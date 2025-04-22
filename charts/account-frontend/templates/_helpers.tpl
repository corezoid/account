{{/*
Common labels
*/}}
{{- define "account.frontend.labels" -}}
release: {{ .Release.Name | quote }}
application: {{ include "module.frontend.name" . }}
{{- end }}

{{- define "module.frontend.name" -}}
{{ include "module.name" . }}-{{- default "frontend" .Values.global.account.frontend.name | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "account.frontend.service.name" -}}
{{- include "module.frontend.name" . }}
{{- end -}}

{{- define "account.frontend.configmap.name.nginx" -}}
{{- include "module.frontend.name" . }}-nginx-configmap
{{- end -}}

{{- define "account.frontend.configmap.name.site" -}}
{{- include "module.frontend.name" . }}-site-configmap
{{- end -}}

{{- define "account.frontend.deployment.name" -}}
{{- include "module.frontend.name" . }}
{{- end -}}

{{- define "account.frontend.role.name" -}}
{{- include "module.frontend.name" . }}-role
{{- end -}}

{{- define "account.frontend.roleBinding.name" -}}
{{- include "module.frontend.name" . }}-role-binding
{{- end -}}

{{- define "account.frontend.serviceaccount.name" -}}
{{- if .Values.global.account.frontend.serviceAccount }}
{{- if .Values.global.account.frontend.serviceAccount.create }}
{{- include "module.frontend.name" . }}
{{- else if .Values.global.account.frontend.serviceAccount.name }}
{{ .Values.global.account.frontend.serviceAccount.name }}
{{- else }}
""
{{- end }}
{{- end }}
{{- end -}}

{{- define "account.frontend.portNumber" -}}
{{- if .Values.global.account.frontend.port -}}
{{ .Values.global.account.frontend.port }}
{{- else }}
{{- printf "%s" 8081 }}
{{- end -}}
{{- end }}

{{- define "account.frontend.portHttpName" -}}
http
{{- end }}

{{- define "account.frontend.portProtocol" -}}
TCP
{{- end }}

{{- define "account.frontend.cpuHpa.name" -}}
{{- include "module.frontend.name" . }}-cpu-autoscale
{{- end -}}


{{/*
Image url
*/}}
{{- define "account.frontend.imageUrl" -}}
{{ .Values.global.imageRegistry }}/{{ .Values.global.repotype | default "public" }}/{{ .Values.image.repository }}:{{ .Values.global.account.frontend.tag | default .Chart.AppVersion }}
{{- end }}

{{- define "account.frontend.annotations" -}}
{{- with .Values.global.account.frontend.annotations }}
{{ toYaml . | trim | indent 4 }}
{{- end }}
{{- end }}

{{/*
Liveness
*/}}
{{- define "account.frontend.liveness" -}}
livenessProbe:
  httpGet:
    scheme: HTTP
    path: /liveness-proxy
    port: {{ include "account.frontend.portHttpName" . }}
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  successThreshold: 1
  failureThreshold: 3
{{- end }}

{{/*
Readiness
*/}}
{{- define "account.frontend.readiness" -}}
readinessProbe:
  httpGet:
    scheme: HTTP
    path: /liveness-proxy
    port: {{ include "account.frontend.portHttpName" . }}
  initialDelaySeconds: 10
  periodSeconds: 10
  timeoutSeconds: 5
  successThreshold: 1
  failureThreshold: 3
{{- end }}
