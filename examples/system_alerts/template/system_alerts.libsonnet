function(config={})
local utils = import 'utils.libsonnet';

      {
        name: config.rule,
        rules: [
          {
            expr: |||
              kube_node_status_condition{%(kubeStateMetricsSelector)s,condition="Ready",status="true"} == 0
            ||| % config.selectors,
            labels: {
              severity: 'warning',
             },
            annotations: {
              message: '{{ $labels.node }} has been unready for more than an hour.',
            },
            'for': '1h',
            alert: 'KubeNodeNotReady',
          },
          {
            alert: 'KubeVersionMismatch',
            expr: |||
              count(count by (gitVersion) (label_replace(kubernetes_build_info{%(notKubeDnsSelector)s},"gitVersion","$1","gitVersion","(v[0-9]*.[0-9]*.[0-9]*).*"))) > 1
            ||| % config.selectors,
            'for': '1h',
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: 'There are {{ $value }} different semantic versions of Kubernetes components running.',
            },
          },
          {
            alert: 'KubeClientErrors',
            // Many clients use get requests to check the existence of objects,
            // this is normal and an expected error, therefore it should be
            // ignored in this alert.
            expr: |||
              (sum(rate(rest_client_requests_total{code=~"5.."}[5m])) by (instance, job)
                /
              sum(rate(rest_client_requests_total[5m])) by (instance, job))
              * 100 > 1
            |||,
            'for': '15m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: "Kubernetes API server client '{{ $labels.job }}/{{ $labels.instance }}' is experiencing {{ printf \"%0.0f\" $value }}% errors.'",
            },
          },
          {
            alert: 'KubeClientErrors',
            expr: |||
              sum(rate(ksm_scrape_error_total{%(kubeStateMetricsSelector)s}[5m])) by (instance, job) > 0.1
            ||| % config.selectors,
            'for': '15m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: "Kubernetes API server client '{{ $labels.job }}/{{ $labels.instance }}' is experiencing {{ printf \"%0.0f\" $value }} errors / second.",
            },
          },
          {
            alert: 'KubeletTooManyPods',
            expr: |||
              kubelet_running_pod_count{%(kubeletSelector)s} > %(kubeletPodLimit)s * 0.9
            ||| % [config.selectors.kubeletSelector, config.kubeletPodLimit],
            'for': '15m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: 'Kubelet {{ $labels.instance }} is running {{ $value }} Pods, close to the limit of %d.' % config.kubeletPodLimit,
            },
          },
          {
            alert: 'KubeAPILatencyHigh',
            expr: |||
              cluster_quantile:apiserver_request_duration_seconds:histogram_quantile{%(kubeApiserverSelector)s,quantile="0.99",subresource!="log",verb!~"^(?:LIST|WATCH|WATCHLIST|PROXY|CONNECT)$"} > %(WarningSeconds)s
            ||| % [config.selectors.kubeApiserverSelector, config.kubeAPILatency.WarningSeconds],
            'for': '10m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: 'The API server has a 99th percentile latency of {{ $value }} seconds for {{ $labels.verb }} {{ $labels.resource }}.',
            },
          },
          {
            alert: 'KubeAPILatencyHigh',
            expr: |||
              cluster_quantile:apiserver_request_duration_seconds:histogram_quantile{%(kubeApiserverSelector)s,quantile="0.99",subresource!="log",verb!~"^(?:LIST|WATCH|WATCHLIST|PROXY|CONNECT)$"} > %(kubeAPILatencyCriticalSeconds)s
            ||| % [config.selectors.kubeApiserverSelector, config.kubeAPILatency.CriticalSeconds],
            'for': '10m',
            labels: {
              severity: 'critical',
            },
            annotations: {
              message: 'The API server has a 99th percentile latency of {{ $value }} seconds for {{ $labels.verb }} {{ $labels.resource }}.',
            },
          },
          {
            alert: 'KubeAPIErrorsHigh',
            expr: |||
              sum(rate(apiserver_request_total{%(kubeApiserverSelector)s,code=~"^(?:5..)$"}[5m]))
                /
              sum(rate(apiserver_request_total{%(kubeApiserverSelector)s}[5m])) * 100 > 3
            ||| % config.selectors,
            'for': '10m',
            labels: {
              severity: 'critical',
            },
            annotations: {
              message: 'API server is returning errors for {{ $value }}% of requests.',
            },
          },
          {
            alert: 'KubeAPIErrorsHigh',
            expr: |||
              sum(rate(apiserver_request_total{%(kubeApiserverSelector)s,code=~"^(?:5..)$"}[5m]))
                /
              sum(rate(apiserver_request_total{%(kubeApiserverSelector)s}[5m])) * 100 > 1
            ||| % config.selectors,
            'for': '10m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: 'API server is returning errors for {{ $value }}% of requests.',
            },
          },
          {
            alert: 'KubeAPIErrorsHigh',
            expr: |||
              sum(rate(apiserver_request_total{%(kubeApiserverSelector)s,code=~"^(?:5..)$"}[5m])) by (resource,subresource,verb)
                /
              sum(rate(apiserver_request_total{%(kubeApiserverSelector)s}[5m])) by (resource,subresource,verb) * 100 > 10
            ||| % config.selectors,
            'for': '10m',
            labels: {
              severity: 'critical',
            },
            annotations: {
              message: 'API server is returning errors for {{ $value }}% of requests for {{ $labels.verb }} {{ $labels.resource }} {{ $labels.subresource }}.',
            },
          },
          {
            alert: 'KubeAPIErrorsHigh',
            expr: |||
              sum(rate(apiserver_request_total{%(kubeApiserverSelector)s,code=~"^(?:5..)$"}[5m])) by (resource,subresource,verb)
                /
              sum(rate(apiserver_request_total{%(kubeApiserverSelector)s}[5m])) by (resource,subresource,verb) * 100 > 5
            ||| % config.selectors,
            'for': '10m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: 'API server is returning errors for {{ $value }}% of requests for {{ $labels.verb }} {{ $labels.resource }} {{ $labels.subresource }}.',
            },
          },
          {
            alert: 'KubeClientCertificateExpiration',
            expr: |||
              apiserver_client_certificate_expiration_seconds_count{job="apiserver"} > 0 and histogram_quantile(0.01, sum by (job, le) (rate(apiserver_client_certificate_expiration_seconds_bucket{%(kubeApiserverSelector)s}[5m]))) < %(certExpiration.WarningSeconds)s
            ||| % [config.selectors.kubeApiserverSelector, config.certExpiration.WarningSeconds],
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: 'A client certificate used to authenticate to the apiserver is expiring in less than %s.' % (utils.humanizeSeconds(config.certExpiration.WarningSeconds)),
            },
          },
          {
            alert: 'KubeClientCertificateExpiration',
            expr: |||
              apiserver_client_certificate_expiration_seconds_count{job="apiserver"} > 0 and histogram_quantile(0.01, sum by (job, le) (rate(apiserver_client_certificate_expiration_seconds_bucket{%(kubeApiserverSelector)s}[5m]))) < %(certExpirationCriticalSeconds)s
            ||| % [config.selectors.kubeApiserverSelector, config.certExpiration.CriticalSeconds],
            labels: {
              severity: 'critical',
            },
            annotations: {
              message: 'A client certificate used to authenticate to the apiserver is expiring in less than %s.' % (utils.humanizeSeconds(config.certExpiration.CriticalSeconds)),
            },
          },
        ],
      }
