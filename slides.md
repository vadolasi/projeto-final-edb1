---
marp: true
theme: default
class: lead
paginate: true
backgroundColor: #ffffff
---

# Tratamento de Colisões em Tabelas Hash
## Um Estudo sobre Dispersão Dupla (Double Hashing)

**Estrutura de Dados Básicas I - IMD0029**
Universidade Federal do Rio Grande do Norte (UFRN)

---

<!-- class: align-left -->
## Agenda

1. Introdução: Função Hash e Colisões
2. Dispersão Dupla: Conceito e Fórmulas
3. Exemplo Prático Passo a Passo
4. Vantagens e Custos (Cache Miss)
5. Comparação com Outros Métodos
6. Conclusão e Referências

---

## 1. O que é uma Função Hash?

- Converte uma informação em um código de tamanho fixo ("impressão digital").
- Garante acesso a dados em complexidade teórica constante $O(1)$.
- Qualquer mínima alteração no dado original altera completamente o valor de hash.
- Essencial em bancos de dados, dicionários, checagem de integridade e senhas.

---

## O Problema: Colisões

- Devido às limitações matemáticas de se reduzir um espaço infinito a um tamanho fixo, ocorrem **colisões**.
- **Colisão:** Quando dois conjuntos de dados distintos produzem o exato mesmo valor ou mapeiam para o mesmo índice na tabela.
- Requer uma estratégia de *Tratamento de Colisões*.
- Um dos métodos mais utilizados: **Endereçamento Aberto**.

---

## 2. Dispersão Dupla (Double Hashing)

A dispersão dupla é uma técnica avançada de endereçamento aberto que busca sanar falhas estatísticas (como agrupamentos) das sondagens mais simples.

Ela utiliza **duas funções de espalhamento** diferentes para determinar a sequência de índices a serem verificados:
- **Primeira Função ($h_1$):** Determina a posição inicial na tabela.
- **Segunda Função ($h_2$):** Determina o tamanho do "salto" ou deslocamento caso a posição inicial esteja ocupada.

---

## Fórmula da Dispersão Dupla

A posição a ser testada na tentativa $i$ é:

### $$ h(k, i) = (h_1(k) + i \cdot h_2(k)) \bmod m $$

Onde:
- **$k$**: A chave a ser inserida.
- **$i$**: O número da tentativa (0, 1, 2...).
- **$m$**: O tamanho da tabela.

---

## Regras Críticas

Para a dispersão dupla não entrar em loop infinito e garantir que visite todos os espaços da tabela, duas regras de $h_2$ são indispensáveis:

1. **Nunca retornar zero:** Se $h_2(k) = 0$, o pulo será de 0 posições. A inserção travará num *loop* infinito.
2. **Ser primo relativo com $m$:** O salto ($h_2(k)$) e o tamanho da tabela ($m$) não podem ter divisores comuns (além do 1). A solução mais simples é usar um **número primo** para o tamanho da tabela ($m$).

---

## 3. Exemplo Prático

Tamanho da Tabela: $m = 7$ (número primo).
Funções definidas:
- **$h_1(k) = k \bmod 7$** (Posição Inicial)
- **$h_2(k) = 1 + (k \bmod 5)$** (Tamanho do Salto)

*Vamos inserir as seguintes chaves nesta ordem: **8, 15, 22, 50***.

---

## Passo 1: Inserindo a Chave 8

- **Cálculo da Posição Inicial:** 
  $h_1(8) = 8 \bmod 7 = 1$

- O índice 1 está livre! 
- **Conclusão:** Chave 8 inserida no índice 1. (Tentativa $i=0$)

---

## Passo 2: Inserindo a Chave 15 (1ª Colisão)

- **Cálculo da Posição Inicial:** 
  $h_1(15) = 15 \bmod 7 = 1$ *(Opa, colidiu com o 8!)*
- Ação: Dispersão dupla!
- **Tamanho do Salto:** $h_2(15) = 1 + (15 \bmod 5) = 1 + 0 = \mathbf{1}$
- **Tentativa 1 ($i=1$):**
  $h(15, 1) = (1 + 1 \cdot 1) \bmod 7 = 2$

- O índice 2 está livre. A chave 15 entra no índice 2.

---

## Passo 3: Inserindo a Chave 22 (Salto Diferente)

- **Posição Inicial:** $h_1(22) = 22 \bmod 7 = 1$ *(Colidiu!)*
- **Tamanho do Salto:** $h_2(22) = 1 + (22 \bmod 5) = 1 + 2 = \mathbf{3}$
  *(Note como o salto mudou de 1 para 3!)*
- **Tentativa 1 ($i=1$):**
  $h(22, 1) = (1 + 1 \cdot 3) \bmod 7 = 4$

- O índice 4 está livre. A chave 22 entra no índice 4.

---

## Passo 4: Inserindo a Chave 50 (Múltiplas Colisões)

- **Posição Inicial:** $h_1(50) = 50 \bmod 7 = 1$ *(Colidiu!)*
- **Tamanho do Salto:** $h_2(50) = 1 + (50 \bmod 5) = 1 + 0 = \mathbf{1}$
- **Tentativa 1 ($i=1$):** $h(50, 1) = (1 + 1 \cdot 1) \bmod 7 = 2$
  *(Colidiu de novo, agora com o 15!)*
- **Tentativa 2 ($i=2$):** $h(50, 2) = (1 + 2 \cdot 1) \bmod 7 = 3$

- O índice 3 está livre. A chave 50 entra no índice 3.

---

## Estado Final da Tabela

| Índice | Chave | O que aconteceu? |
| :---: | :---: | :--- |
| **0** | Livre | Nenhum elemento |
| **1** | **8** | Entrou direto (Posição Original) |
| **2** | **15** | Colidiu no 1, deu um salto de 1 |
| **3** | **50** | Colidiu no 1 e no 2 |
| **4** | **22** | Colidiu no 1, deu salto de 3 |
| **5** | Livre | Nenhum elemento |
| **6** | Livre | Nenhum elemento |

*(Observe o espalhamento das chaves na tabela, sem formação de blocos colados!)*

---

## 4. Vantagens

1. **Fim do Agrupamento Primário:** Chaves que colidem no mesmo índice terão pulos de tamanhos diferentes, evitando os "blocos" da sondagem linear.
2. **Fim do Agrupamento Secundário:** Diferente da quadrática, chaves com o mesmo hash inicial tomam rotas diferentes.
3. **Distribuição Quase Ideal:** É a técnica de endereçamento aberto que estatisticamente mais se aproxima do mapeamento uniforme pseudoaleatório.

---

## Custos e Desvantagens

- **Alto Custo de CPU:** Calcular funções de módulo matematicamente encarece o processamento (duas funções por chave colidida).
- **Péssima Localidade de Referência (Cache Miss):** Hardwares modernos são otimizados para blocos sequenciais na memória cache (L1/L2/L3). Saltos longos causam acessos aleatórios constantes à lenta memória RAM.
- **Complexidade na Remoção:** Exige o uso pesado de marcadores ("Tombstones").
- **Restrições Matemáticas Rigorosas.**

---

## 5. Comparação Geral: Métodos

| Característica | Linear | Quadrática | Dispersão Dupla |
| :--- | :--- | :--- | :--- |
| **Agrupamento Primário** | Alto | Moderado | Inexistente |
| **Agrupamento Secundário**| Alto | Alto | Inexistente |
| **Performance de Cache** | **Excelente** | Média | **Ruim** (Cache Misses) |
| **Risco de Loop** | Baixo | Alto | Alto (se regras ignoradas) |
| **Uso de CPU** | Muito Baixo | Baixo | Alto |

---

## Conclusão

A **Dispersão Dupla** destaca-se como a abordagem mais poderosa para reduzir colisões com distribuição ótima, sendo recomendada para tabelas hash que sofrem densamente com alta taxa de agrupamento.

Apesar de seu sucesso teórico em manter buscas próximas de $O(1)$, impõe ressalvas substanciais na performance do processador em sistemas que tiram grande proveito da localidade de _cache_ espacial, além da forte dependência matemática.

---

## Anexo I - Declaração de Uso de Inteligência Artificial

Ferramentas de Inteligência Artificial (Google Gemini, ChatGPT, Claude) foram empregadas como **apoio complementar** na elaboração da formatação destes slides, revisão gramatical da sintaxe de apresentação (Marp) e sugestão de layout de tabelas de visualização e ilustrações explicativas, respeitando o princípio ético estabelecido na disciplina, de que o conteúdo autoral e a análise crítica pertencem unicamente aos alunos.

---

## Referências

1. CORMEN, T. H. et al. **Introduction to Algorithms**, 4th ed. MIT Press, 2022.
2. WEISS, M. A. **Estruturas de Dados e Análise de Algoritmos**. Pearson, 2013.
3. KNUTH, D. E. **The Art of Computer Programming, Volume 3: Sorting and Searching**. Addison-Wesley, 1998.
4. KASPERSKY. **Hash: o que são e como funcionam**.
5. FREEMAN LAW. **Hash Collisions Explained**.
6. RODRIVEON. **Função Hash**, YouTube, 2020.
