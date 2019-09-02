{
  rule: {
    type: 'string',
    default: 'kubernetes-absent',
    required: true,
    description: 'The rule name',
  },
  jobs: {
    required: true,
    description: 'List of the components labels to watch',
    type: 'object',
    additionalProperties: {
      type: 'string',
    },
    default: {
      KubeAPI: 'job="kube-apiserver"',
      KubeControllerManager: 'job="kube-controller-manager"',
      KubeScheduler: 'job="kube-scheduler"',
      Kubelet: 'job="kubelet"',
    },
  },
}
