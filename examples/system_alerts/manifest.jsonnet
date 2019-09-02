local u = import "mixtool.libsonnet";
function(config={}, generate=true)

local manifest = {
    local top = self,

    descriptor: {
        name: "kubernetes-absent-alerts",
        description: "Creates alerts if a component is not Present.
                      List all labels selectors in the 'jobs' variable ",
        type: "alerts"
    },
    specs: import "spec.libsonnet",
    resources: {
        "kubernetes-system": (import "template/system_alerts.libsonnet")(top.config)
    },
};

u.build(manifest, config, generate)

