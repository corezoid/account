# Pre-install

## Database: 
For correct database migration application need to be owner of `accounts` database.
Use next sql script for change owner:

```sql
ALTER DATABASE accounts OWNER TO application_user ;
```

where `application_user` is a current user for `single-account` application

Also need change owner for all `table`, `sequences` and `views` in `accounts` database to `application_user`.

Here an example how to do this:

```bash
for tbl in `psql -h single_account_database_host -p 5432 -qAt -c "select tablename from pg_tables where schemaname = 'public';" accounts` ; do  psql -h single_account_database_host -p 5432 -c "alter table \"$tbl\" owner to application_user" accounts ; done

for tbl in `psql -h single_account_database_host -p 5432 -qAt -c "select sequence_name from information_schema.sequences where sequence_schema = 'public';" accounts` ; do  psql -h single_account_database_host -p 5432 -c "alter sequence \"$tbl\" owner to application_user" accounts ; done

for tbl in `psql -h single_account_database_host -p 5432 -qAt -c "select table_name from information_schema.views where table_schema = 'public';" accounts` ; do  psql -h single_account_database_host -p 5432 -c "alter view \"$tbl\" owner to application_user" accounts ; done
```

# Install


```git clone https://github.com/corezoid/account.git```

```cd account```


Create namespace if need:
```kubectl create namespace account```

Make changes in `values.yaml` file and run command:
```helm upgrade --install account -n account -f ./values.yaml .```

# Avatar delivery (`account-frontend` nginx)

Avatars are files on the shared volume mounted at `/<persistantVolumeClaimShareDir>` (default
`/avatars`) and are served by the `account-frontend` nginx (`charts/account-frontend/templates/configmap.yaml`).
Files are written by `account-workspace` (`resource_dir`): `<id>.jpg` (user photo),
`animation/<id>.jpg` (poster frame) and `animation/<id>.mp4` (7.5 s loop) of the AI-generated
animated avatar, `workspaces/<wsId>.jpg` (workspace logo), `workspaces/<wsExtId>/<id>.jpg`.

| URL | on miss |
|---|---|
| `/avatars/<id>.jpg` | placeholder `/static/avatar.jpg`, 200 |
| `/avatars/<WxH>/<file>` | placeholder, 200 (resized on the fly, `image_filter crop`) |
| `/avatars/workspaces/<ws>/<file>` | placeholder, 200 |
| `/avatars/workspaces/<ws>/<WxH>/<file>` | placeholder, 200 (resized on the fly) |
| `/avatars/animation/<id>.jpg` | user photo `/avatars/<id>.jpg`, else `/static/anonymous.jpg`, 200 |
| `/avatars/animation/<WxH>/<id>.jpg` | same as above, resized and cached (see below) |
| `/avatars/animation/<id>.mp4` | 404 if the user has a photo but no animation; `/static/anonymous.mp4` if no photo at all |
| anything else under `/avatars/` | exact file or 404 |

`<WxH>` = 2–4 digits each. Unsupported shapes (`.webm`, extra path segments, …) return 404.

## Cache-Control

| response | header | value |
|---|---|---|
| hit, URL has `?v=<N>` | `global.account.frontend.avatars.cache.versioned_max_age` | `public, max-age=31536000, immutable` |
| hit, URL has no `?v=` | `…cache.unversioned_max_age` | `public, max-age=86400` |
| placeholder / fallback / 404 | `…cache.placeholder_max_age` | `public, max-age=120` |

`?v=<N>` is the Simulator's `users.version`, bumped by the Account `user/set` event on every
profile update (a photo upload is one), so a new avatar gets a new URL. The short TTL on
fallbacks matters because the animation is generated asynchronously after the upload: a client
that asks for the poster/video during those seconds must not cache the fallback for a year.
Files replaced in place without a version bump (e.g. a bulk re-encode) are picked up by browsers
only after the next version bump — visually identical content, so this is acceptable.

## Resized poster frames

`/avatars/animation/<WxH>/<id>.jpg?v=N` is proxied to a loopback-only second `server`
(`127.0.0.1:<avatars.poster.port>`, default 8090) that runs `image_filter crop` on the poster and
falls back to the user photo, then `/static/anonymous.jpg`. The main server caches the result in
`/var/cache/nginx/avatars` (`proxy_cache`, key `W:H:id:v`, `avatars.poster.cache_valid`, bounded by
`avatars.poster.cache_max_size`; per pod, not shared). Fallback posters are flagged
`X-Avatar-Source: photo|anonymous`, get the short TTL and `X-Accel-Expires` so they are re-checked
soon. `X-Cache-Status: MISS|HIT|…` is returned to the client. Disable with
`avatars.poster.enabled: false`.

Note: poster frames written by the current `account-workspace` are PNG bytes with a `.jpg` name
(Gemini output), so a resized variant of such a file is a PNG as well (~150 KB at 480x296 instead of
~10 KB for a real JPEG); see CGA-2529/CGA-2530 for the normalisation of the stored files.

## Normalising the stored files (CGA-2529 / CGA-2530)

`global.account.frontend.avatars.normalize.enabled: true` renders a CronJob
`<release>-avatars-normalize` (default 03:30 UTC daily) that runs
`charts/account-frontend/files/avatars-normalize.sh` in the account-workspace image (it has
ffmpeg) with the avatars volume mounted read-write. For every `animation/<id>.mp4` wider than
480 px or taller than 270 px, with an audio track, not constrained-baseline or without faststart it
writes a 480px/CRF 28/baseline/`-an`/`+faststart` version (taller-than-16:9 clips are cropped to a
480x270 band around the face, `face_y`; the CRF is raised in steps of 3 up to `max_crf` until the
clip is under `target_bytes`); every `animation/<id>.jpg` that is actually
PNG becomes a JPEG. Files are replaced by an atomic rename; the original is copied once to
`<volume>/.orig/animation/` (rollback = copy back). The job is idempotent and prints a
`SUMMARY` line.

Backfill / manual run:
```bash
kubectl -n sa-prod create job --from=cronjob/singlespace-prod-avatars-normalize avatars-normalize-backfill
kubectl -n sa-prod logs -f job/avatars-normalize-backfill | grep -E 'SUMMARY|FAIL'
```
Dry run first: set `normalize.dry_run: true` (or `kubectl set env job/... DRY_RUN=1` on a copy).
Browsers keep an `immutable`-cached copy of a rewritten file until the user's `?v=` changes;
that is fine, the content is the same picture.

## Testing a config change locally

```bash
helm template singlespace-prod . -f <values.yaml> > /tmp/r.yaml   # extract both ConfigMaps
docker run --rm -p 18080:80 --add-host account-auth-service:127.0.0.1 --add-host account-workspace-service:127.0.0.1 \
  -v $PWD/nginx.conf:/etc/nginx/nginx.conf:ro -v $PWD/site.conf:/etc/nginx/conf.d/account-frontend.conf:ro \
  -v $PWD/fixtures/avatars:/avatars:ro -v $PWD/fixtures/www:/ebsmnt/www/mw-auth:ro nginx:1.26.3-alpine
curl -sD - -o /dev/null -H 'Host: account.corezoid.com' http://localhost:18080/avatars/animation/480x296/4.jpg?v=1
```
