// Copyright 2018 mixtool authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"fmt"
	"os"

	"github.com/metalmatze/mixtool/pkg/mixer"
	"github.com/urfave/cli"
)

type lintConfig struct {
	Prometheus bool
	Grafana    bool
	Vendor     []string
}

func lintCommand() cli.Command {
	config := lintConfig{
		Prometheus: true,
		Grafana:    true,
	}

	return cli.Command{
		Name:        "lint",
		Usage:       "Lint jsonnet files",
		Description: "Lint jsonnet files for correct structure of JSON objects",
		Flags: []cli.Flag{
			cli.BoolTFlag{
				Name:        "grafana",
				Usage:       "Lint Grafana dashboards against Grafana's schema",
				Destination: &config.Grafana,
			},
			cli.BoolTFlag{
				Name:        "prometheus",
				Usage:       "Lint Prometheus alerts and rules and their given expressions",
				Destination: &config.Prometheus,
			},
			cli.StringSliceFlag{
				Name:  "vendor",
				Usage: "Add folders to be used as vendor folders",
			},
		},
		Action: lintAction(config),
	}
}
func lintAction(config lintConfig) cli.ActionFunc {
	return func(c *cli.Context) error {
		files := c.Args()

		vendors := c.StringSlice("vendor")

		for _, filename := range files {
			if err := mixer.Lint(os.Stdout, vendors, filename); err != nil {
				return fmt.Errorf("failed to lint the file %s: %v", filename, err)
			}
		}

		return nil
	}
}