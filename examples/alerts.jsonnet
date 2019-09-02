local u = import ".mixtool.libsonnet";
function(config={}, generate=true)

local manifest = {
    local top = self,

    descriptor: {
        name: "Kubernetes all systems alerts",
        description: "Complete list of alerts to monitor a vanilla kubernetes cluster ",
        type: "alerts",
    },
    config:
     {
          rule: "all",
     }
    dependencies:: {
      "absent_alerts":
         pkg:  "absent_alerts/manifest.jsonnet"
         config:
           rule: "absent"
      "system_alerts": (import "system_alerts/manifest.jsonnet")(config, false)

    },


};

u.build(manifest, config, generate)
