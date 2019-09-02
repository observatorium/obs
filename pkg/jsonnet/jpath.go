package jsonnet

import (
	"errors"
	"io/ioutil"
	"os"
	"path/filepath"
)

var (
	// RootFileName is the default file name to find the root directory
	RootFileName = "main.jsonnet"

	// ErrorNoBase means no baseDir was found in the parents
	ErrorNoBase = errors.New("could not locate a " + RootFileName + " in the parent directories, which is required as the entrypoint for the evaluation")
)

// ErrorFileNotFound means that the searched file was not found
type ErrorFileNotFound struct {
	filename string
}

func (e ErrorFileNotFound) Error() string {
	return e.filename + " not found"
}

// Resolve the given directory and resolves the jPath around it. This means it:
// - figures out the project root (the one with RootFileName, vendor/ and lib/)
// - figures out the environments base directory (the one with the main.jsonnet)
//
// It then constructs a jPath with the base directory, vendor/ and lib/.
// This results in predictable imports, as it doesn't matter whether the user called
// called the command further down tree or not. A little bit like git.
func Resolve(workdir string) (path []string, root string, err error) {
	root, err = FindParentFile(RootFileName, workdir, "/")
	if err != nil {
		if _, ok := err.(ErrorFileNotFound); ok {
			return nil, "", ErrorNoBase
		}
		return nil, "", err
	}

	return []string{
		root,
		filepath.Join(root, "vendor"),
		filepath.Join(root, "lib"),
	}, root, nil
}

// FindParentFile traverses the parent directory tree for the given `file`,
// starting from `start` and ending in `stop`. If the file is not found an error is returned.
func FindParentFile(file, start, stop string) (string, error) {
	files, err := ioutil.ReadDir(start)
	if err != nil {
		return "", err
	}

	if dirContainsFile(files, file) {
		return start, nil
	} else if start == stop {
		return "", ErrorFileNotFound{file}
	}
	return FindParentFile(file, filepath.Dir(start), stop)
}

// dirContainsFile returns whether a file is included in a directory.
func dirContainsFile(files []os.FileInfo, filename string) bool {
	for _, f := range files {
		if f.Name() == filename {
			return true
		}
	}
	return false
}
