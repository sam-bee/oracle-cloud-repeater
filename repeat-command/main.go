package main

import (
	"flag"
	"fmt"
	"os/exec"
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
		cmd := exec.Command("sh", "-c", command)
		err := cmd.Run()
		if err == nil {
			fmt.Println("Command executed successfully")
			return
		}

		if time.Since(startTime).Seconds() > float64(timeout) {
			fmt.Println("Timeout reached. Command failed to execute successfully.")
			return
		}

		fmt.Printf("Command failed. Got %s. Retrying in %d seconds...\n", err, waitTime)
		time.Sleep(time.Duration(waitTime) * time.Second)
	}
}
