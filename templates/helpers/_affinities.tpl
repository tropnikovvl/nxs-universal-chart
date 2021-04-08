{{- define "helpers.affinities.nodes.soft" -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - preference:
      matchExpressions:
        - key: {{ .key }}
          operator: In
          values:
            {{- range .values }}
            {{- if typeIs "string" . }}
            - {{ . | quote }}
            {{- else }}
            - {{ . }}
            {{- end }}
            {{- end }}
    weight: 1
{{- end -}}

{{- define "helpers.affinities.nodes.hard" -}}
requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:
    - matchExpressions:
        - key: {{ .key }}
          operator: In
          values:
            {{- range .values }}
            {{- if typeIs "string" . }}
            - {{ . | quote }}
            {{- else }}
            - {{ . }}
            {{- end }}
            {{- end }}
{{- end -}}

{{- define "helpers.affinities.nodes" -}}
  {{- if .type -}}
  {{- if eq .type "soft" }}
    {{- include "helpers.affinities.nodes.soft" $ -}}
  {{- else if eq .type "hard" }}
    {{- include "helpers.affinities.nodes.hard" $ -}}
  {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "helpers.affinities.pods.soft" -}}
{{- $component := default "" .component -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - podAffinityTerm:
      labelSelector:
        matchLabels: {{- (include "helpers.app.selectorLabels" .context) | nindent 10 }}
          {{- if not (empty $component) }}
          {{ printf "app.kubernetes.io/component: %s" $component }}
          {{- end }}
      namespaces:
        - {{ .context.Release.Namespace | quote }}
      topologyKey: kubernetes.io/hostname
    weight: 1
{{- end -}}

{{- define "helpers.affinities.pods.hard" -}}
{{- $component := default "" .component -}}
requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchLabels: {{- (include "helpers.app.selectorLabels" .context) | nindent 8 }}
        {{- if not (empty $component) }}
        {{ printf "app.kubernetes.io/component: %s" $component }}
        {{- end }}
    namespaces:
      - {{ .context.Release.Namespace | quote }}
    topologyKey: kubernetes.io/hostname
{{- end -}}

{{- define "helpers.affinities.pods" -}}
  {{- if .type -}}
  {{- if eq .type "soft" }}
    {{- include "helpers.affinities.pods.soft" $ -}}
  {{- else if eq .type "hard" }}
    {{- include "helpers.affinities.pods.hard" $ -}}
  {{- end -}}
  {{- end -}}
{{- end -}}