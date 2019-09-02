package jsonnet

import (
	"io/ioutil"
	"path/filepath"

	jsonnet "github.com/google/go-jsonnet"
)

// EvaluateFile opens the file, reads it into memory and evaluates it afterwards (`Evaluate()`)
func EvaluateFile(jsonnetFile string, jpath []string) (string, error) {
	bytes, err := ioutil.ReadFile(jsonnetFile)
	if err != nil {
		return "", err
	}
	root := filepath.Dir(jsonnetFile)
	jpath = append(jpath, root, filepath.Join(root, "vendor"),
		filepath.Join(root, "lib"), filepath.Join(root, "jsonnet"))
	return Evaluate(string(bytes), jsonnetFile, jpath)
}

// Evaluate renders the given jssonet into a string
func Evaluate(sonnet string, filename string, jpath []string) (string, error) {
	importer := jsonnet.FileImporter{
		JPaths: jpath,
	}

	vm := jsonnet.MakeVM()
	vm.Importer(&importer)
	for _, nf := range NativeFuncs() {
		vm.NativeFunction(nf)
	}

	return vm.EvaluateSnippet(filename, sonnet)
}
