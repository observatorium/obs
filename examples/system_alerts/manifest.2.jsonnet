local u = import "mixtool.libsonnet";
function(config={}, generate=true)

local manifest = std.native(importYaml, "manifest.yaml")
local m = {
    local top = self,

    descriptor: manifest.descriptor
    specs:
        std.native("import"import "spec.libsonnet",
    resources: {
        "kubernetes-system": (import "template/system_alerts.libsonnet")(top.config)
    },
};

u.build(manifest, config, generate)

