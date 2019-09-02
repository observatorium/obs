# validator = import mixin.specValidation.libsonnet;
# # validator raises Assert if fail
# validator.check(manifest.config, manifest.config_spec)
{
local utils = self,
validateSpec(config, spec):: (
    # TODO: implement spec validation
    assert true: "Validation spec failed";
    true
),
validate_spec(config, spec):: (
    # TODO: implement spec validation
    assert true: "Validation spec failed";
    true
),
mergeDict(dep, field):: (
    {[field]: std.foldr(std.mergePatch,
            [dep[name][field] for name in std.objectFields(dep)
                              if std.objectHas(dep[name], "specs")], {})}
),

build(manifest, global_config, generate):: (
    # Generate the configuration from spec default, and merge with the global
    # configuration

     local specs =
    // # Merge dependencies specs
    if std.objectHasAll(manifest, 'dependencies')
    then
       utils.mergeDict(manifest.dependencies, "specs").specs
    else
        if std.objectHas(manifest, "specs") then manifest.specs else {};


    local resources =
    # Merge resources
    if std.objectHasAll(manifest, 'dependencies')
    then
       utils.mergeDict(manifest.dependencies, "resources").resources
    else
        if std.objectHas(manifest, "resources") then manifest.resources else {};

    # Create a default configuration from the var specs
    local vars = {
    [name]: specs[name].default
    for name in std.objectFields(specs) if std.objectHas(specs[name], "default")
    } + global_config;

    # Validate the configuration with the specs
    assert utils.validateSpec(vars, specs);

    local m = manifest + {config: vars, specs: specs, resources: resources,
         __render__+: {"alerts"+: {}, "dashboards"+: {}, "rules"+: {}}};

    if generate == "alerts"
    then
        [m.__render__[generate][name] for name in std.objectFields(m.__render__[generate])]
    else if generate == "dashboards" then
        [m.__render__[generate][name] for name in std.objectFields(m.__render__[generate])]
    else if generate == "rules" then
        [m.__render__[generate][name] for name in std.objectFields(m.__render__[generate])]
    else if generate == "all" then
        [m.__render__]
    else
        # Return the complete object
        m + {__render__:: super.__render__}
)

}