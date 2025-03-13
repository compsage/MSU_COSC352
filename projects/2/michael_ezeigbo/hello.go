package main

import (
	"fmt"
	"os"
	"strconv"
)

func main() {
	
	if len(os.Args) != 3 {
		fmt.Println("Usage: ./hello <name> <number>")
		return
	}

	
	name := os.Args[1]
	count, err := strconv.Atoi(os.Args[2])
	if err != nil {
		fmt.Println("Error: The number of greetings must be an integer.")
		return
	}


	if count <= 0 {
		fmt.Println("Error: The number of greetings must be a positive integer.")
		return
	}

	
	fmt.Printf("Starting to greet %s...\n", name)
	for i := 0; i < count; i++ {
		fmt.Printf("Hello %s!\n", name)
	}
	fmt.Printf("Greeting process completed for %s.\n", name)
}
