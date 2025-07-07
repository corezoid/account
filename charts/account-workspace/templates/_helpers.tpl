{{/*
Common labels
*/}}

{{- define "account.common.initWait.image" -}}
{{ .Values.global.imageInit.repository }}:{{ .Values.global.imageInit.tag }}
{{- end -}}


{{- define "account.workspace.labels" -}}
release: {{ .Release.Name | quote }}
application: {{ include "module.workspace.name" . }}
{{- if .Values.global.account.workspace.customLabels }}
{{- toYaml .Values.global.account.workspace.customLabels | nindent 0 }}
{{- end }}
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
http
{{- end }}

{{- define "account.workspace.portProtocol" -}}
{{- printf "%s" "TCP" }}
{{- end }}

{{- define "account.workspace.cpuHpa.name" -}}
{{- include "module.workspace.name" . }}-cpu-autoscale
{{- end -}}

{{/*
Set metrics port
*/}}
{{- define "account.workspace.portMetricsNumber" -}}
{{ .Values.global.account.workspace.portMetrics | default 9100 }}
{{- end }}

{{/*
Set profiler port
*/}}
{{- define "account.workspace.portProfilerNumber" -}}
{{ .Values.global.account.workspace.portProfiler | default 8050 }}
{{- end }}

{{/*
Image url
*/}}
{{- define "account.workspace.imageUrl" -}}
{{ .Values.global.imageRegistry }}/{{ .Values.global.repotype | default "public" }}/{{ .Values.image.repository }}:{{ .Values.global.account.workspace.tag | default .Chart.AppVersion }}
{{- end }}

{{- define "account.workspace.annotations" -}}
{{- with .Values.global.account.workspace.annotations }}
{{ toYaml . | trim | indent 4 }}
{{- end }}
{{- end }}

{{/*
Liveness
*/}}
{{- define "account.workspace.liveness" -}}
livenessProbe:
  httpGet:
    scheme: HTTP
    path: {{ .Values.appAuthLivenessPath }}
    port: {{ include "account.workspace.portHttpName" . }}
  initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds }}
  periodSeconds: {{ .Values.livenessProbe.periodSeconds }}
  timeoutSeconds: {{ .Values.livenessProbe.timeoutSeconds }}
  successThreshold: {{ .Values.livenessProbe.successThreshold }}
  failureThreshold: {{ .Values.livenessProbe.failureThreshold }}
{{- end }}

{{/*
Readiness
*/}}
{{- define "account.workspace.readiness" -}}
readinessProbe:
  httpGet:
    scheme: HTTP
    path: {{ .Values.appAuthReadinessPath }}
    port: {{ include "account.workspace.portHttpName" . }}
  initialDelaySeconds: {{ .Values.readinessProbe.initialDelaySeconds }}
  periodSeconds: {{ .Values.readinessProbe.periodSeconds }}
  timeoutSeconds: {{ .Values.readinessProbe.timeoutSeconds }}
  successThreshold: {{ .Values.readinessProbe.successThreshold }}
  failureThreshold: {{ .Values.readinessProbe.failureThreshold }}
{{- end }}
