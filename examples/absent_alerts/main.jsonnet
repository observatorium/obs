function(config={}, generate=null)

  local mixtool = import 'mixtool.libsonnet';

  local manifest = {
    local top = self,
    descriptor: import 'descriptor.libsonnet',
    specs: import 'spec.libsonnet',
    resources: {
      alerts: [
        {
          'kubernetes-absent': {
            src: 'templates/absent_alerts.libsonnet',
         },
        },
      ],
    },
    __render__: {
        alerts: {
            'kubernetes-absent': (import 'templates/absent_alerts.libsonnet')(top.config),
        }
    }
  };

mixtool.build(manifest, config, generate)
