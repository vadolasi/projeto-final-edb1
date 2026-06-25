#import "@preview/charged-ieee:0.1.4": ieee

#show: ieee.with(
  title: [Tratamento de Colisões em Tabelas Hash: Um Estudo sobre Dispersão Dupla],
  abstract: [
    As funções de espalhamento (hash) são fundamentais para garantir acesso rápido e proteção de informações em estruturas de dados. Contudo, devido a limitações matemáticas, diferentes chaves podem mapear para o mesmo índice na tabela, gerando colisões. Este artigo analisa as principais técnicas para o tratamento de colisões (Encadeamento, Sondagem Linear e Quadrática), com ênfase aprofundada na técnica de endereçamento aberto de Dispersão Dupla (Double Hashing). Discutimos seu funcionamento matemático, exemplificamos na prática o comportamento da tabela frente a colisões e comparamos a dispersão dupla com os demais métodos. Nossos resultados indicam que a dispersão dupla resolve eficazmente problemas de agrupamento (clustering), oferecendo um tempo de busca mais estável.
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
Uma função de hash tem como objetivo converter qualquer informação em um código de tamanho fixo, operando como uma "impressão digital" dos dados. Ela assegura acesso a dados rapidamente, integridade e até mesmo proteção de senhas, visto que alterações no dado original modificam o código hash @kaspersky. No entanto, o problema inerente a essa redução de um espaço infinito a um escopo finito de índices é a inevitabilidade das colisões. O objetivo deste trabalho é discutir os fundamentos das técnicas de tratamento de colisões e detalhar a aplicação e as vantagens da Dispersão Dupla.

= Fundamentação Teórica

== Função Hash e Colisões
Uma colisão acontece quando dois conjuntos de dados distintos produzem o mesmo valor de hash na função de espalhamento, mapeando-os para a mesma posição no vetor @freeman @rodriveon2020. 

A @fig:colisao demonstra esse exato fenômeno. Ao tentarmos inserir o conjunto de chaves $K = {22, 33, 48}$ em uma tabela de $m = 11$ posições, utilizando a função $h(k) = k mod 11$, observamos o comportamento do mapeamento.

#figure(
  image("0.jpg", width: 80%),
  caption: [Exemplo de ocorrência de colisões em funções hash. Imagem gerada com auxílio de inteligência artificial por meio da ferramenta ChatGPT (OpenAI), sob orientação e revisão dos autores.],
  placement: top,
) <fig:colisao>

Conforme ilustrado, os valores 22 e 33 produzirão o mesmo índice de mapeamento (0), configurando uma colisão estrutural no momento de alocar a chave 33.
Para solucionar esse problema em tabelas, diversas estratégias podem ser empregadas, dividindo-se primariamente em técnicas de encadeamento exterior ou de endereçamento aberto (onde todos os dados permanecem no próprio vetor principal) @cormen2022.

== Encadeamento Externo
Uma colisão ocorre, matematicamente, quando duas chaves distintas $k_1$ e $k_2$ mapeiam para o mesmo índice, ou seja, $h(k_1) = h(k_2)$. Esse fenômeno é explicado pelo Princípio da Casa dos Pombos: se houver mais chaves possíveis (pombos) do que posições na tabela (caixas), pelo menos duas chaves compartilharão o mesmo espaço.

O encadeamento externo (ou _Separate Chaining_) é uma das soluções mais clássicas para isso. Diferente do endereçamento aberto, que busca o próximo índice vazio no próprio vetor, o encadeamento externo modifica a lógica da estrutura: cada posição do vetor atua como um ponteiro para uma lista ligada externa @weiss. 

Sempre que uma colisão acontece, o novo elemento é simplesmente anexado a essa lista. Como resultado, o armazenamento não fica restrito ao tamanho do vetor inicial, permitindo que a tabela cresça quase sem limites, dependendo apenas da memória RAM. As operações básicas comportam-se da seguinte maneira:
- *Inserção*: O índice é calculado e o elemento é colocado na lista (comumente no início, para manter a operação em $O(1)$).
- *Busca*: O índice é localizado pelo hash e, em seguida, a lista ligada correspondente é percorrida sequencialmente até que a chave seja encontrada.
- *Remoção*: Encontra-se a lista correta, localiza-se o item e os ponteiros são ajustados para retirar o nó da memória, sem a necessidade de marcadores especiais de remoção (_tombstones_).

Para avaliar o desempenho do encadeamento, utiliza-se o Fator de Carga ($alpha$), definido por $alpha = n / m$, onde $n$ é o número de elementos guardados e $m$ é o tamanho do vetor da tabela. No encadeamento, $alpha$ pode ser perfeitamente maior do que 1. Se a função hash espalhar os dados uniformemente, o tamanho médio de cada lista ligada será exatamente igual a $alpha$. 

#figure(
  caption: [Análise de Desempenho do Encadeamento],
  placement: top,
  table(
    columns: (auto, auto, auto),
    align: (left, center, left),
    table.header[*Cenário*][*Tempo*][*Comportamento Prático*],
    [Melhor Caso], [$O(1)$], [Dados bem distribuídos; o índice possui apenas um elemento ou está vazio.],
    [Caso Médio], [$O(1 + alpha)$], [Cálculo do hash somado ao tempo de percorrer uma lista de tamanho médio $alpha$.],
    [Pior Caso], [$O(n)$], [A função hash falha e todas as $n$ chaves são enviadas para a exata mesma posição.],
  )
) <tab:encadeamento_desempenho>

Para mitigar o cenário de pior caso --- onde a tabela se torna uma única lista ligada gigante ineficiente --- sistemas modernos usam a técnica de re-encadeamento dinâmico. Quando uma lista ultrapassa certo limite, ela é automaticamente convertida numa árvore binária autoequilibrada (como a árvore Rubro-Negra). Essa mudança assegura que, mesmo sob ataque intencional de colisões, o tempo de busca caia de $O(n)$ para $O(log n)$.

Apesar da tolerância a grandes volumes e não bloquear por falta de espaço físico, o encadeamento gasta mais memória para guardar os ponteiros de cada nó. Além disso, sofre expressiva perda de desempenho na memória _cache_ do processador: as listas espalham nós por locais aleatórios na RAM, desperdiçando a velocidade de leitura sequencial que vetores contínuos de endereçamento aberto fornecem.

== Sondagem Linear e Sondagem Quadrática
As sondagens são técnicas primárias de endereçamento aberto, que dispensam o uso de listas externas, buscando o próximo espaço vazio no próprio arranjo.
- *Sondagem Linear*: O método mais trivial. Soluciona colisões verificando índices linearmente consecutivos da tabela (incremento de 1 em 1). A codificação é simples e a localidade em cache é excelente (devido à contiguidade na memória). No entanto, ocasiona enorme taxa de _agrupamento primário_ (blocos de posições contíguas ocupadas), inviabilizando inserções futuras de forma eficiente.
- *Sondagem Quadrática*: O tamanho do salto para buscar um espaço vazio cresce quadraticamente (incrementos exponenciais como $1^2$, $2^2$, $3^2$). Isso reduz o agrupamento primário da sondagem linear, mas acarreta no agrupamento secundário (chaves com o mesmo hash inicial percorrem exatamente a mesma rota de pulos) e corre o risco de não acessar todos os elementos vazios disponíveis na tabela.

== Dispersão Dupla <sec:func>
A dispersão dupla (ou _Double Hashing_) utiliza uma técnica avançada de endereçamento aberto para resolver definitivamente os problemas de agrupamento estatístico das sondagens mais simples @knuth. Ela emprega duas funções de espalhamento diferentes. A primeira função ($h_1$) determina a posição inicial na tabela. Se o espaço não estiver disponível, uma segunda função ($h_2$) determina o tamanho do salto ou deslocamento da chave a ser tentada.

A fórmula para o cálculo do índice na tentativa $i$ pode ser descrita por @eq:hash:
$ h(k, i) = (h_1(k) + i dot h_2(k)) mod m $ <eq:hash>

Sendo:
- $k$: a chave a ser inserida.
- $i$: o número da tentativa (iniciando em 0).
- $h_1$: a função hash principal.
- $h_2$: a função hash secundária (define o tamanho do salto).
- $m$: o tamanho total da tabela.

Para que a dispersão dupla funcione sem entrar em laços infinitos na tabela, a principal regra é que a função secundária, $h_2(k)$, *nunca pode retornar zero* @cormen2022. Uma abordagem comum para garantir isso na elaboração de algoritmos é definir $h_2(k) = R - (k mod R)$, onde $R$ é um número primo menor que $m$. 

Outra regra impositiva é que $h_2(k)$ e o tamanho da tabela $m$ devem ser *primos relativos*, isto é, não compartilhar divisores comuns. Em termos práticos, é altamente recomendado que o tamanho do vetor $m$ seja dimensionado para um número primo.

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

= Conclusão
A dispersão dupla configura uma das técnicas mais robustas e estatisticamente perfeitas para endereçamento aberto, distribuindo dados sem viciar a tabela. Todavia, suas rígidas amarras matemáticas a tornam uma escolha adequada apenas a sistemas e arquiteturas que possam arcar com o custo dos acessos dispersos em nível de cache.

= Anexo I - Declaração de Uso de Inteligência Artificial
- *Ferramentas Utilizadas*: Google Gemini, OpenAI ChatGPT, Anthropic Claude.
- *Finalidade do Uso*: Geração ilustrativa de conceitos e refinamento da tipografia na conversão tipográfica.
- *Forma de Utilização*: Durante a modelagem do conteúdo, IAs produziram imagens sob a supervisão de diretrizes acadêmicas. Na formatação e redação, IAs como Google Gemini e Claude forneceram apoio em revisão ortográfica, adequação do layout das tabelas e montagem no padrão da *IEEE*.

= Anexo II - Contribuição dos Integrantes
- *João Gabriel de Andrade Matos Lima*: Autoria da subseção 2.1 (Função Hash e Colisões).
- *Victor Alves De Araujo Silva*: Autoria da subseção 2.2 (Encadeamento).
- *Diogo Ramon Fernandes de Oliveira*: Autoria da subseção 2.3 (Sondagem Linear e Sondagem Quadrática).
- *Fernanda Raquel Ramos Ho*: Autoria da subseção 2.4 (Dispersão Dupla), e do Exemplo Prático.
- *Vitor Daniel Lopes dos Santos*: Compilação, diagramação, produção dos anexos complementares e dos slides.
