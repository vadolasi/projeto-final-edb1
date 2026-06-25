CORE=3
PERF_EVENTS=L1-dcache-loads,L1-dcache-load-misses,LLC-loads,LLC-load-misses
LOAD_FACTOR?=85

.PHONY: all build run-linear run-double clean

all: build

build:
	go build -o benchmark.executable ./main.go

run-linear: build
	sudo perf stat -e $(PERF_EVENTS) sudo nice -n -20 taskset -c $(CORE) ./benchmark.executable linear $(LOAD_FACTOR)

run-double: build
	sudo perf stat -e $(PERF_EVENTS) sudo nice -n -20 taskset -c $(CORE) ./benchmark.executable double $(LOAD_FACTOR)

clean:
	rm -f benchmark.executable


