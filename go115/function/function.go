package function

import (
	"fmt"
	"log"
	"net/http"
	"strconv"
	"time"
)

type Entity struct {
	Test2 int
}

var inProgress bool

func HelloWorld(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "Hello World!\n")
}

func Fibonacci(w http.ResponseWriter, r *http.Request) {
	var n int64 = 30
	param := r.URL.Query().Get("n")
	if p, err := strconv.Atoi(param); err == nil {
		n = int64(p)
	}
	before := time.Now()
	result := fibo(n)
	after := time.Now()

	ret := fmt.Sprintf("Fibonacci(%d) = %d found in %s \n", n, result, after.Sub(before))
	log.Printf(ret)
	fmt.Fprintf(w, ret)
}

func fibo(n int64) int64 {
	if n <= 2 {
		return n - 1
	} else {
		return fibo(n-1) + fibo(n-2)
	}
}
