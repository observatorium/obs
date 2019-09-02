function(config={})

{
        name: config.rule,
        rules: [
          {
            alert: '%sDown' % name,
            expr: |||
              absent(up{%s} == 1)
            ||| % config.jobs[name],
            'for': '15m',
            labels: {
              severity: 'critical',
            },
            annotations: {
              message: '%s has disappeared from Prometheus target discovery.' % name,
            },
          }
          for name in std.objectFields(config.jobs)
        ],
}


