# validator = import mixin.specValidation.libsonnet;
# # validator raises Assert if fail
# validator.check(manifest.config, manifest.config_spec)
{
local utils = self,
validate_spec(config, spec):: (
    # TODO: implement spec validation
    assert true: "Validation spec failed";
    true
),

build(manifest, global_config, generate):: (
    # Generate the configuration from spec default, and merge with the global
    # configuration
    local vars = {config: {
    [name]: manifest.specs[name].default
    for name in std.objectFields(manifest.specs) if std.objectHas(manifest.specs[name], "default")
    } + global_config};

    # Validate the configuration with the specs
    assert utils.validate_spec(vars, manifest.specs);
    local m = manifest + vars;
    if generate == true
    then
        [m.resources[name] for name in std.objectFields(m.resources)]
    else
        m
)

}