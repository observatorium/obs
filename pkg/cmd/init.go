package cmd

import (
	"bytes"
	"io/ioutil"
	"log"
	"os"
	"path"
	"text/template"
)

// InitCmdOpts is the options passed by the commandline to the init function
type InitCmdOpts struct {
	Force bool
	Name  string
	Dir   string
}

const (
	specsjsonnet = `
	{
	//   $varname: {
	//     type: 'string',
	//     default: 'the-default-value',
	//     required: true,
	//     description: 'insert description',
  		},
	}
	`

	descriptoryaml = `---
name: {{.Name}}
description: |
        Long Description
icons:
- size: 300x300
  src: # https://....
  type: image/png
types:
 - alerts
# - dashboards
keywords:
- rules
- dashboards
- prometheus
links:
- name: GitRepo
  url: https://github.com/....
maintainers:
- emails:
  name:
`

	descriptorjsonnet = `
{
      name: '{{.Name}}',

	  description: "Long description",

	  types: [
		'alerts',
		'dashboards',
	  ],

      keywords: [
        'kubernetes',
        'kube-system',
        'alerts',
	  ],

      links: [
        {
          name: 'GitRepo',
          url: 'https://github.com/...',
		},
	  ],

      maintainers: [
        {
          name: 'ant31',
          emails: 'alegrand@redhat.com',
        },
	  ],

      icons: [
        {
          src: 'https://example.com/my-image.png',
          type: 'image/png',
          size: '300x300',
        },
      ]
}
`

	mainjsonnet = `
  local mixtool = import 'mixtool.libsonnet';

  local manifest = {
    local top = self,
    descriptor: import 'descriptor.libsonnet',
    specs: import 'spec.libsonnet',
    resources: {
      rules: [
        // {
        //   '$ruleName1': {
        //     src: 'templates/$ruleName1.libsonnet',
        //  },
        // },
	  ]
	  dashboards: [],
    },
    __render__: {
        rules: {
          // '$ruleName1': (import 'templates/$ruleName1.libsonnet')(top.config),
		},
		dashboards: {}

    }
  };

  mixtool.build(manifest, config, generate)
`
)

func executeTpl(opts InitCmdOpts, name string, tpl string) (string, error) {
	var out bytes.Buffer
	parsed := template.Must(template.New(name).Parse(tpl))
	err := parsed.Execute(&out, opts)
	if err != nil {
		return "", err
	}
	return out.String(), nil
}

func initMainJsonnet(opts InitCmdOpts) (string, error) {
	return executeTpl(opts, "main", mainjsonnet)
}

func initSpecsJsonnet(opts InitCmdOpts) (string, error) {
	return executeTpl(opts, "specs", specsjsonnet)
}

func initDescriptorYaml(opts InitCmdOpts) (string, error) {
	return executeTpl(opts, "descriptor", descriptoryaml)
}

func initDescriptorJsonnet(opts InitCmdOpts) (string, error) {
	return executeTpl(opts, "descriptorjsonnet", descriptorjsonnet)
}

// InitCmdFunc creates a new application
func InitCmdFunc(opts InitCmdOpts) error {
	if err := os.MkdirAll(opts.Dir, os.ModePerm); err != nil {
		log.Fatalf("Error creating `%s` folder:%s\n", opts.Dir, err)
	}

	files, err := ioutil.ReadDir(opts.Dir)
	if err != nil {
		log.Fatalln("Error listing files:", err)
	}

	if len(files) > 0 && !opts.Force {
		log.Fatalln("Error: directory not empty. Use `-f` to force")
	}

	if err := writeNewFile(path.Join(opts.Dir, "jsonnetfile.json"), "{}"); err != nil {
		log.Fatalln("Error creating `jsonnetfile.json`:", err)
	}

	if err := os.MkdirAll(path.Join(opts.Dir, "vendor"), os.ModePerm); err != nil {
		log.Fatalln("Error creating `vendor/` folder:", err)
	}

	if err := os.MkdirAll(path.Join(opts.Dir, "templates"), os.ModePerm); err != nil {
		log.Fatalln("Error creating `templates/` folder:", err)
	}

	if err := os.MkdirAll(path.Join(opts.Dir, "lib"), os.ModePerm); err != nil {
		log.Fatalln("Error creating `lib/` folder:", err)
	}

	out, err := initMainJsonnet(opts)
	if err != nil {
		log.Fatalln("Error loading `main.jsonnet` template:", err)
	}

	if err := writeNewFile(path.Join(opts.Dir, "main.jsonnet"), out); err != nil {
		log.Fatalln("Error creating `main.jsonnet`:", err)
	}
	return err
}

// writeNewFile writes the content to a file if it does not exist
func writeNewFile(name, content string) error {
	if _, err := os.Stat(name); os.IsNotExist(err) {
		return ioutil.WriteFile(name, []byte(content), 0644)
	}
	return nil
}
