{{/*
Common labels
*/}}
{{- define "account.auth.labels" -}}
release: {{ .Release.Name | quote }}
application: {{ include "module.auth.name" . }}
{{- end }}

{{- define "module.auth.name" -}}
{{ include "module.name" . }}-{{- default "auth" .Values.global.account.auth.name | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "account.auth.service.name" -}}
{{- include "module.auth.name" . }}-service
{{- end -}}

{{- define "account.auth.configmap.name" -}}
{{- include "module.auth.name" . }}-configmap
{{- end -}}

{{- define "account.auth.deployment.name" -}}
{{- include "module.auth.name" . }}-deployment
{{- end -}}

{{- define "account.auth.role.name" -}}
{{- include "module.auth.name" . }}-role
{{- end -}}

{{- define "account.auth.roleBinding.name" -}}
{{- include "module.auth.name" . }}-rolebind
{{- end -}}

{{- define "account.auth.serviceaccount.name" -}}
{{- if .Values.global.account.auth.serviceAccount }}
{{- if .Values.global.account.auth.serviceAccount.create }}
{{- include "module.auth.name" . }}
{{- else if .Values.global.account.auth.serviceAccount.name }}
{{ .Values.global.account.auth.serviceAccount.name }}
{{- else }}
""
{{- end }}
{{- end }}
{{- end -}}

{{- define "account.auth.servicePortNumber" -}}
80
{{- end }}

{{- define "account.auth.portNumber" -}}
{{- if .Values.global.account.auth.port -}}
{{ .Values.global.account.auth.port }}
{{- else }}
{{- printf "%s" 8080 }}
{{- end -}}
{{- end }}

{{- define "account.auth.portHttpName" -}}
http
{{- end }}

{{- define "account.auth.portProtocol" -}}
TCP
{{- end }}

{{- define "account.auth.cpuHpa.name" -}}
{{- include "module.auth.name" . }}-cpu-autoscale
{{- end -}}


{{/*
Image url
*/}}
{{- define "account.auth.imageUrl" -}}
{{ .Values.image.registry }}/{{ .Values.global.repotype | default "public" }}/{{ .Values.image.repository }}:{{ .Values.global.account.auth.tag | default .Chart.AppVersion }}
{{- end }}

{{- define "account.auth.annotations" -}}
{{- with .Values.global.account.auth.annotations }}
{{ toYaml . | trim | indent 4 }}
{{- end }}
{{- end }}

