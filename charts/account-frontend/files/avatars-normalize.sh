#!/bin/sh
# Normalise stored animated avatars to the delivery format (CGA-2529 / CGA-2530).
#
#   animation/<id>.mp4  -> 480px wide, at most 16:9 (taller clips are cropped to a 480x270 band around the
#                          face: Veo's 9:16 output has the head at ~35% of the height, a centre band shows the
#                          chin), H.264 constrained baseline, CRF 28 raised in steps of 3 up to MAX_CRF until the
#                          file is under TARGET_BYTES, no audio, +faststart
#   animation/<id>.jpg  -> real JPEG (the generator used to write PNG bytes under a .jpg name)
#
# Idempotent: a file is rewritten only when it does not match the target; the first time a file
# is touched its original is copied to $BACKUP_DIR (same layout), so a rollback is `cp` back.
# A rewrite always starts from the backed-up original when one exists (no generation loss).
# Files are replaced with an atomic rename on the same filesystem, so nginx never sees a partial
# file. Needs ffmpeg + ffprobe (present in the account-workspace image).
#
# Env: AVATARS_DIR (default /avatars), BACKUP_DIR (default $AVATARS_DIR/.orig), DRY_RUN=1,
#      MAX_WIDTH (480), MAX_HEIGHT (270), CRF (28), MAX_CRF (34), TARGET_BYTES (102400), FACE_Y (0.36),
#      PRESET (medium), JPEG_Q (3 = ffmpeg mjpeg quality, 2..5 sane),
#      LIMIT (stop after N rewritten files, 0 = no limit)
set -u

AVATARS_DIR="${AVATARS_DIR:-/avatars}"
ANIM_DIR="$AVATARS_DIR/animation"
BACKUP_DIR="${BACKUP_DIR:-$AVATARS_DIR/.orig}"
DRY_RUN="${DRY_RUN:-0}"
MAX_WIDTH="${MAX_WIDTH:-480}"
MAX_HEIGHT="${MAX_HEIGHT:-270}"
CRF="${CRF:-28}"
MAX_CRF="${MAX_CRF:-34}"
TARGET_BYTES="${TARGET_BYTES:-102400}"
FACE_Y="${FACE_Y:-0.36}"
PRESET="${PRESET:-medium}"
JPEG_Q="${JPEG_Q:-3}"
LIMIT="${LIMIT:-0}"

log() { echo "$(date -u +%FT%TZ) $*"; }

for bin in ffmpeg ffprobe; do
  command -v "$bin" >/dev/null 2>&1 || { log "FATAL: $bin not found"; exit 2; }
done
[ -d "$ANIM_DIR" ] || { log "FATAL: $ANIM_DIR not found"; exit 2; }

mkdir -p "$BACKUP_DIR/animation" 2>/dev/null || true
# marker files for clips that stay above TARGET_BYTES even at MAX_CRF, so they are not retried every night
STATE_DIR="$BACKUP_DIR/.state"; mkdir -p "$STATE_DIR" 2>/dev/null || true

n_mp4=0 n_mp4_done=0 n_mp4_fail=0 n_jpg=0 n_jpg_done=0 n_jpg_fail=0 bytes_before=0 bytes_after=0

backup_once() { # $1 = relative path (animation/<id>.mp4)
  [ -f "$BACKUP_DIR/$1" ] || cp -p "$AVATARS_DIR/$1" "$BACKUP_DIR/$1"
}

# moov before mdat? (busybox-friendly: look for the atom names in the first 64 KB)
has_faststart() {
  head -c 65536 "$1" | tr -c '[:alnum:]' ' ' | grep -q 'moov'
}

needs_video_rewrite() { # prints a reason or nothing
  f="$1"
  ffprobe -v error "$f" >/dev/null 2>&1 || { echo "unreadable"; return; }
  width=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=nk=1:nw=1 "$f" 2>/dev/null)
  height=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=nk=1:nw=1 "$f" 2>/dev/null)
  profile=$(ffprobe -v error -select_streams v:0 -show_entries stream=profile -of default=nk=1:nw=1 "$f" 2>/dev/null)
  audio=$(ffprobe -v error -select_streams a -show_entries stream=codec_type -of default=nk=1:nw=1 "$f" 2>/dev/null)
  [ -n "$width" ] || { echo "no-video-stream"; return; }
  [ "$width" -gt "$MAX_WIDTH" ] && { echo "width=$width"; return; }
  [ "$height" -gt "$MAX_HEIGHT" ] && { echo "height=$height"; return; }
  size=$(stat -c %s "$f")
  [ "$size" -gt "$TARGET_BYTES" ] && [ ! -f "$STATE_DIR/$(basename "$f").maxcrf" ] && { echo "size=$size"; return; }
  [ -n "$audio" ] && { echo "has-audio"; return; }
  case "$profile" in *Baseline*) ;; *) echo "profile=$profile"; return;; esac
  has_faststart "$f" || { echo "no-faststart"; return; }
}

is_png() { [ "$(head -c 4 "$1" | od -An -tx1 | tr -d ' \n')" = "89504e47" ]; }

rewritten=0
for f in "$ANIM_DIR"/[0-9]*.mp4; do
  [ -f "$f" ] || continue
  n_mp4=$((n_mp4+1))
  reason=$(needs_video_rewrite "$f")
  [ -n "$reason" ] || continue
  rel="animation/$(basename "$f")"
  size0=$(stat -c %s "$f")
  if [ "$DRY_RUN" = "1" ]; then log "DRY mp4 $rel ($reason, $size0 B)"; continue; fi
  tmp="$f.normalize.tmp.mp4"
  src="$f"; [ -f "$BACKUP_DIR/$rel" ] && src="$BACKUP_DIR/$rel"
  # scale to the target width, then crop anything taller than 16:9 to a MAX_HEIGHT band around the face
  # (band centre at FACE_Y of the height, clamped to the frame); raise CRF until the clip fits TARGET_BYTES
  vf="scale=${MAX_WIDTH}:-2:flags=lanczos,crop=iw:min(ih\,${MAX_HEIGHT}):0:min(ih-min(ih\,${MAX_HEIGHT})\,max(0\,ih*${FACE_Y}-${MAX_HEIGHT}/2))"
  crf="$CRF"; ok=""
  while :; do
    if ffmpeg -v error -nostdin -y -i "$src" -an -vf "$vf" \
         -c:v libx264 -profile:v baseline -level 3.0 -pix_fmt yuv420p -crf "$crf" -preset "$PRESET" \
         -movflags +faststart "$tmp" </dev/null 2>"$tmp.err" && [ -s "$tmp" ] && ffprobe -v error "$tmp" >/dev/null 2>&1; then
      ok=1
    else
      ok=""; break
    fi
    [ "$(stat -c %s "$tmp")" -le "$TARGET_BYTES" ] && break
    [ "$crf" -ge "$MAX_CRF" ] && { touch "$STATE_DIR/$(basename "$f").maxcrf"; break; }
    crf=$((crf+3)); [ "$crf" -gt "$MAX_CRF" ] && crf="$MAX_CRF"
  done
  if [ -n "$ok" ]; then
    backup_once "$rel"
    mv -f "$tmp" "$f"; rm -f "$tmp.err"
    size1=$(stat -c %s "$f")
    bytes_before=$((bytes_before+size0)); bytes_after=$((bytes_after+size1))
    n_mp4_done=$((n_mp4_done+1)); rewritten=$((rewritten+1))
    log "mp4 $rel: $reason, $size0 -> $size1 B (crf $crf)"
  else
    n_mp4_fail=$((n_mp4_fail+1)); log "FAIL mp4 $rel: $(head -c 300 "$tmp.err" 2>/dev/null | tr '\n' ' ')"; rm -f "$tmp" "$tmp.err"
  fi
  [ "$LIMIT" -gt 0 ] && [ "$rewritten" -ge "$LIMIT" ] && break
done

for f in "$ANIM_DIR"/[0-9]*.jpg; do
  [ -f "$f" ] || continue
  case "$(basename "$f")" in *_*) continue;; esac   # skip _blue / _tmp intermediates
  n_jpg=$((n_jpg+1))
  is_png "$f" || continue
  rel="animation/$(basename "$f")"
  size0=$(stat -c %s "$f")
  if [ "$DRY_RUN" = "1" ]; then log "DRY jpg $rel (png, $size0 B)"; continue; fi
  tmp="$f.normalize.tmp.jpg"
  if ffmpeg -v error -nostdin -y -i "$f" -frames:v 1 -q:v "$JPEG_Q" -pix_fmt yuvj420p -f image2 "$tmp" </dev/null 2>"$tmp.err" && [ -s "$tmp" ]; then
    backup_once "$rel"
    mv -f "$tmp" "$f"; rm -f "$tmp.err"
    size1=$(stat -c %s "$f")
    bytes_before=$((bytes_before+size0)); bytes_after=$((bytes_after+size1))
    n_jpg_done=$((n_jpg_done+1)); rewritten=$((rewritten+1))
    log "jpg $rel: png->jpeg, $size0 -> $size1 B"
  else
    n_jpg_fail=$((n_jpg_fail+1)); log "FAIL jpg $rel: $(head -c 300 "$tmp.err" 2>/dev/null | tr '\n' ' ')"; rm -f "$tmp" "$tmp.err"
  fi
  [ "$LIMIT" -gt 0 ] && [ "$rewritten" -ge "$LIMIT" ] && break
done

log "SUMMARY mp4: scanned=$n_mp4 rewritten=$n_mp4_done failed=$n_mp4_fail | jpg: scanned=$n_jpg rewritten=$n_jpg_done failed=$n_jpg_fail | bytes $bytes_before -> $bytes_after | dry_run=$DRY_RUN"
[ "$n_mp4_fail" -eq 0 ] && [ "$n_jpg_fail" -eq 0 ]
