# OBS package

Observatorium uses a packaging format called _obs_. A osb is a collection of files
that describe a related set of Monitoring resources. A single obs
might be used to deploy something simple, like a Mysql dashboard and alerts pod, or
something complex, composed from multiple dependent obs, for example the complete monitoring configuration of a Kubernetes cluster.


Obs are created as files laid out in a particular directory tree,
then they can be packaged into versioned archives to be shared.

## The OBS File Structure

A chart is organized as a collection of files inside of a directory.
The structure matches this:

```
postgres/
  main.yaml           # A YAML file containing information about the OBS
  LICENSE             # OPTIONAL: A plain text file containing the license for the chart
  README.md           # OPTIONAL: A human-readable README file
  specs.yaml          # The openAPIV3 schema for this package, describe templated value
  config.yaml         # OPTIONAL: a configuration file to override the default config values
  lib/jsonnnet        # A directory containing jsonnet librairies to be loaded
  vendor/jsonnet      # A directory containing any dependent jsonnet libraries
  vendor/obs          # A directory containing any dependent obs
  templates/          # OPTIONAL/CONVENTION A directory with the monitoring configuration templates

```

All yaml files, can also be written directly in jsonnet.

## The main.yaml File

The `main.yaml` file is required for a osb. It contains the following fields:

```yaml
# object containing package metadata
descriptor: # (required)
    name: name of the obs (required)
    description: A short description of this package (optional)
    # list of configuration categories included [dashboards, prometheus, alerts]
    types: # (optional)
      - dashboards
      - alerts
    keywords:
    - A list of keywords that identify the package. (optional)
    notes: Notes contain human readable snippets intended as a quick start for the users of the monitoring package. They may be plain text or <a href="spec.commonmark.org">CommonMark</a> markdown.
    # Links are a list of descriptive URLs intended to be used to surface additional documentation, dashboards, etc...
    links: # (optional)
    - name: Git Repo  (Link name/reference) (required for each link)
      url: https://github.com/observatorium/obs-postgresql (required for each link)
    # The obs package maintainers
    maintainers: # (optional)
      - name: The maintainer's name (required for each maintainer)
      email: The maintainer's email (optional for each maintainer)
      url: A URL for the maintainer (optional for each maintainer)

    # A list of icons for an application. Icon information includes the source, size, and mime type.
    icons: # (optional)
      - src: "https://example.com/wordpress.png" # (required)
        type: "image/png" # (required)
        size: "300x300" # (optional)

scrape_configs:
    postgres:
    wordpress:
        scrape_interval: 5m

config_schema:  object containing openapiV3 definitions of the available configuration. If not present, specs.yaml or specs.jsonnet is read. (optional)

config: Default values, config is checked against the defined schema.
If not present, reads "config.yaml" or "config.jsonnet", or generate the field from config_schema defaults values (optional)

config_generator: "Same as config, but instead of providing the value, its execute a promql query to get the value. Config_generator is then merged with config (optional)"
    $key: "PromQL query",
    $key: {$ubkey: "PromQL Query"},

# List of monitoring resources, grouped by type.
# Each resources is referenced by a name.
resources:
    dashboards:
        $name:
          schema: "One of the known schema ("grafana") or a url/path to the openapiv3 schema (json or yaml) (optional)"

          file: "path to the template or resource" (required)
          render: "the resource expanded, usually autogenerated field or in jsonnet to be used as:
           `object: (import 'templates/postgres-dash.libsonnet')(top.config)` (required / generated)"
          config: override value configured in the top level config field (optional)
          tpl: jsonnet
    alerts: # (optional)
        $name:
            schema: "prometheus_rules"
            file:
            template:
            object:
            config:

    rules: # (optional)
        $name:
            schema: "prometheus_rules"
    discovery: # (optional)
        $name:
            schema: scrape_config


# List of depedencies
dependencies:
 -  obs: Path/Url of the obs, format path: https://github.com/hashicorp go-getter#url-format
    config: true # uses the parent config values, if false uses the default values of the imported obs. When true, the imported obs config_schema is merged with the parent.
    resources: # Specific list of resources to import only
       dashboards:
         - $resource-name:

```

Other fields will be silently ignored.


## Variable config precedence

If multiple variables of the same name are defined in different places, they get overwritten in a certain order.

Here is the order of precedence from least to greatest (the last listed variables winning prioritization):

1. obs config_schema defaults
1. obs config_generator
1. obs resources individual config
1. obs config / config.yaml
1. parent config
1. parent individual dependency config
1. cli command line config

With dependents obs, the parent config is pushed as if it was a "config.yaml" (high priority) unless the field `parentConfig: false` is set.

## Dependencies

## Example