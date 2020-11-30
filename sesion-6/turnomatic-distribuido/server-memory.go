package main

import (
	"fmt"
	"log"
	"net/http"
	"sync/atomic"
	"time"

	"github.com/gorilla/mux"
)

var globalCounter *int64 = new(int64)

func main() {
	r := mux.NewRouter()
	r.HandleFunc("/turno/{key}", turnomatic)
	srv := &http.Server{
		Handler:      r,
		Addr:         ":7017",
		WriteTimeout: 15 * time.Second,
		ReadTimeout:  15 * time.Second,
	}
	log.Println("Listening on http://127.0.0.7017")
	log.Fatal(srv.ListenAndServe())

}
func turnomatic(w http.ResponseWriter, r *http.Request) {
	currentCount := atomic.AddInt64(globalCounter, 1)
	params := mux.Vars(r)
	fmt.Fprintf(w, "{'id': '%s', 'result': %d}", params["key"], currentCount)
}
