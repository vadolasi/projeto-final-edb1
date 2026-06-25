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

// HashTable: Vetor encapsulado.
type HashTable struct {
	data []int
}

// NewHashTable: Inicializa índices com marcador vazio.
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

// hash2: Função de salto. Retorna valor coprimo e estritamente diferente de zero.
func hash2(key int) int {
	const R = 9999991
	return R - (key % R)
}

// InsertDouble: Executa a dispersão dupla. O salto depende do valor da chave,
// o que força saltos aleatórios no vetor e invalida blocos de Cache L1.
func (ht *HashTable) InsertDouble(key int) bool {
	idx := hash1(key)
	step := hash2(key)
	for i := 0; i < TableSize; i++ {
		pos := (idx + (i * step)) % TableSize // Salto quebra a localidade de referência
		if ht.data[pos] == Empty {
			ht.data[pos] = key
			return true
		}
	}
	return false
}

func main() {
	// Cálculo do fator de carga com aritmética inteira.
	numElements := (TableSize * 85) / 100

	// Geração antecipada de chaves.
	keys := make([]int, numElements)
	for i := 0; i < numElements; i++ {
		keys[i] = rand.Intn(1000000000)
	}

	fmt.Printf("[Dispersão Dupla] Iniciando inserção de %d chaves...\n", numElements)
	htDouble := NewHashTable()

	// Início da medição de tempo e zona estrita de estresse de hardware.
	start := time.Now()
	for _, key := range keys {
		htDouble.InsertDouble(key)
	}
	duration := time.Since(start)

	fmt.Printf("[Dispersão Dupla] Tempo de Execução: %v\n", duration)
}
