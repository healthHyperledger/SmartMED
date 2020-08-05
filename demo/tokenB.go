package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/darksidergod/githubfs-test"
	"github.com/google/go-github/github"
	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-protos-go/peer"
	"golang.org/x/oauth2"
)

type mycc struct{}

var m map[string]string

// Init Implements the Init method
func (token *mycc) Init(stub shim.ChaincodeStubInterface) peer.Response {

	// Simply print a message
	fmt.Println("Init executed")

	return shim.Success([]byte("true"))
}

func (clientdid *mycc) read(stub shim.ChaincodeStubInterface, patientID string, levelToRead string) peer.Response {
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
	path := m[patientID]
	path += levelToRead
	f, err := fs.Open(path)
	if err != nil {
		return shim.Error("failure")
	}
	fmt.Println(f)
	return shim.Success([]byte("Success."))
}

func (clientdid *mycc) write(stub shim.ChaincodeStubInterface, patientID string, levelToRead string) peer.Response {
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
	f.Write([]byte("Hello World."))
	err = f.Close()
	if err != nil {
		return shim.Error("error")
	}

	return shim.Success([]byte("Success."))
}

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
