{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "spin.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "spin.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "spin.labels" -}}
helm.sh/chart: {{ include "spin.chart" . }}
{{ include "spin.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "spin.subchart" -}}
{{- printf "%s-%s" "webapp" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "spin.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spin.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create host
*/}}
{{- define "spin.host" -}}
{{- printf "%s.%s" .Values.environment .Values.domain }}
{{- end }}

{{/*
Detect which version of main image we should use
*/}}
{{- define "spin.version" -}}
{{- if .Values.github.enabled }}
{{- printf "Fetching latest tag from GitHub..." | quote -}}
{{- printf -}}
{{- $githubTag := printf "https://api.github.com/repos/%s/%s/releases/latest" .Values.github.organization .Values.github.repository | quote }}
{{- $githubTagResponse := printf "$(curl -s %s)" $githubTag | quote }}
{{- $githubTagResponse -}}
{{- else }}
{{- .Values.deployment.image.tag | quote -}}
{{- end }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "spin.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "spin.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create volumes mounts definition
*/}}
{{- define "spin.volumeMounts" -}}
{{- if .Values.flux.configmap.enabled }}
volumeMounts:
- name: config-flux-volume
mountPath: {{ .Values.flux.configmap.filepath -}}{{- .Values.flux.configmap.filename }}
subPath: {{ .Values.flux.configmap.filename }}
{{- end }}
{{- with .Values.deployment.volumeMounts }}
volumeMounts:
   {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.deployment.extraVolumeMounts }}
   {{- toYaml | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Create volumes definition
*/}}
{{- define "spin.volumes" -}}
  volumes:
  {{- if .Values.flux.configmap.enabled }}
  volumes:
  - name: config-flux-volume
    configMap:
      name: {{ .Release.Name }}-config-flux
  {{- end }}
  {{- with .Values.deployment.volumes }}
  {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- with .Values.deployment.extraVolumes }}
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}

