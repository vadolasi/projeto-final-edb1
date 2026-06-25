# Dispersão Dupla vs. Sondagem Linear

## Como Executar

```bash
make run-linear
make run-double
```


Para remover os binários gerados:
```bash
make clean
```

## Resultados Obtidos

### Ambiente de Execução

* **Processador:** 11th Gen Intel(R) Core(TM) i5-1135G7 @ 2.40GHz
* **Memória RAM:** 16 GB (DDR4)
* **Sistema Operacional:** CachyOS Linux (Base Arch Linux)
* **Kernel Linux:** `7.0.12-1-cachyos`
* **Compilador:** Go `go1.26.2 linux/amd64`

### Sondagem Linear (Linear Probing)
```text
[Sondagem Linear] Iniciando inserção de 8500016 chaves...
[Sondagem Linear] Tempo de Execução: 545.860417ms

 Performance counter stats for 'taskset -c 3 ./linear.executable':

       409.204.513      L1-dcache-loads:u                                                     
        29.875.534      L1-dcache-load-misses:u                                               
        11.610.243      LLC-loads:u                                                           
        10.132.020      LLC-load-misses:u                                                     

       0,729634965 seconds time elapsed
```

### Dispersão Dupla (Double Hashing)
```text
[Dispersão Dupla] Iniciando inserção de 8500016 chaves...
[Dispersão Dupla] Tempo de Execução: 702.820847ms

 Performance counter stats for 'taskset -c 3 ./double.executable':

       379.370.582      L1-dcache-loads:u                                                     
        68.957.240      L1-dcache-load-misses:u                                               
        31.451.791      LLC-loads:u                                                           
        29.660.847      LLC-load-misses:u                                                     

       0,924757346 seconds time elapsed
```
