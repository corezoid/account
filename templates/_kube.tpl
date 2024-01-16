{{- define "module.name" -}}
{{- default "account" .Values.global.account.module | trunc 63 | trimSuffix "-" }}
{{- end }}


{{- define "module.frontend.name" -}}
{{ include "module.name" . }}-{{- default "frontend" .Values.global.account.frontend.name | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "account.frontend.service.name" -}}
{{- include "module.frontend.name" . }}-service
{{- end -}}
