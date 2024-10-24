package main

import (
	"bytes"
	"flag"
	"fmt"
	"os/exec"
	"strings"
	"time"
)

func main() {
	var waitTime int
	var timeout int
	var command string

	flag.IntVar(&waitTime, "wait", 30, "Wait time between retries in seconds")
	flag.IntVar(&timeout, "timeout", 14400, "Total timeout in seconds")
	flag.StringVar(&command, "command", "", "CLI command to execute")
	flag.Parse()

	if command == "" {
		fmt.Println("Please provide a command to execute using the -command flag")
		return
	}

	startTime := time.Now()
	for {
		// Run command
		var stdout, stderr bytes.Buffer
		cmd := exec.Command("sh", "-c", command)
		err := cmd.Run()
		cmd.Stdout = &stdout
		cmd.Stderr = &stderr
		if err == nil {
			fmt.Println("Command executed successfully")
			return
		}

		if time.Since(startTime).Seconds() > float64(timeout) {
			fmt.Println("Timeout reached. Command failed to execute successfully.")
			return
		}

		// Check whether the stderr contained the string "500-InternalError, Out of host capacity."

		if err != nil && strings.Contains(string(stderr.String()), "500-InternalError, Out of host capacity.") {
			fmt.Printf("%s Command failed: 'Out of host capacity'.Retrying in %d seconds...\n", time.Now().String(), waitTime)
		} else {
			fmt.Println("Command failed due to other reasons. Exiting...")
			fmt.Println(stderr.String())
			return
		}

		fmt.Printf("Command failed. Got %s. Retrying in %d seconds...\n", err, waitTime)
		time.Sleep(time.Duration(waitTime) * time.Second)
	}
}
