{{/*
Common labels
*/}}
{{- define "account.valkey.labels" -}}
release: {{ .Release.Name }}
application: account-valkey
role: master
{{- if .Values.global.account.valkey.customLabels }}
{{- toYaml .Values.global.account.valkey.customLabels | nindent 0 }}
{{- end }}
{{- end }}

