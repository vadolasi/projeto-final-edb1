#import "@preview/charged-ieee:0.1.4": ieee

#show: ieee.with(
  title: [Tratamento de Colisões em Tabelas Hash: Um Estudo sobre Dispersão Dupla],
  abstract: [
    As funções de espalhamento (hash) são fundamentais para garantir acesso rápido e proteção de informações em estruturas de dados. Contudo, devido a limitações matemáticas, diferentes chaves podem mapear para o mesmo índice na tabela, gerando colisões. Este artigo analisa as principais técnicas para o tratamento de colisões (Encadeamento, Sondagem Linear e Quadrática), com ênfase aprofundada na técnica de endereçamento aberto de Dispersão Dupla (Double Hashing). Discutimos seu funcionamento matemático, exemplificamos na prática o comportamento da tabela frente a colisões e comparamos a dispersão dupla com os demais métodos. Nossos resultados teóricos indicam que a dispersão dupla resolve eficazmente problemas de agrupamento (clustering), oferecendo um tempo de busca mais estável. No entanto, avaliações experimentais em hardware indicam que a localidade de referência da Sondagem Linear supera a dispersão dupla em desempenho devido aos impactos da cache de memória.
  ],
  authors: (
    (
      name: "João Gabriel de Andrade Matos Lima"
    ),
    (
      name: "Victor Alves De Araujo Silva"
    ),
    (
      name: "Diogo Ramon Fernandes de Oliveira"
    ),
    (
      name: "Fernanda Raquel Ramos Ho"
    ),
    (
      name: "Vitor Daniel Lopes dos Santos"
    ),
  ),
  index-terms: ("Tabelas Hash", "Tratamento de Colisões", "Endereçamento Aberto", "Dispersão Dupla"),
  bibliography: bibliography("refs.bib"),
  figure-supplement: [Fig.],
)

= Introdução
As tabelas hash são frequentemente empregadas em sistemas de computação por sua habilidade de executar operações de busca, inserção e exclusão de maneira bastante eficaz @cormen2022. Estruturas que utilizam tabelas hash podem ser encontradas em bancos de dados, compiladores, sistemas operacionais e aplicativos que necessitam de acesso ágil às informações. No entanto, quando há colisões entre chaves, é imprescindível adotar métodos de manejo que garantam o armazenamento correto dos elementos @cormen2022.

Dentre as abordagens de endereçamento aberto, se sobressaem a Sondagem Linear e a Dispersão Dupla. Apesar de ambos terem um desempenho teórico satisfatório, as suas estratégias de acesso à memória diferem, o que pode impactar diretamente o funcionamento do processador e da hierarquia de memória cache @cormen2022 @patterson2021.

Nas estruturas arquitetônicas contemporâneas, a eficácia dos algoritmos não se restringe apenas à sua complexidade computacional, mas também é influenciada pelo modo como os dados são recuperados da memória. A violação da localidade de referência pode resultar em um incremento nas falhas de cache, o que gera um maior número de acessos à memória principal e, por consequência, afeta negativamente o desempenho @patterson2021 @tanenbaum2013.

Neste contexto, o presente estudo sugere uma investigação prática sobre a influência do cache em abordagens de endereçamento aberto, fazendo uma comparação entre a Sondagem Linear e a Dispersão Dupla. Para alcançar esse objetivo, são analisadas métricas de desempenho que dizem respeito ao tempo de execução e à performance dos diversos níveis de cache do processador.

A estrutura do artigo segue a seguinte organização: na Seção 2, são discutidos os trabalhos relacionados encontrados na literatura. A Seção 3 apresenta a fundamentação teórica dos métodos clássicos. A Seção 4 apresenta o exemplo prático e a análise de vantagens e custos teóricos. A Seção 5 expõe a proposta do estudo e a metodologia de hardware empregada. Na Seção 6, são apresentados os resultados experimentais obtidos e a sua discussão física. Finalmente, a Seção 7 traz as conclusões do trabalho e as reflexões finais.

= Trabalhos Relacionados
A literatura clássica de estruturas de dados frequentemente prioriza a análise de complexidade assintótica e a mitigação do agrupamento primário em tabelas de dispersão, favorecendo abordagens teóricas como a Dispersão Dupla @knuth @cormen2022. No entanto, trabalhos fundamentados em algoritmos conscientes de hardware apontam que o custo de acesso à memória pode mudar essa vantagem.

Heileman e Luo @heileman2005 comprovaram empiricamente que a localidade espacial beneficia a Sondagem Linear pelo melhor uso do cache L1, embora tenham avaliado apenas o tempo em arquiteturas antigas. Richter et al. @richter2015 analisaram métodos de hashing sob estresse e mostraram que os saltos da Dispersão Dupla prejudicam o hardware prefetcher do processador, gerando ciclos ociosos (stalls). Em Balkesen et al. @balkesen2013, discute-se o impacto da latência em acessos aleatórios devido à "Muralha da Memória" @wulf1995, mostrando que a falta de contiguidade força buscas na memória principal.

Diferente de trabalhos anteriores que usam simulação ou rodam sem isolamento de CPU, este artigo avalia os métodos em hardware moderno sob alto fator de carga (85%), medindo dados diretamente da CPU via perf com afinidade de núcleo física. Isso permite mensurar a penalidade no cache L3 causada pelos acessos não sequenciais.

= Fundamentação Teórica

== Função Hash e Colisões
Uma colisão acontece quando dois conjuntos de dados distintos produzem o mesmo valor de hash na função de espalhamento, mapeando-os para a mesma posição no vetor @freeman @rodriveon2020. 

A @fig:colisao demonstra esse exato fenômeno. Ao tentarmos inserir o conjunto de chaves $K = {22, 33, 48}$ em uma tabela de $m = 11$ posições, utilizando a função $h(k) = k mod 11$, observamos o comportamento do mapeamento.

#figure(
  image("0.jpg", width: 80%),
  caption: [Exemplo de ocorrência de colisões em funções hash. Imagem gerada com auxílio de inteligência artificial por meio da ferramenta ChatGPT (OpenAI), sob orientação e revisão dos autores.],
  placement: top,
) <fig:colisao>

Conforme ilustrado, os valores 22 e 33 produzirão o mesmo índice de mapeamento (0), configurando uma colisão estrutural no momento de alocar a chave 33. Para solucionar esse problema em tabelas, diversas estratégias podem ser empregadas, dividindo-se primariamente em técnicas de encadeamento exterior ou de endereçamento aberto (onde todos os dados permanecem no próprio vetor principal) @cormen2022.

== Encadeamento
O encadeamento (ou separate chaining) é uma técnica de tratamento de colisões que utiliza estruturas de dados auxiliares, comumente listas encadeadas, vinculadas a cada índice da tabela hash principal. Quando uma colisão ocorre, o novo elemento é simplesmente inserido na lista ligada àquele índice, em vez de buscar um novo espaço livre no vetor. Apesar de ser de fácil implementação e não sofrer com o limite rígido de capacidade (o fator de carga pode exceder 1), o encadeamento pode causar degradação de desempenho se as listas crescerem demasiadamente, além de aumentar o consumo de memória devido aos ponteiros adicionais @weiss.

== Sondagem Linear e Sondagem Quadrática
As sondagens são técnicas primárias de endereçamento aberto, que dispensam o uso de listas externas, buscando o próximo espaço vazio no próprio arranjo.
- *Sondagem Linear*: O método mais trivial. Soluciona colisões verificando índices linearmente consecutivos da tabela (incremento de 1 em 1). A codificação é simples e a localidade em cache é excelente (devido à contiguidade na memória). No entanto, ocasiona enorme taxa de agrupamento primário (blocos de posições contíguas ocupadas), inviabilizando inserções futuras de forma eficiente.
- *Sondagem Quadrática*: O tamanho do salto para buscar um espaço vazio cresce quadraticamente (incrementos exponenciais como $1^2$, $2^2$, $3^2$). Isso reduz o agrupamento primário da sondagem linear, mas acarreta no agrupamento secundário (chaves com o mesmo hash inicial percorrem exatamente a mesma rota de pulos) e corre o risco de não acessar todos os elementos vazios disponíveis na tabela.

== Dispersão Dupla <sec:func>
A dispersão dupla (ou double hashing) utiliza uma técnica avançada de endereçamento aberto para resolver definitivamente os problemas de agrupamento estatístico das sondagens mais simples @knuth. Ela emprega duas funções de espalhamento diferentes. A primeira função ($h_1$) determina a posição inicial na tabela. Se o espaço não estiver disponível, uma segunda função ($h_2$) determina o tamanho do salto ou deslocamento da chave a ser tentada.

A fórmula para o cálculo do índice na tentativa $i$ pode ser descrita por @eq:hash:
$ h(k, i) = (h_1(k) + i dot h_2(k)) mod m $ <eq:hash>

Sendo:
- $k$: a chave a ser inserida.
- $i$: o número da tentativa (iniciando em 0).
- $h_1$: a função hash principal.
- $h_2$: a função hash secundária (define o tamanho do salto).
- $m$: o tamanho total da tabela.

Para que a dispersão dupla funcione sem entrar em laços infinitos na tabela, a principal regra é que a função secundária, $h_2(k)$, nunca pode retornar zero @cormen2022. Uma abordagem comum para garantir isso na elaboração de algoritmos é definir $h_2(k) = R - (k mod R)$, onde $R$ é um número primo menor que $m$.

Outra regra impositiva é que $h_2(k)$ e o tamanho da tabela $m$ devem ser primos relativos, isto é, não compartilhar divisores comuns. Em termos práticos, é altamente recomendado que o tamanho do vetor $m$ seja dimensionado para um número primo.

Abaixo, criamos representações visuais passo a passo simulando a inserção no vetor para demonstrar o rastreio da dupla dispersão em caso de colisão para $m=11$ posições:

*1. Inserção da Chave 58* \
A posição inicial resulta em $h_1(58) = 3$. Como o índice 3 está livre, a chave 58 é armazenada.
#align(center)[
  #table(columns: 11, align: center, inset: 4pt,
    [*0*], [*1*], [*2*], [*3*], [*4*], [*5*], [*6*], [*7*], [*8*], [*9*], [*10*],
    [], [], [], [*58*], [], [], [], [], [], [], []
  )
]

*2. Inserção da Chave 14* \
A posição inicial resulta em $h_1(14) = 3$ *(Colisão!)*. A função de salto retorna $h_2(14) = 7 - (14 mod 7) = 7$. A nova posição será $(3 + 1 dot 7) mod 11 = 10$. A chave 14 é armazenada no índice 10.
#align(center)[
  #table(columns: 11, align: center, inset: 4pt,
    [*0*], [*1*], [*2*], [*3*], [*4*], [*5*], [*6*], [*7*], [*8*], [*9*], [*10*],
    [], [], [], [58], [], [], [], [], [], [], [*14*]
  )
]

= Exemplo Prático de Dispersão Dupla
Para materializar as equações da @sec:func, demonstramos um exemplo prático com uma tabela de tamanho pequeno, $m = 7$ (que é um número primo), com índices de 0 a 6.

Assuma as funções:
- $h_1(k) = k mod 7$
- $h_2(k) = 1 + (k mod 5)$

Inseriremos as chaves nesta exata ordem: 8, 15, 22, e 50.

*Passo 1: Inserir a Chave 8* \
$h_1(8) = 1$. A tabela está vazia, o índice 1 recebe a chave 8.
#align(center)[
  #table(columns: 7, align: center, inset: 5pt,
    [*0*], [*1*], [*2*], [*3*], [*4*], [*5*], [*6*],
    [], [*8*], [], [], [], [], []
  )
]

*Passo 2: Inserir a Chave 15 (Primeira Colisão)* \
$h_1(15) = 1$ *(Colisão)*. O salto calculado é $h_2(15) = 1$. \
Nova posição ($i=1$): $(1 + 1 dot 1) mod 7 = 2$.
#align(center)[
  #table(columns: 7, align: center, inset: 5pt,
    [*0*], [*1*], [*2*], [*3*], [*4*], [*5*], [*6*],
    [], [8], [*15*], [], [], [], []
  )
]

*Passo 3: Inserir a Chave 22* \
$h_1(22) = 1$ *(Colisão)*. O salto calculado é $h_2(22) = 3$. \
Nova posição ($i=1$): $(1 + 1 dot 3) mod 7 = 4$.
#align(center)[
  #table(columns: 7, align: center, inset: 5pt,
    [*0*], [*1*], [*2*], [*3*], [*4*], [*5*], [*6*],
    [], [8], [15], [], [*22*], [], []
  )
]

*Passo 4: Inserir a Chave 50 (Múltiplas Colisões)* \
$h_1(50) = 1$ *(Colisão)*. O salto calculado é $h_2(50) = 1$. \
Tentativa 1 ($i=1$): $(1 + 1 dot 1) mod 7 = 2$ *(Colisão com o 15)*. \
Tentativa 2 ($i=2$): $(1 + 2 dot 1) mod 7 = 3$.
#align(center)[
  #table(columns: 7, align: center, inset: 5pt,
    [*0*], [*1*], [*2*], [*3*], [*4*], [*5*], [*6*],
    [], [8], [15], [*50*], [22], [], []
  )
]

= Vantagens e Custos
Como visto, a grande vantagem da dispersão dupla é eliminar por completo os agrupamentos primários e secundários, sendo a técnica que mais se aproxima de um espalhamento uniforme ideal e possuindo alta resiliência frente a tabelas com alto fator de carga @weiss.

No entanto, o maior obstáculo está no *Cache Miss* (péssima localidade de referência). A arquitetura dos processadores modernos beneficia blocos contíguos no Cache (L1/L2). Os saltos pseudoaleatórios geram constantes falhas de cache, forçando leituras lentas na memória RAM @cormen2022. Além disso, a computação algébrica de duas funções hash demanda maior esforço constante da CPU, e a remoção de dados exige implementações trabalhosas de marcadores (Tombstones).

= Comparação com Outros Métodos
Para consolidar os achados sobre técnicas de sondagem em endereçamento aberto de hash tables, podemos inferir através de comparação direta:

- *Sondagem Linear*: O método mais trivial. Soluciona colisões verificando índices linearmente consecutivos da tabela com incremento unitário. A codificação é simples e a localidade em cache é excelente (devido à contiguidade). No entanto, ocasiona enorme taxa de agrupamento primário e risco de gargalo algorítmico, inviabilizando escalabilidade.
- *Sondagem Quadrática*: O tamanho do salto cresce quadraticamente (incrementos exponenciais $1^2$, $2^2$, $3^2$). Reduz o agrupamento linear severo e espalha ligeiramente melhor as inserções no vetor em comparação à linear, mas corre o risco de não acessar todos os elementos vazios disponíveis de sua tabela para o preenchimento completo.
- *Dispersão Dupla*: Garante acessar todo elemento disponível desde que seu salto seja coprimo da capacidade. Oferece a melhor distribuição pseudoaleatória, mas é severamente impactada pelo custo de localidade no cache das CPUs e complexidade técnica imposta.

#figure(
  caption: [Comparativo Direto: Sondagem Linear vs. Dispersão Dupla],
  placement: top,
  table(
    columns: (auto, auto, auto),
    align: (left, center, center),
    table.header[*Característica*][*Sondagem Linear*][*Dispersão Dupla*],
    [Agrupamento Primário], [Alto], [Inexistente],
    [Agrupamento Secundário], [Alto], [Inexistente],
    [Uso de CPU (Cálculo)], [Muito Baixo (Soma 1)], [Alto (Duas funções)],
    [Performance de Cache], [Excelente], [Ruim (Saltos aleatórios)],
    [Risco de Loops Infinitos], [Inexistente], [Alto (se regra ignorada)],
    [Complexidade de Código], [Simples], [Avançada (Rigor estrito)],
  )
) <tab:comparacao>

= Proposta do Estudo e Metodologia Empregada

== Proposta de Análise Empírica
Este trabalho propõe uma abordagem prática para avaliar o impacto da hierarquia de memória no desempenho de tabelas hash, comparando duas técnicas de endereçamento aberto para resolução de colisões: a Sondagem Linear e a Dispersão Dupla @cormen2022.

Na literatura de estruturas de dados, a Dispersão Dupla é teoricamente apontada como superior em alta ocupação por eliminar o agrupamento primário @cormen2022. No entanto, análises matemáticas costumam desconsiderar a arquitetura física da memória e dos processadores atuais @patterson2021.

A nossa proposta consiste em realizar uma análise empírica orientada ao hardware, investigando como a localidade de referência afeta o tempo real de execução. Enquanto a Sondagem Linear varre posições contíguas, aproveitando linhas de cache e o hardware prefetcher, a Dispersão Dupla realiza saltos pseudoaleatórios que invalidam as linhas de cache de dados @drepper2007. Monitorando os contadores de hardware (como cache L1 de dados e LLC), correlacionamos as falhas de cache com o tempo total de processamento das inserções em larga escala.

== Ambiente de Execução
Para garantir a reprodutibilidade dos testes e isolar variáveis externas do sistema, o benchmark foi executado em uma máquina com as seguintes especificações:
- *CPU*: Intel Core i5-1135G7 (11ª Geração) \@ 2.40GHz.
- *RAM*: 16 GB DDR4.
- *Sistema Operacional*: CachyOS Linux (baseado em Arch Linux, com kernel otimizado para baixa latência).
- *Kernel*: 7.0.12-1-cachyos.
- *Linguagem*: Go (versão go1.26.2 linux/amd64).

== Metodologia Experimental
O desenho experimental consistiu em medir o tempo e o custo físico da inserção massiva de chaves numéricas sob fatores de carga de 50% e 85%. Para mitigar a interferência do escalonador do sistema operacional e tráfego concorrente, usamos o utilitário `taskset` @taskset para fixar a execução em um único núcleo físico (Core 3):
`taskset -c 3 ./benchmark.executable [linear|double] [50|85]`

A tabela hash foi alocada com capacidade de $m = 10.000.019$ posições (número primo). Geramos chaves inteiras únicas de 64 bits de forma pseudoaleatória para simular estresse de escrita.

Os dados de baixo nível de hardware foram coletados com o utilitário `perf` @perf do Linux. As métricas monitoradas foram:
- *L1-dcache-loads*: Leituras na cache de dados L1.
- *L1-dcache-load-misses*: Falhas na cache L1 que exigem busca nos níveis inferiores.
- *LLC-loads*: Acessos à cache de último nível (L3).
- *LLC-load-misses*: Falhas na LLC que forçam acessos lentos à RAM principal.
- *Tempo de Execução*: Medido internamente via API nativa de tempo do Go.
- *Tempo Total Elapsado*: Tempo de execução externo medido pelo `perf`.

= Resultados e Análise

== Resultados Obtidos
Os dados brutos recolhidos nos testes foram devidamente normalizados para extrair as taxas de falha (miss rates) de cada estrutura em ambos os cenários.

#figure(
  caption: [Resultados experimentais sob fator de carga moderado (50%)],
  table(
    columns: (2.5fr, 1.5fr, 1.5fr, 2.5fr),
    align: (left, center, center, left),
    table.header[*Métrica de Avaliação*][*Sondagem Linear*][*Dispersão Dupla*][*Impacto Relativo*],
    [Tempo de Execução (Go)], [163,75 ms], [278,92 ms], [Dispersão Dupla é 70,3% mais lenta],
    [Tempo Total Elapsado], [0,277 s], [0,384 s], [Linear conclui o processo mais rápido],
    [L1-dcache Loads], [224.164.179], [226.247.448], [Similaridade na quantidade de acessos],
    [L1-dcache Misses (Taxa)], [14.153.447 (6,31%)], [18.127.846 (8,01%)], [Dispersão Dupla falha ~27% mais em L1],
    [LLC Loads], [4.973.039], [7.621.271], [Dispersão Dupla gera 53,2% mais acessos ao L3],
    [LLC Misses (RAM)], [4.515.051 (90,79%)], [7.151.752 (93,84%)], [58,4% mais acessos à RAM na Dispersão Dupla]
  )
) <tab:bench_50>

#figure(
  caption: [Resultados experimentais sob fator de carga elevado (85%)],
  table(
    columns: (2.5fr, 1.5fr, 1.5fr, 2.5fr),
    align: (left, center, center, left),
    table.header[*Métrica de Avaliação*][*Sondagem Linear*][*Dispersão Dupla*][*Impacto Relativo*],
    [Tempo de Execução (Go)], [545,86 ms], [702,82 ms], [Dispersão Dupla é 28,7% mais lenta],
    [Tempo Total Elapsado], [0,729 s], [0,924 s], [Linear mantém liderança em performance],
    [L1-dcache Loads], [409.204.513], [379.370.582], [Menos loads na dupla, mas com pior eficiência],
    [L1-dcache Misses (Taxa)], [29.875.534 (7,30%)], [68.957.240 (18,18%)], [Explosão de misses em L1 na Dispersão Dupla (+130,8%)],
    [LLC Loads], [11.610.243], [31.451.791], [Dispersão Dupla gera 170% mais buscas no L3],
    [LLC Misses (RAM)], [10.132.020 (87,27%)], [29.660.847 (94,31%)], [Quase o triplo (192,7% mais) de acessos à RAM]
  )
) <tab:bench_85>

== Discussão e Confronto com a Literatura
Os resultados experimentais contrariam a visão teórica tradicional de que a Dispersão Dupla seria superior à Sondagem Linear sob altos fatores de carga. A Sondagem Linear apresentou menor tempo de execução em ambos os cenários (163,75 ms vs 278,92 ms em 50% de carga, e 545,86 ms vs 702,82 ms em 85% de carga).

Isso ocorre devido ao princípio da *Localidade Espacial de Referência* @patterson2021: quando a Sondagem Linear falha em encontrar um slot livre e se move para o índice imediatamente vizinho ($i + 1$), esse slot muito provavelmente já foi transferido para dentro da mesma linha de cache da CPU (tipicamente com 64 bytes de largura) durante o primeiro acesso @drepper2007. Como o benchmark usa inteiros de 64 bits em Go (8 bytes), cada linha de cache armazena 8 posições consecutivas da tabela. Ao colidir no índice $i$, a Sondagem Linear testa o índice $i+1$, que provavelmente já está na cache L1, resultando em latência mínima.

Além disso, a contiguidade física favorece o funcionamento do *Hardware Prefetcher* integrado ao processador. Os processadores modernos detectam o padrão de acesso sequencial (passos unitários) e pré-carregam as próximas linhas de cache de forma antecipada @richter2015. Isso explica por que a taxa de falhas L1 da Sondagem Linear se manteve estável (variando de 6,31% a 7,30%).

Em contrapartida, a Dispersão Dupla calcula saltos pseudoaleatórios que dependem do valor da chave, o que impede a predição pelo prefetcher de hardware @richter2015. Sob 85% de fator de carga, a taxa de falhas L1 da Dispersão Dupla subiu para 18,18% (mais que o dobro da linear). A quebra de localidade espacial gera buscas constantes na cache de último nível (LLC/L3). Em 85% de carga, a Dispersão Dupla gerou 31,4 milhões de buscas no L3, resultando em 29,6 milhões de falhas LLC (acessos à RAM). Esse número é quase o triplo do registrado pela Sondagem Linear (10,1 milhões).

A latência de acesso à memória RAM (cerca de 50 a 100 ns) é muito maior que a do cache L1. Esse atraso força a CPU a aguardar os dados em ciclos ociosos (stalls), configurando o gargalo conhecido como a "Muralha da Memória" (*Memory Wall*) @wulf1995 @balkesen2013. Na Dispersão Dupla, o tempo perdido nesses stalls supera as vantagens de termos menos colisões.

Adicionalmente, a operação de módulo ($mod$) necessária para calcular a segunda função hash exige divisão inteira, que consome de 10 a 40 ciclos de clock nas CPUs modernas, enquanto somas e multiplicações são executadas em apenas um ciclo. Isso sobrecarrega a CPU e explica por que a Dispersão Dupla foi 70,3% mais lenta mesmo sob carga moderada de 50%, onde há poucas colisões.

= Conclusão e Reflexões Finais
Os resultados obtidos mostraram que a Sondagem Linear teve um desempenho superior ao da Dispersão Dupla no ambiente experimental estudado. Embora a Dispersão Dupla diminua o agrupamento de elementos, seus acessos pseudoaleatórios resultaram em um maior número de falhas de cache, o que aumentou o tempo total de execução.

A Sondagem Linear demonstrou uma melhor localidade de referência, o que favoreceu os mecanismos de prefetch e a utilização do cache do processador. Assim, os resultados sugerem que a eficiência teórica de um algoritmo nem sempre se traduz em um desempenho ótimo em arquiteturas modernas.

Portanto, conclui-se que a seleção do método de tratamento de colisões deve levar em conta não apenas a análise algorítmica tradicional, mas também os impactos da hierarquia de memória e do comportamento do hardware.

= Anexo I - Declaração de Uso de Inteligência Artificial
- *Ferramentas Utilizadas*: Google Gemini, OpenAI ChatGPT, Anthropic Claude.
- *Finalidade do Uso*: Geração ilustrativa de conceitos, refinamento da tipografia na conversão tipográfica, projeto e estruturação dos testes.
- *Forma de Utilização*: Durante a modelagem do conteúdo, IAs produziram imagens sob a supervisão de diretrizes acadêmicas. Na formatação e redação, IAs forneceram apoio em revisão ortográfica, adequação do layout das tabelas e montagem no padrão da *IEEE*. Adicionalmente, as ferramentas foram consultadas para modelagem da lógica do benchmark em Go e estruturação dos scripts de monitoramento de performance com o perf no Linux.

= Anexo II - Contribuição dos Integrantes
- *João Gabriel de Andrade Matos Lima*: Redação da Introdução e da Conclusão .
- *Fernanda Raquel Ramos Ho*: Redação da seção "Trabalhos Relacionados".
- *Victor Alves De Araujo Silva*: Redação das seções "Proposta" e "Avaliação".
- *Diogo Ramon Fernandes de Oliveira*: Redação das seções "Resultados" e "Discussão" .
- *Vitor Daniel Lopes dos Santos*: Desenvolvimento e execução dos testes, compilação, revisão textual, diagramação, produção dos Anexos e dos slides.
