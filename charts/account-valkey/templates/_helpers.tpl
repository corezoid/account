{{/*
Common labels
*/}}
{{- define "account.valkey.labels" -}}
release: {{ .Release.Name }}
application: account-valkey
role: master
{{- end }}

