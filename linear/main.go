package main

import (
	"fmt"
	"math/rand"
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

// hash1: Função primária.
func hash1(key int) int {
	return key % TableSize
}

// InsertLinear: Executa a sondagem linear buscando o próximo espaço adjacente.
// Alta eficiência de Cache L1 devido ao salto +1 contínuo.
func (ht *HashTable) InsertLinear(key int) bool {
	idx := hash1(key)
	for i := 0; i < TableSize; i++ {
		pos := (idx + i) % TableSize // Agrupamento primário intencional
		if ht.data[pos] == Empty {
			ht.data[pos] = key
			return true
		}
	}
	return false
}

func main() {
	// Cálculo do fator de carga utilizando aritmética inteira pura.
	numElements := (TableSize * 85) / 100

	// Geração da carga prévia para não poluir o benchmark com o custo do gerador randômico.
	keys := make([]int, numElements)
	for i := 0; i < numElements; i++ {
		keys[i] = rand.Intn(1000000000)
	}

	fmt.Printf("[Sondagem Linear] Iniciando inserção de %d chaves...\n", numElements)
	htLinear := NewHashTable()

	// Início do bloco cronometrado e alvo estrito da análise do 'perf'.
	start := time.Now()
	for _, key := range keys {
		htLinear.InsertLinear(key)
	}
	duration := time.Since(start)

	fmt.Printf("[Sondagem Linear] Tempo de Execução: %v\n", duration)
}
