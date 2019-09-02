{
        descriptor: {
        name: "kubernetes-absent-alerts",
        description: "Creates alerts if a component is not Present.
                      List all labels selectors in the 'jobs' variable ",
        type: "alerts"
    },
    specs: [
       "specs.libsonnet"
    ],
    resources: {
        alerts: {
            "kubernetes-system": "template/system_alerts.libsonnet"
        }

    },
}


