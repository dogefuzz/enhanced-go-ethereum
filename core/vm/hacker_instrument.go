package vm

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
)

type InstrumentRequest struct {
	Address      string   `json:"address"`
	Input        string   `json:"input"`
	TxHash       string   `json:"txHash"`
	Instructions []uint64 `json:"instructions"`
}

type ExecutionRegistry interface {
	Register(pc uint64)
	SendRegistriesToFuzzer()
}

type executionRegistry struct {
	address      string
	input        string
	txHash       string
	instructions []uint64
}

func GetRegistryInstance(contractAddress string, input string, txHash string) *executionRegistry {
	return &executionRegistry{
		address:      contractAddress,
		input:        input,
		txHash:       txHash,
		instructions: make([]uint64, 0, 3),
	}
}

func (r *executionRegistry) Register(pc uint64) {
	r.instructions = append(r.instructions, pc)
}

func (r *executionRegistry) SendRegistriesToFuzzer() {
	fuzzerHost := os.Getenv("FUZZER_HOST")
	if fuzzerHost == "" {
		fuzzerHost = "localhost"
	}
	fuzzerPort := os.Getenv("FUZZER_PORT")
	if fuzzerPort == "" {
		fuzzerPort = "8888"
	}

	url := fmt.Sprintf("http://%s:%s/transactions/executions", fuzzerHost, fuzzerPort)
	request := InstrumentRequest{
		Address:      r.address,
		Input:        r.input,
		TxHash:       r.txHash,
		Instructions: r.instructions,
	}
	data, err := json.Marshal(request)
	if err != nil {
		log.Printf("Error Occurred. %+v", err)
		return
	}
	res, err := http.Post(url, "application/json", bytes.NewBuffer(data))
	if err != nil {
		log.Printf("Error Occurred. %+v", err)
		return
	}
	defer res.Body.Close()
	log.Printf("Sending execution log: %s", res.Status)
}
