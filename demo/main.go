package main

import (
	"context"
	"log"

	"github.com/darksidergod/githubfs-test"
	"github.com/google/go-github/github"
	"golang.org/x/oauth2"
)

func main() {
	githubToken := "8480ffea13811da3e717c2ff996e5c6c8c587c66"
	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: githubToken},
	)
	tc := oauth2.NewClient(ctx, ts)

	client := github.NewClient(tc)

	fs, err := githubfs.NewGithubfs(client, "darksidergod", "githubfs-test", "master")
	if err != nil {
		panic(err)
	}
	err = fs.MkdirAll("test/foo", 0700)
	if err != nil {
		log.Fatal("mkdir", err)
	}
	_, err = fs.Create("test/foo/bar")
	if err != nil {
		log.Fatal("create", err)
	}
	//info, _ := afero.ReadDir(fs, "/")
	//err = fs.Remove("/base.yaml")
	//data, _ := afero.ReadFile(fs, "/core.yaml")
	//os.Stdout.Write(data)
	//err = fs.RemoveAll("/channel-artifacts")
	//err = fs.Rename("/configtx.txt", "/configtx.yaml")
	//fmt.Printf("%# v", pretty.Formatter(err))
}
