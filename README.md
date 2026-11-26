# 🌲 Tree Despise Chaos! (Tree-Hates-Chaos)

> **Projeto prático e interativo de Teoria dos Grafos & Estruturas de Dados Avançadas aplicado ao desenvolvimento de jogos.**

Desenvolvido em **GameMaker** (GML), o projeto visualiza e demonstra na prática o funcionamento, balanceamento e otimização de diferentes tipos de árvores em cenários clássicos de games: particionamento espacial (radar/tiro), gerenciamento de ameaças/ordenação (agro de monstros) e inventários auto-balanceáveis com nós múltiplos.

---

## 🎮 Visão Geral das Estruturas e Minigames

O projeto conta com um **layout dividido em split-screen**:
* **Lado Esquerdo (Arena de Jogo):** Simulação interativa onde as mecânicas de gameplay e entidades atuam em tempo real.
* **Lado Direito (Inspetor Topológico):** Desenho em tempo real e auto-ajustável dos nós, cores, divisões e conexões topológicas da árvore com métricas e log de operações em tempo real.

O projeto implementa 3 árvores distintas em salas dedicadas:

### 1. 🎯 Árvore k-D (2D k-D Tree) — `[Tecla 1]` / `rm_kdtree`
* **Mecânica no Jogo:** Radar e detecção espacial de naves inimigas na arena.
* **Conceito Teórico:** Particionamento do espaço 2D alternando eixos de corte cartesianos ($X$ e $Y$) a cada nível de profundidade.
* **Aplicações em Games:** Busca do Vizinho Mais Próximo (*Nearest Neighbor Search*) com poda de quadrantes inteiros, acelerando miras automáticas e detecção de proximidade de $O(N)$ para $O(\log N)$ em média.
* **Funcionalidades:** Inserção dinâmica, reorganização/balanceamento pela mediana dos pontos e detecção de nós sobrepostos.

### 2. 🔴⚫ Árvore Rubro-Negra (Red-Black Tree) — `[Tecla 2]` / `rm_rbtree`
* **Mecânica no Jogo:** Gerenciamento de ameaça e fila de ataque (*Agro*) de monstros (Goblins, Orcs, Dragões, etc.).
* **Conceito Teórico:** Árvore binária de busca auto-balanceável que garante altura $h \le 2\log_2(N+1)$ atribuindo cores (Vermelho/Preto) e executando rotações à esquerda/direita e recolorações para evitar degeneração da árvore.
* **Aplicações em Games:** Busca, inserção e remoção no pior caso garantidos em $O(\log N)$, ideal para listas de prioridade de IA e tabelas de agro em tempo real.
* **Funcionalidades:** Modo didático passo a passo para visualizar violações de nós vermelhos adjacentes e balanceamento manual/automático.

### 3. 📦 Árvore 2-3-4 (B-Tree de Ordem 4) — `[Tecla 3]` / `rm_234tree`
* **Mecânica no Jogo:** Inventário de itens e loot RPG indexados por valor em ouro.
* **Conceito Teórico:** Árvore de busca multi-caminhos perfeitamente balanceada onde cada nó interno possui 2, 3 ou 4 filhos (e 1, 2 ou 3 chaves). Cresce de baixo para cima utilizando *Splits* preemptivos e *Merges* (fusões) em underflow.
* **Aplicações em Games:** Estruturas de indexação de inventário, caches de assets em blocos e paginação de dados em disco/memória.
* **Funcionalidades:** Demonstração visual de cisão (*Split*) de nós cheios e fusão (*Merge*) em tempo real.

---

## ⌨️ Controles e Atalhos

### Navegação Global
| Atalho | Ação |
| :--- | :--- |
| `1` | Ir para a sala da **k-D Tree** |
| `2` | Ir para a sala da **Árvore Rubro-Negra** |
| `3` | Ir para a sala da **Árvore 2-3-4** |
| `F1` | Repovoar a árvore com 22 nós aleatórios |
| `Espaço` | Pausar / Continuar simulação |
| `F11` | Alternar modo Janela / Tela Cheia |

### Controles Específicos por Minigame
* **k-D Tree:**
  * `S`: Inserir pontos em padrão diagonal (forçar desbalanceamento).
  * `B` (ou clique no botão): Reconstruir e balancear a árvore pela mediana.
  * `Botão Esquerdo`: Inserir nova nave na coordenada do clique.
* **Árvore Rubro-Negra:**
  * `S` / `I`: Inserir novo monstro e gerar conflito de nós vermelhos.
  * `B` (ou clique no botão): Executar passo de correção e balanceamento (rotação/recoloração).
* **Árvore 2-3-4:**
  * `B` (ou clique no botão): Forçar *Split* no 4-nó.
  * `K`: Testar *Merge* / remoção com fusão.

---

## 🛠️ Tecnologias Utilizadas

* **Engine:** [GameMaker](https://gamemaker.io/) (GML - GameMaker Language)
* **Arquitetura:** Scripts modulares em GML orientados a construtores (`constructor` / `structs`) para implementação manual e pura das estruturas de dados sem dependências externas.
* **Renderização:** Canvas procedural auto-ajustável para desenho em tempo real da topologia da árvore (`scr_visualizer`).

---

## 🚀 Como Executar o Projeto

1. Baixe ou clone este repositório:
   ```bash
   git clone https://github.com/Joao-Pedro-Moraes/Tree-Hates-Chaos-.git
   ```
2. Abra o **GameMaker**.
3. Selecione **Open** e aponte para o arquivo do projeto:
   ```text
   TREE DESPISE CHAOS!!.yyp
   ```
4. Pressione `F5` (ou o botão Run) para compilar e iniciar o minigame.
