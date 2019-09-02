{
  rule: {
    type: 'string',
    default: 'kubernetes-system',
    required: true,
    description: 'The rule name',
  },

  certExpiration: {
    required: true,
    description: 'Configure the Warning and Critical certs expiration alerts in seconds',
    type: 'object',
    properties: {
      WarningSeconds: { type: 'integer' },
      CriticalSeconds: { type: 'integer' },
    },
    default: {
      WarningSeconds: 7 * 24 * 3600,
      CriticalSeconds: 1 * 24 * 3600,
    },

  },

  kubeAPILatency: {
      required: true,
      description: 'Alerts if the latency of the kube api master is too slow',
      type: 'object',
      properties: {
        WarningSeconds: {type: "integer"},
        CriticalSeconds: {type: "integer"},
      },
      default: {
        WarningSeconds: 1,
        CriticalSeconds: 4,
      }
  },

  kubeletPodLimit: {
      required: true,
      description: "Max pod per kubelet/node, alerts when reached",
      type: "integer",
      default:  110,
  },

  selectors: {
    required: true,
    description: 'List of the rules labels',
    type: 'object',
    properties: {
      kubeletSelector: { type: 'string' },
      kubeStateMetricsSelector: { type: 'string' },
      notKubeDnsSelector: { type: 'string' },
      kubeApiserverSelector: { type: 'string' },
    },
    default: {
      kubeletSelector: 'job="kubelet"',
      kubeStateMetricsSelector: 'job="kube-state-metrics"',
      notKubeDnsSelector: 'job!="kube-dns"',
      kubeApiserverSelector: 'job="kube-apiserver"',
    },
  },
}
