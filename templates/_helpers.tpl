{{- define "common.imagePullSecrets" -}}
{{- if not (eq .Values.global.repotype "public") }}
imagePullSecrets:
- name: {{ .Values.global.imagePullSecrets.name }}
{{- end }}
{{- end -}}

{{- define "account.domainFull" -}}
{{- if and .Values.global .Values.global.account .Values.global.account.enabled -}}
  {{- if .Values.global.account.subDomain -}}
    {{ .Values.global.account.subDomain }}.{{ .Values.global.domain }}
  {{- else -}}
    {{ .Values.global.domain }}/account
  {{- end }}
{{- end }}
{{- end -}}

{{- define "account.postgresSecretName" -}}
{{- $sa_secret_db := "" }}
{{- if .Values.global.account.db }}
{{- $sa_secret_db = .Values.global.account.db.secret }}
{{- else if .Values.global.db }}
{{- $sa_secret_db = .Values.global.db.secret }}
{{- else }}
{{- $sa_secret_db = nil }}
{{- end }}
{{- printf "%s-%s" .Release.Name $sa_secret_db.name | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "account.redisSecretName" -}}
{{- $sa_secret_redis := "" }}
{{- if .Values.global.account.redis }}
{{- $sa_secret_redis = .Values.global.account.redis.secret }}
{{- else if .Values.global.redis }}
{{- $sa_secret_redis = .Values.global.redis.secret }}
{{- else }}
{{- $sa_secret_redis = nil }}
{{- end }}
{{- printf "%s-%s" .Release.Name $sa_secret_redis.name | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "account.valkeySecretName" -}}
{{- printf "%s-%s" .Release.Name "secret-valkey" | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "account.auth_provider_secret_name" }}
{{- printf "%s-%s" .Release.Name "auth-provider-secret" | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "common.ServiceMonitor.apiVersion" -}}
monitoring.coreos.com/v1
{{- end -}}

{{- define "common.ServiceMonitor.metadata.labes" -}}
simulator.observability/scrape: "true"
{{- end -}}


{{/*
Return the target Kubernetes version
*/}}
{{- define "common.capabilities.kubeVersion" -}}
{{- if .Values.global }}
    {{- if .Values.global.kubeVersion }}
    {{- .Values.global.kubeVersion -}}
    {{- else }}
    {{- default .Capabilities.KubeVersion.Version .Values.kubeVersion -}}
    {{- end -}}
{{- else }}
{{- default .Capabilities.KubeVersion.Version .Values.kubeVersion -}}
{{- end -}}
{{- end -}}


{{/*
Return the appropriate apiVersion for RBAC resources.
*/}}
{{- define "common.capabilities.rbac.apiVersion" -}}
{{- if semverCompare "<1.17-0" (include "common.capabilities.kubeVersion" .) -}}
{{- print "rbac.authorization.k8s.io/v1beta1" -}}
{{- else -}}
{{- print "rbac.authorization.k8s.io/v1" -}}
{{- end -}}
{{- end -}}


{{- define "saDomain" -}}
{{ .Values.global.account.subDomain }}.{{ .Values.global.domain }}
{{- end -}}

