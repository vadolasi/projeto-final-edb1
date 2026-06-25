# Benchmark: Sondagem Linear vs. Dispersão Dupla

## Ambiente de Execução
* **Processador:** 11th Gen Intel(R) Core(TM) i5-1135G7 @ 2.40GHz
* **Memória RAM:** 16 GB (DDR4)
* **Sistema Operacional:** CachyOS Linux (Base Arch Linux)
* **Kernel Linux:** 7.0.12-1-cachyos
* **Go:** go1.26.2 linux/amd64

## Como Executar

```bash
make run-linear LOAD_FACTOR=50
make run-double LOAD_FACTOR=50

make run-linear LOAD_FACTOR=85
make run-double LOAD_FACTOR=85
```

Para limpar os executáveis:
```bash
make clean
```

## Resultados Obtidos

### Fator de Carga: 50%

#### Sondagem Linear
```text
[Sondagem Linear] Fator de Carga: 50% | Inserindo 5000009 chaves...
[Sondagem Linear] Tempo de Execução: 163.754829ms

 Performance counter stats for 'taskset -c 3 ./benchmark.executable linear 50':

       224.164.179      L1-dcache-loads:u                                                     
        14.153.447      L1-dcache-load-misses:u                                               
         4.973.039      LLC-loads:u                                                           
         4.515.051      LLC-load-misses:u                                                     

       0,277821563 seconds time elapsed
```

#### Dispersão Dupla
```text
[Dispersão Dupla] Fator de Carga: 50% | Inserindo 5000009 chaves...
[Dispersão Dupla] Tempo de Execução: 278.923588ms

 Performance counter stats for 'taskset -c 3 ./benchmark.executable double 50':

       226.247.448      L1-dcache-loads:u                                                     
        18.127.846      L1-dcache-load-misses:u                                               
         7.621.271      LLC-loads:u                                                           
         7.151.752      LLC-load-misses:u                                                     

       0,384940650 seconds time elapsed
```

### Fator de Carga: 85%

#### Sondagem Linear
```text
[Sondagem Linear] Fator de Carga: 85% | Inserindo 8500016 chaves...
[Sondagem Linear] Tempo de Execução: 545.860417ms

 Performance counter stats for 'taskset -c 3 ./benchmark.executable linear 85':

       409.204.513      L1-dcache-loads:u                                                     
        29.875.534      L1-dcache-load-misses:u                                               
        11.610.243      LLC-loads:u                                                           
        10.132.020      LLC-load-misses:u                                                     

       0,729634965 seconds time elapsed
```

#### Dispersão Dupla
```text
[Dispersão Dupla] Fator de Carga: 85% | Inserindo 8500016 chaves...
[Dispersão Dupla] Tempo de Execução: 702.820847ms

 Performance counter stats for 'taskset -c 3 ./benchmark.executable double 85':

       379.370.582      L1-dcache-loads:u                                                     
        68.957.240      L1-dcache-load-misses:u                                               
        31.451.791      LLC-loads:u                                                           
        29.660.847      LLC-load-misses:u                                                     

       0,924757346 seconds time elapsed
```
