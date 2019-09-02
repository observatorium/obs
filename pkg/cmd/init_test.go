package cmd

import (
	"testing"
)

func TestInitMain(t *testing.T) {
	t.Log(initMainJsonnet(InitCmdOpts{Name: "foo"}))
}

func TestInitSpecs(t *testing.T) {
	t.Log(initSpecsJsonnet(InitCmdOpts{Name: "foo"}))
}

func TestInitDescriptor(t *testing.T) {
	out, _ := initDescriptorYaml(InitCmdOpts{Name: "foo"})
	t.Log(out)
}

func TestInitDescriptorJsonnet(t *testing.T) {
	out, _ := initDescriptorJsonnet(InitCmdOpts{Name: "foo"})
	t.Log(out)
}

func TestInitFunc(t *testing.T) {
	InitCmdFunc(InitCmdOpts{Name: "Bla", Dir: "/tmp/g/a", Force: true})
}
