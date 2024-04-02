{{/*
Common labels
*/}}
{{- define "account.workspace.labels" -}}
release: {{ .Release.Name | quote }}
application: {{ include "module.workspace.name" . }}
{{- end }}

{{- define "module.workspace.name" -}}
{{ include "module.name" . }}-{{- default "workspace" .Values.global.account.workspace.name | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "account.workspace.service.name" -}}
{{- include "module.workspace.name" . }}-service
{{- end -}}

{{- define "account.workspace.configmap.name" -}}
{{- include "module.workspace.name" . }}-configmap
{{- end -}}

{{- define "account.workspace.deployment.name" -}}
{{- include "module.workspace.name" . }}-deployment
{{- end -}}

{{- define "account.workspace.role.name" -}}
{{- include "module.workspace.name" . }}-role
{{- end -}}

{{- define "account.workspace.roleBinding.name" -}}
{{- include "module.workspace.name" . }}-rolebind
{{- end -}}

{{- define "account.workspace.serviceaccount.name" -}}
{{- if .Values.global.account.workspace.serviceAccount }}
{{- if .Values.global.account.workspace.serviceAccount.create }}
{{- include "module.workspace.name" . }}
{{- else if .Values.global.account.workspace.serviceAccount.name }}
{{ .Values.global.account.workspace.serviceAccount.name }}
{{- else }}
""
{{- end }}
{{- end }}
{{- end }}

{{- define "account.workspace.servicePortNumber" -}}
80
{{- end }}

{{- define "account.workspace.portNumber" -}}
{{- if .Values.global.account.workspace.port -}}
{{ .Values.global.account.workspace.port }}
{{- else }}
{{- printf "%s" 8080 }}
{{- end -}}
{{- end }}

{{- define "account.workspace.portHttpName" -}}
{{- printf "%s" "http" }}
{{- end }}

{{- define "account.workspace.portProtocol" -}}
{{- printf "%s" "TCP" }}
{{- end }}

{{- define "account.workspace.cpuHpa.name" -}}
{{- include "module.workspace.name" . }}-cpu-autoscale
{{- end -}}


{{/*
Image url
*/}}
{{- define "account.workspace.imageUrl" -}}
{{ .Values.image.registry }}/{{ .Values.global.repotype | default "public" }}/{{ .Values.image.repository }}:{{ .Values.global.account.workspace.tag | default .Chart.AppVersion }}
{{- end }}

{{- define "account.workspace.annotations" -}}
{{- with .Values.global.account.workspace.annotations }}
{{ toYaml . | trim | indent 4 }}
{{- end }}
{{- end }}

{{/*
Readiness
*/}}
{{- define "account.workspace.readiness" -}}
readinessProbe:
  httpGet:
    scheme: HTTP
    path: /api/sa/1.0/check/readiness
    port: {{ .Values.global.account.workspace.port }}
  initialDelaySeconds: 10
  periodSeconds: 5
  timeoutSeconds: 5
  successThreshold: 1
  failureThreshold: 3
{{- end }}

{{/*
Liveness
*/}}
{{- define "account.workspace.liveness" -}}
livenessProbe:
  tcpSocket:
    port: {{ .Values.global.account.workspace.port }}
  initialDelaySeconds: 15
  periodSeconds: 10
  timeoutSeconds: 5
  successThreshold: 1
  failureThreshold: 3
{{- end }}
