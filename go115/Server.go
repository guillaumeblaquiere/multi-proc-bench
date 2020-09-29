package main

import (
	"fmt"
	"go115/function"
	"log"
	"net/http"
	"os"
	"time"
)

func main() {
	before := time.Now()

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/fibonacci/", function.Fibonacci)
	http.HandleFunc("/", function.HelloWorld)

	after := time.Now()
	log.Printf("server started in %s", after.Sub(before))
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
}
