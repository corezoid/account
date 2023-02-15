{{- define "sa.ingressAnnotations" -}}
kubernetes.io/ingress.class: nginx
nginx.ingress.kubernetes.io/ssl-redirect: "true"
nginx.ingress.kubernetes.io/configuration-snippet: |
    more_set_headers "Cache-Control no-cache";
    more_set_headers "Cache-Control: no-store";
    expires 0;
{{- end }}