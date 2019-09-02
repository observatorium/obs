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
	cmd "github.com/monitoring-mixins/mixtool/pkg/cmd"
	"gopkg.in/alecthomas/kingpin.v2"
	"os"
)

// Version of the mixtool.
// This is overridden at compile time.
var version = "0.1.0"

type initCmdKingPin struct {
	cmd.InitCmdOpts
}

func (opts *initCmdKingPin) run(c *kingpin.ParseContext) error {
	return cmd.InitCmdFunc(opts.InitCmdOpts)
}

func configureInitCommand(app *kingpin.Application) {
	initopts := &initCmdKingPin{}
	initcmd := app.Command("init", "Initialize a new package directory").Action(initopts.run)
	initcmd.Flag("force", "overwrite existing files").Short('f').Default("false").BoolVar(&initopts.Force)
	initcmd.Flag("dest", "directory path to create").Short('d').Default(".").StringVar(&initopts.Dir)

}

func main() {
	app := kingpin.New("mixtool", "Monitoring packages cli")
	app.Author("Antoine Legrand<alegrand@redhat.com>, Matthias Loibl<mloibl@redhat.com>")
	app.Version(version)
	configureInitCommand(app)
	kingpin.MustParse(app.Parse(os.Args[1:]))
}
