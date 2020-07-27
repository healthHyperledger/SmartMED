package main

import (
	"context"
	"log"
	"os"

	"github.com/darksidergod/githubfs-test"
	"github.com/google/go-github/github"
	"golang.org/x/oauth2"
)

func main() {
	githubToken := "5a55cf8ede14add10195364f3daf62e8e9944ba5"
	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: githubToken},
	)
	tc := oauth2.NewClient(ctx, ts)

	client := github.NewClient(tc)

	fs, err := githubfs.NewGithubfs(client, "darksidergod", "Security-Utils.", "master")
	if err != nil {
		panic(err)
	}

	f, err := fs.OpenFile("dark", os.O_APPEND, 0644)
	if err != nil {
		log.Fatal(err)
	}

	f.Write([]byte("Hello World."))
	err = f.Close()
	if err != nil {
		log.Fatal(err)
	}
	//fmt.Printf("%# v", pretty.Formatter(fs))
}
