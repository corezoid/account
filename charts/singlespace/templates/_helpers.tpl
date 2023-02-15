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
