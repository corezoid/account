{{/*
Common labels
*/}}
{{- define "sa-singlespace.labels" -}}
tier: {{ .Values.appName | quote }}
release: {{ .Release.Name | quote }}
{{- end }}

{{/*
Image url
*/}}
{{- define "sa-singlespace.imageUrl" -}}
{{ .Values.image.registry }}/{{ .Values.global.repotype | default "public" }}/{{ .Values.image.repository }}:{{ .Values.global.sa.singlespace.tag | default .Chart.AppVersion }}
{{- end }}

{{- define "sa.sa-singlespace.annotations" -}}
{{- with .Values.global.sa.singlespace.annotations }}
{{ toYaml . | trim | indent 4 }}
{{- end }}
{{- end }}

{{/*
Define postgres secret name
*/}}
{{- define "sa-postgres.secretName" -}}
{{- if .Values.global.sa.db }}
{{- if .Values.global.sa.db.secret }}
{{- if .Values.global.sa.db.secret.create }}
{{ .Values.global.sa.db.secret.name }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Readiness
*/}}
{{- define "sa-singlespace.readiness" -}}
readinessProbe:
  httpGet:
    scheme: HTTP
    path: /api/sa/1.0/check/readiness
    port: {{ .Values.global.sa.singlespace.port }}
  initialDelaySeconds: 10
  periodSeconds: 5
  timeoutSeconds: 5
  successThreshold: 1
  failureThreshold: 3
{{- end }}

{{/*
Liveness
*/}}
{{- define "sa-singlespace.liveness" -}}
livenessProbe:
  tcpSocket:
    port: {{ .Values.global.sa.singlespace.port }}
  initialDelaySeconds: 15
  periodSeconds: 10
  timeoutSeconds: 5
  successThreshold: 1
  failureThreshold: 3
{{- end }}
