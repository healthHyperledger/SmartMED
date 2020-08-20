package main

import (
	"context"
	"fmt"
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
	fmt.Println("Init executed")
	key := "patient"
	m[key] = "patient"
	return shim.Success([]byte("true"))
}

func (clientdid *mycc) Invoke(stub shim.ChaincodeStubInterface) peer.Response {

	funcName, args := stub.GetFunctionAndParameters()
	fmt.Println("Function=", funcName)

	if funcName == "read" {
		return clientdid.read(stub, args[0], args[1])

	} else if funcName == "write" {
		return clientdid.write(stub, args[0], args[1])
	}

	return shim.Error(("Bad Function Name = " + funcName + "!!!"))
}

func (clientdid *mycc) read(stub shim.ChaincodeStubInterface, patientID string, levelToRead string) peer.Response {
	githubToken := "GITHUB_TOKEN"
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
	path := m[patientID] + "/"
	path += levelToRead
	f, err := fs.Open(path)
	if err != nil {
		return shim.Error("failure")
	}
	fmt.Println(f)
	return shim.Success([]byte("Success."))
}

func (clientdid *mycc) write(stub shim.ChaincodeStubInterface, patientID string, levelToRead string) peer.Response {
	githubToken := "GITHUB_TOKEN"
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
	f, err := fs.OpenFile("EHR", os.O_APPEND, 0644)
	f.Write([]byte("Write operation to EHR.\n"))
	err = f.Close()
	if err != nil {
		return shim.Error("error")
	}

	return shim.Success([]byte("Success."))
}

// Chaincode registers with the Shim on startup
func main() {
	fmt.Printf("Started Chaincode.\n")
	err := shim.Start(new(mycc))
	if err != nil {
		fmt.Printf("Error starting chaincode: %s", err)
	}
}
