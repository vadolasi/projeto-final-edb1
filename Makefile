CORE=3
PERF_EVENTS=L1-dcache-loads,L1-dcache-load-misses,LLC-loads,LLC-load-misses

.PHONY: all build run-linear run-double clean

all: build

build:
	go build -o linear.executable ./linear/main.go
	go build -o double.executable ./double/main.go

run-linear: build
	sudo perf stat -e $(PERF_EVENTS) sudo nice -n -20 taskset -c $(CORE) ./linear.executable

run-double: build
	sudo perf stat -e $(PERF_EVENTS) sudo nice -n -20 taskset -c $(CORE) ./double.executable

clean:
	rm -f *.executable
