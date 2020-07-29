package main

import (
	"context"
	"fmt"

	"github.com/darksidergod/githubfs-test"
	"github.com/google/go-github/github"
	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-protos-go/peer"
	"golang.org/x/oauth2"
)

type mycc struct{}

func (clientdid *mycc) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
	// Get the function name and parameters
	funcName, args := stub.GetFunctionAndParameters()

	// Just to satisfy the compiler - otherwise it will complain that args declared but not used
	fmt.Println(len(args))

	if funcName == "read" {
		return peer.Response{}
	} else if funcName == "ApproveRead" {
		return peer.Response{}
	}

	return shim.Error("Bad Func Name!!!")
}

func (clientdid *mycc) read()
func main() {
	githubToken := "cadc9fbea35ff429ccbe646016c9a87412e88550"
	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: githubToken},
	)
	tc := oauth2.NewClient(ctx, ts)

	client := github.NewClient(tc)

	fs, err := githubfs.NewGithubfs(client, "darksidergod", "recordStorage", "master")
	if err != nil {
		panic(err)
	}
	fs.MkdirAll("test/foo/bar", 0040000)
	//	f, err := fs.OpenFile("test/dark", os.O_APPEND, 0644)
	//	if err != nil {
	//		log.Fatal(err)
	//}

	//f.Write([]byte("Hello World."))
	//err = f.Close()
	//if err != nil {
	//	log.Fatal(err)
	//}
	//fmt.Printf("%# v", pretty.Formatter(fs))
}
