package main

// 52.44
import (
	"context"
	"encoding/base64"
	"fmt"
	"os"
	"path"
	"strings"
	"sync"
	"time"

	"github.com/google/go-github/github"
	"github.com/kr/pretty"
	"github.com/spf13/afero"
	"github.com/spf13/afero/mem"
	"golang.org/x/oauth2"
)

// 1.33
const commitMessage string = "automatic commit"

type githubDir struct {
	tree *github.Tree
	mem.DirMap
}

//func (d *githubDir) Len() int
//func (d *githubDir) Names() []string
//func (d *githubDir) Files() []*mem.FileData
//func (d *githubDir) Add(*mem.FileData)
//func (d *githubDir) Remove(*mem.FileData)
const commitmsg string = "auto commit from git"

type githubFs struct {
	client *github.Client
	user   string
	repo   string
	branch string
	tree   *github.Tree
	mu     sync.Mutex
}

func convstring(s string) *string {
	return &s
}
func createFile(name string) *mem.File {
	fileData := mem.CreateFile(name)
	file := mem.NewFileHandle(fileData)
	return file
}

func newGithubfs(client *github.Client, user string, repo string, branch string) (afero.Fs, error) {
	ghfs := &githubFs{
		client: client,
		user:   user,
		repo:   repo,
		branch: branch,
	}
	ctx := context.Background()
	b, _, err := client.Repositories.GetBranch(ctx, user, repo, branch)
	if err != nil {
		return nil, err
	}
	treeHash := b.Commit.Commit.Tree.GetSHA()
	ghfs.tree, _, _ = client.Git.GetTree(ctx, user, repo, treeHash, true)
	if err != nil {
		return nil, err
	}

	return ghfs, nil
}

func (fs *githubFs) updateTree(sha string) (err error) {
	_, _, err = fs.client.Git.GetTree(context.TODO(), fs.user, fs.repo, sha, true)
	return err
}

// Open opens a file, returning it or an error, if any happens.
func (fs *githubFs) Open(name string) (afero.File, error) {
	normalName := strings.TrimPrefix(name, "/")
	entry := fs.findEntry(name)

	for _, e := range fs.tree.Entries {
		if e.GetPath() == normalName {
			entry = e
			break
		}
	}
	if entry == nil {
		return nil, afero.ErrFileNotFound
	}
	if entry.GetType() == "blob" {
		fd := mem.CreateFile(normalName)
		mem.SetMode(fd, os.FileMode(int(0644)))
		f := mem.NewFileHandle(fd)
		blob, _, err := fs.client.Git.GetBlob(context.TODO(), fs.user, fs.repo, entry.GetSHA())
		if err != nil {
			return nil, err
		}
		b, _ := base64.StdEncoding.DecodeString(blob.GetContent())
		f.Write(b)
		f.Seek(0, 0)
		return f, nil
	}

	dir := mem.CreateDir(name)
	if normalName == "" {
		normalName = "."
	}
	for _, e := range fs.tree.Entries {
		if path.Dir(e.GetPath()) != normalName {
			continue
		}
		normalName := strings.TrimPrefix(e.GetPath(), path.Dir(e.GetPath())+"/")
		switch e.GetType() {
		case "blob":
			f := mem.CreateFile(normalName)
			mem.SetMode(f, os.FileMode(int(0644)))
			mem.AddToMemDir(dir, f)

		case "tree":
			d := mem.CreateDir(normalName)
			mem.SetMode(d, os.FileMode(int(040000)))
			mem.AddToMemDir(dir, d)
		default:
			continue
		}
	}

	return mem.NewFileHandle(dir), nil
}
func (fs *githubFs) Remove(name string) error {
	fs.mu.Lock()
	defer fs.mu.Unlock()
	return fs.remove(name)
}

// Remove removes a file identified by name, returning an error, if any
// happens.
func (fs *githubFs) remove(name string) error {
	normalName := strings.TrimPrefix(name, "/")
	entry := fs.findEntry(name)
	if entry == nil {
		return afero.ErrFileNotFound
	}
	resp, _, err := fs.client.Repositories.DeleteFile(context.TODO(), fs.user, fs.repo, normalName, &github.RepositoryContentFileOptions{
		Message: convstring(commitMessage),
		SHA:     convstring(entry.GetSHA()),
		Branch:  convstring(fs.branch),
	})
	if err != nil {
		return err
	}

	return fs.updateTree(resp.Tree.GetSHA())
}

// RemoveAll removes a directory path and any children it contains. It
// does not fail if the path does not exist (return nil).
func (fs *githubFs) RemoveAll(path string) error {
	fs.mu.Lock()
	defer fs.mu.Unlock()
	normalName := strings.TrimSuffix(strings.TrimPrefix(path, "/"), "/")
	entry := fs.findEntry(path)
	if entry == nil {
		return afero.ErrFileNotFound
	}
	if entry.GetType() == "blob" {
		return fs.Remove(path)
	}

	for _, e := range fs.tree.Entries {
		if e.GetType() == "tree" {
			continue
		}
		if strings.HasPrefix(e.GetPath(), normalName+"/") {
			err := fs.remove(e.GetPath())
			if err != nil {
				return err
			}
		}
	}
	return nil
}

func (fs *githubFs) Create(name string) (afero.File, error) {
	return createFile(name), nil
}

// Mkdir creates a directory in the filesystem, return an error if any
// happens.
func (fs *githubFs) Mkdir(name string, perm os.FileMode) error {
	dir := mem.CreateDir(name)
	mem.SetMode(dir, perm)
	return nil
}

// MkdirAll creates a directory path and all parents that does not exist
// yet.
func (fs *githubFs) MkdirAll(path string, perm os.FileMode) error {
	return nil

}

func (fs *githubFs) findEntry(name string) *github.TreeEntry {
	normalName := strings.TrimPrefix(name, "/")
	for _, e := range fs.tree.Entries {
		if e.GetPath() == normalName {
			return e
		}
	}
	return nil
}

// OpenFile opens a file using the given flags and the given mode.
func (fs *githubFs) OpenFile(name string, flag int, perm os.FileMode) (afero.File, error) {
	return nil, nil
}

// Rename renames a file.
func (fs *githubFs) Rename(oldname, newname string) error {
	fs.mu.Lock()
	defer fs.mu.Unlock()
	normalOld := strings.TrimPrefix(oldname, "/")
	normalNew := strings.TrimPrefix(newname, "/")
	b, _, err := fs.client.Repositories.GetBranch(context.TODO(), fs.user, fs.repo, fs.branch)
	if err != nil {
		return err
	}
	err = fs.updateTree(b.Commit.Commit.Tree.GetSHA())
	if err != nil {
		return err
	}
	var entries []*github.TreeEntry
	for _, e := range fs.tree.Entries {
		if e.GetPath() == normalOld {
			e.Path = convstring(normalNew)
		}
		e.Content = nil
		e.URL = nil
		e.Size = nil
		entries = append(entries, e)
	}
	tree, _, err := fs.client.Git.CreateTree(context.TODO(), fs.user, fs.repo, fs.tree.GetSHA(), entries)
	err = fs.updateTree(tree.GetSHA())
	if err != nil {
		return err
	}

	commit, _, err := fs.client.Git.CreateCommit(context.TODO(), fs.user, fs.repo, &github.Commit{
		Message: convstring(commitmsg),
		Tree:    tree,
		Parents: []*github.Commit{{SHA: b.GetCommit().SHA}},
	})
	_, _, err = fs.client.Git.UpdateRef(context.TODO(), fs.user, fs.repo, &github.Reference{
		Ref: convstring("heads/" + b.GetName()),
		Object: &github.GitObject{
			SHA: commit.SHA,
		},
	}, false)
	return nil
}

// Stat returns a FileInfo describing the named file, or an error, if any
// happens.
func (fs *githubFs) Stat(name string) (os.FileInfo, error) {
	f, err := fs.Open(name)
	if err != nil {
		return nil, err
	}
	return f.Stat()
}

// The name of this FileSystem
func (fs *githubFs) Name() string {
	return "github"
}

//Chmod changes the mode of the named file to mode.
func (fs *githubFs) Chmod(name string, mode os.FileMode) error {
	return nil
}

//Chtimes changes the access and modification times of the named file
func (fs *githubFs) Chtimes(name string, atime time.Time, mtime time.Time) error {
	return nil
}

func main() {
	githubToken := "9a7f5b5818d0dc4a0a0c5de616caa0984c61ef76"
	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: githubToken},
	)
	tc := oauth2.NewClient(ctx, ts)

	client := github.NewClient(tc)

	fs, err := newGithubfs(client, "darksidergod", "githubfs-test", "master")
	if err != nil {
		panic(err)
	}
	//info, _ := afero.ReadDir(fs, "/")
	//err = fs.Remove("/base.yaml")
	//data, _ := afero.ReadFile(fs, "/core.yaml")
	//os.Stdout.Write(data)
	//err = fs.RemoveAll("/channel-artifacts")
	err = fs.Rename("/configtx.yaml", "/configtx.txt")
	fmt.Printf("%# v", pretty.Formatter(err))
}
