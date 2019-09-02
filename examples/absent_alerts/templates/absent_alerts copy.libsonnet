function(config={})

{
        name: config.ruleName,
        rules: [
          {
            alert: '%s' % config.alertName,
            expr: |||
              %s
            ||| % config.alertExpr,
            'for': '15m',
            labels: {
              severity: 'critical',
            },
            annotations: {
              message: 'Alert Description Message',
            },
          }
        ],
}


