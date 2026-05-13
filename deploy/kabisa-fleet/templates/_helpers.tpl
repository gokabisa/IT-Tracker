{{- define "kabisa-fleet.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "kabisa-fleet.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "kabisa-fleet.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "kabisa-fleet.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "kabisa-fleet.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kabisa-fleet.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "kabisa-fleet.redisAddress" -}}
{{- printf "%s-redis-master:6379" .Release.Name -}}
{{- end -}}

{{- define "kabisa-fleet.image" -}}
{{- printf "%s:%s" .Values.image.repository (required "image.tag must be set" .Values.image.tag) -}}
{{- end -}}

{{- define "kabisa-fleet.fleetEnv" -}}
{{- range $key, $value := .Values.env }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
- name: FLEET_MYSQL_ADDRESS
  value: {{ .Values.mysql.address | quote }}
- name: FLEET_MYSQL_DATABASE
  value: {{ .Values.mysql.database | quote }}
- name: FLEET_MYSQL_USERNAME
  value: {{ .Values.mysql.username | quote }}
- name: FLEET_MYSQL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.mysqlSecret }}
      key: {{ .Values.mysql.passwordKey }}
- name: FLEET_REDIS_ADDRESS
  value: {{ include "kabisa-fleet.redisAddress" . | quote }}
{{- end -}}
