package main

import (
	"fmt"
	"math/rand"
	"os"
	"strconv"
	"time"
)

// TableSize: Tamanho da tabela (número primo).
const TableSize = 10000019

// Empty: Marcador de espaço vazio.
const Empty = -1

// HashTable: Vetor encapsulado para forçar contiguidade em memória.
type HashTable struct {
	data []int
}

// NewHashTable: Inicializa os índices com o marcador de espaço livre.
func NewHashTable() *HashTable {
	ht := &HashTable{
		data: make([]int, TableSize),
	}
	for i := range ht.data {
		ht.data[i] = Empty
	}
	return ht
}

// hash1: Função de espalhamento primária.
func hash1(key int) int {
	return key % TableSize
}

// hash2: Função de salto para dispersão dupla. Retorna valor coprimo e diferente de zero.
func hash2(key int) int {
	const R = 9999991
	return R - (key % R)
}

// InsertLinear: Executa a sondagem linear.
func (ht *HashTable) InsertLinear(key int) bool {
	idx := hash1(key)
	for i := 0; i < TableSize; i++ {
		pos := (idx + i) % TableSize
		if ht.data[pos] == Empty {
			ht.data[pos] = key
			return true
		}
	}
	return false
}

// InsertDouble: Executa a dispersão dupla.
func (ht *HashTable) InsertDouble(key int) bool {
	idx := hash1(key)
	step := hash2(key)
	for i := 0; i < TableSize; i++ {
		pos := (idx + (i * step)) % TableSize
		if ht.data[pos] == Empty {
			ht.data[pos] = key
			return true
		}
	}
	return false
}

func main() {
	method := os.Args[1]
	loadFactor, _ := strconv.Atoi(os.Args[2])

	numElements := (TableSize * loadFactor) / 100

	// Geração da carga prévia para não poluir o benchmark com o custo do gerador randômico.
	keys := make([]int, numElements)
	for i := 0; i < numElements; i++ {
		keys[i] = rand.Intn(1000000000)
	}

	ht := NewHashTable()

	if method == "linear" {
		fmt.Printf("[Sondagem Linear] Fator de Carga: %d%% | Inserindo %d chaves...\n", loadFactor, numElements)
		start := time.Now()
		for _, key := range keys {
			ht.InsertLinear(key)
		}
		duration := time.Since(start)
		fmt.Printf("[Sondagem Linear] Tempo de Execução: %v\n", duration)
	} else {
		fmt.Printf("[Dispersão Dupla] Fator de Carga: %d%% | Inserindo %d chaves...\n", loadFactor, numElements)
		start := time.Now()
		for _, key := range keys {
			ht.InsertDouble(key)
		}
		duration := time.Since(start)
		fmt.Printf("[Dispersão Dupla] Tempo de Execução: %v\n", duration)
	}
}
