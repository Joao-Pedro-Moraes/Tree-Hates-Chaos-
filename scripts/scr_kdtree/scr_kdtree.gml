/// ============================================================================
/// SCRIPT: scr_kdtree
/// ESTRUTURA: Árvore Binária k-D (k = 2 dimensões: Eixo X e Eixo Y)
/// OBJETIVO: Organizar pontos 2D em hiperplanos alternados para buscas espaciais
///           rápidas (Vizinho Mais Próximo) com poda de quadrantes.
/// ============================================================================

/// ----------------------------------------------------------------------------
/// CONSTRUTOR: KDNode(_px, _py, _axis, _label_id)
/// DESCRIÇÃO: Cria um nó espacial representando uma nave inimiga na arena.
/// PARÂMETROS:
///   _px       -> Coordenada X do ponto na arena
///   _py       -> Coordenada Y do ponto na arena
///   _axis     -> Dimensão de corte deste nó (0 = Vertical/X, 1 = Horizontal/Y)
///   _label_id -> Identificador numérico único exibido no inspetor
/// ----------------------------------------------------------------------------
function KDNode(_px, _py, _axis, _label_id) constructor {
    px   = _px;         // Armazena a posição X real na arena
    py   = _py;         // Armazena a posição Y real na arena
    key  = _label_id;   // Rótulo visual do nó (1, 2, 3...)
    axis = _axis;       // Define qual coordenada será comparada neste nível
    
    // Política de elementos repetidos: em vez de criar nós duplicados na árvore,
    // pontos sobrepostos (< 4px) são agrupados dentro do mesmo nó.
    count      = 1;     // Quantidade de entidades neste ponto
    duplicates = [];    // Lista de coordenadas das réplicas agrupadas
    
    // Ponteiros topológicos para as subárvores
    left  = undefined;  // Filhos com coordenada MENOR que o corte no eixo atual
    right = undefined;  // Filhos com coordenada MAIOR ou IGUAL no eixo atual
    
    // Coordenadas visuais usadas exclusivamente pelo Inspetor Topológico (direita)
    x        = 1015;    // Posição X atual na tela (interpolada)
    y        = 80;      // Posição Y atual na tela (interpolada)
    target_x = 1015;    // Posição X destino calculada pelo layout em-ordem
    target_y = 80;      // Posição Y destino calculada pela profundidade
}

/// ----------------------------------------------------------------------------
/// CONSTRUTOR: KDTree()
/// DESCRIÇÃO: Estrutura gerenciadora da k-D Tree (inserção, mediana, busca, remoção).
/// ----------------------------------------------------------------------------
function KDTree() constructor {
    root           = undefined; // Ponteiro para o nó raiz (nível 0, corta em X)
    next_id        = 1;         // Gerador sequencial de IDs para novos nós
    last_checks    = 0;         // Contador de nós visitados na última busca (prova a poda)
    total_nodes    = 0;         // Total de nós únicos presentes na árvore
    balance_info   = undefined; // Struct com métricas da última reconstrução pela mediana
    last_op_log    = "Radar k-D inicializado."; // Mensagem de status exibida no rodapé

    // =========================================================================
    // FUNÇÃO: insert(_px, _py)
    // DESCRIÇÃO: Ponto de entrada público para inserir uma nova coordenada.
    // COMPLEXIDADE: O(log N) no caso médio | O(N) se inserido em ordem (diagonal).
    // =========================================================================
    function insert(_px, _py) {
        root = _insert_rec(root, _px, _py, 0); // Inicia recursão na raiz (profundidade 0)
        total_nodes = binary_tree_count(root); // Reconta total de nós ativos
        binary_tree_layout(root);              // Recalcula posições visuais no painel direito
    }
    
    // =========================================================================
    // FUNÇÃO: _insert_rec(_node, _px, _py, _depth)
    // DESCRIÇÃO: Percorre recursivamente a árvore alternando X e Y a cada nível.
    // =========================================================================
    function _insert_rec(_node, _px, _py, _depth) {
        var _axis = _depth mod 2; // Profundidade par -> Eixo 0 (X); ímpar -> Eixo 1 (Y)
        
        // Caso base: chegou em um ponteiro vazio, cria e retorna a nova folha
        if (_node == undefined) {
            var _new_node = new KDNode(_px, _py, _axis, next_id);
            next_id += 1;
            return _new_node;
        }
        
        // Se já existe um nó a menos de 4 pixels, agrupa como repetido [xN]
        if (point_distance(_node.px, _node.py, _px, _py) < 4) {
            _node.count += 1;
            array_push(_node.duplicates, { px: _px, py: _py });
            return _node;
        }
        
        // Compara apenas a coordenada correspondente ao eixo da profundidade atual
        var _go_left = (_axis == 0) ? (_px < _node.px) : (_py < _node.py);
        
        if (_go_left) _node.left  = _insert_rec(_node.left,  _px, _py, _depth + 1);
        else          _node.right = _insert_rec(_node.right, _px, _py, _depth + 1);
        
        return _node;
    }

    // =========================================================================
    // FUNÇÃO: balance()
    // DESCRIÇÃO: Executa o Balanceamento Estático pela Mediana.
    // POR QUE NÃO USA ROTAÇÃO? Rotações alterariam o nível dos nós e quebrariam
    // a alternância obrigatória entre cortes X e Y.
    // COMPLEXIDADE: O(N log² N) devido à ordenação por nível.
    // =========================================================================
    function balance() {
        if (root == undefined) return;
        
        var _nodes_list = [];
        _collect_nodes(root, _nodes_list); // 1. Extrai todos os nós para um array linear
        
        var _old_h = get_height(root);          // Guarda altura antes de balancear
        root = _build_balanced(_nodes_list, 0); // 2. Reconstrói escolhendo a mediana por nível
        var _new_h = get_height(root);          // Guarda altura otimizada após balancear
        
        // Armazena dados do pivô raiz para exibir no Inspetor de Balanceamento
        balance_info = {
            pivot_id: root.key,
            pivot_px: round(root.px),
            pivot_py: round(root.py),
            left_count: binary_tree_count(root.left),
            right_count: binary_tree_count(root.right),
            old_h: _old_h,
            new_h: _new_h
        };
        
        total_nodes = binary_tree_count(root);
        binary_tree_layout(root);
        last_op_log = "BALANCEADA PELA MEDIANA! Raiz: Nó #" + string(root.key) + " (X=" + string(round(root.px)) + ") | Altura: " + string(_old_h) + " -> " + string(_new_h);
    }
    
    // =========================================================================
    // FUNÇÃO: _collect_nodes(_node, _list)
    // DESCRIÇÃO: Travessia em-ordem que coleta as referências de todos os nós.
    // =========================================================================
    function _collect_nodes(_node, _list) {
        if (_node == undefined) return;
        _collect_nodes(_node.left, _list);
        array_push(_list, _node);
        _collect_nodes(_node.right, _list);
    }
    
    // =========================================================================
    // FUNÇÃO: _build_balanced(_list, _depth)
    // DESCRIÇÃO: Ordena o subconjunto pelo eixo ativo, elege o elemento central
    //            (mediana) como raiz e repete recursivamente para as duas metades.
    // =========================================================================
    function _build_balanced(_list, _depth) {
        var _len = array_length(_list);
        if (_len == 0) return undefined; // Sublista vazia -> ponteiro folha nulo
        
        var _axis = _depth mod 2; // Define se ordena por X (0) ou Y (1)
        
        if (_axis == 0) {
            array_sort(_list, function(_a, _b) { return _a.px - _b.px; });
        } else {
            array_sort(_list, function(_a, _b) { return _a.py - _b.py; });
        }
        
        var _mid   = _len div 2;   // Índice exato da mediana
        var _pivot = _list[_mid];  // Nó central vira a raiz deste quadrante
        _pivot.axis = _axis;       // Atualiza o eixo de corte do pivô para o novo nível
        
        // Divide os elementos restantes em sublista esquerda (< mediana) e direita (> mediana)
        var _left_list  = [];
        var _right_list = [];
        for (var i = 0; i < _mid; i++) array_push(_left_list, _list[i]);
        for (var i = _mid + 1; i < _len; i++) array_push(_right_list, _list[i]);
        
        // Constrói recursivamente os filhos no próximo nível (_depth + 1)
        _pivot.left  = _build_balanced(_left_list,  _depth + 1);
        _pivot.right = _build_balanced(_right_list, _depth + 1);
        return _pivot;
    }
    
    // =========================================================================
    // FUNÇÃO: is_balanced()
    // DESCRIÇÃO: Verifica se a altura atual está próxima do ideal logarítmico.
    // =========================================================================
    function is_balanced() {
        if (total_nodes <= 2) return true;
        var _current_h = get_height(root);
        var _ideal_max = ceil(log2(total_nodes + 1)) + 1;
        return (_current_h <= _ideal_max);
    }

    // =========================================================================
    // FUNÇÃO: find_nearest(_qx, _qy)
    // DESCRIÇÃO: Busca o inimigo mais próximo da nave (_qx, _qy) em O(log N).
    // =========================================================================
    function find_nearest(_qx, _qy) {
        last_checks = 0; // Zera o contador de nós inspecionados
        var _state = { best_node: undefined, best_dist: 999999 };
        _nearest_rec(root, _qx, _qy, _state);
        return _state.best_node;
    }
    
    // =========================================================================
    // FUNÇÃO: _nearest_rec(_node, _qx, _qy, _state)
    // DESCRIÇÃO: Desce pelo lado onde o jogador está e aplica PODA ESPACIAL
    //            para evitar visitar o lado oposto quando ele está longe demais.
    // =========================================================================
    function _nearest_rec(_node, _qx, _qy, _state) {
        if (_node == undefined) return;
        last_checks += 1; // Contabiliza que este nó foi visitado
        
        // Calcula distância euclidiana real até o nó atual e atualiza o recorde
        var _d = point_distance(_qx, _qy, _node.px, _node.py);
        if (_d < _state.best_dist) {
            _state.best_dist = _d;
            _state.best_node = _node;
        }
        
        // Distância perpendicular assinada até a linha de corte (hiperplano)
        var _diff = (_node.axis == 0) ? (_qx - _node.px) : (_qy - _node.py);
        
        // Prioriza o ramo que contém o jogador (_near_branch)
        var _near_branch = (_diff < 0) ? _node.left  : _node.right;
        var _far_branch  = (_diff < 0) ? _node.right : _node.left;
        
        _nearest_rec(_near_branch, _qx, _qy, _state);
        
        // PODA ESPACIAL: Só entra no ramo distante se a linha de corte cruzar
        // o círculo da menor distância encontrada até agora!
        if (abs(_diff) < _state.best_dist) {
            _nearest_rec(_far_branch, _qx, _qy, _state);
        }
    }

    // =========================================================================
    // FUNÇÃO: remove_point(_target_node)
    // DESCRIÇÃO: Remove um ponto mantendo a propriedade de corte dos eixos.
    // =========================================================================
    function remove_point(_target_node) {
        if (_target_node == undefined || root == undefined) return;
        root = _remove_rec(root, _target_node.px, _target_node.py, 0);
        total_nodes = binary_tree_count(root);
        binary_tree_layout(root);
    }
    
    // =========================================================================
    // FUNÇÃO: _find_min_dim(_node, _dim, _depth)
    // DESCRIÇÃO: Encontra o nó substituto com menor valor na dimensão _dim.
    // =========================================================================
    function _find_min_dim(_node, _dim, _depth) {
        if (_node == undefined) return undefined;
        var _cur_axis = _depth mod 2;
        
        // Se o nó atual corta na dimensão buscada, o mínimo está sempre à esquerda
        if (_cur_axis == _dim) {
            if (_node.left == undefined) return _node;
            return _find_min_dim(_node.left, _dim, _depth + 1);
        }
        
        // Caso contrário, precisa comparar o nó atual com ambos os filhos
        var _l_min = _find_min_dim(_node.left,  _dim, _depth + 1);
        var _r_min = _find_min_dim(_node.right, _dim, _depth + 1);
        var _best  = _node;
        
        if (_l_min != undefined && ((_dim == 0 && _l_min.px < _best.px) || (_dim == 1 && _l_min.py < _best.py))) _best = _l_min;
        if (_r_min != undefined && ((_dim == 0 && _r_min.px < _best.px) || (_dim == 1 && _r_min.py < _best.py))) _best = _r_min;
        return _best;
    }
    
    // =========================================================================
    // FUNÇÃO: _remove_rec(_node, _tx, _ty, _depth)
    // DESCRIÇÃO: Localiza o alvo e o substitui pelo mínimo da subárvore direita
    //            (ou esquerda, movendo-a para a direita) no mesmo eixo.
    // =========================================================================
    function _remove_rec(_node, _tx, _ty, _depth) {
        if (_node == undefined) return undefined;
        var _axis = _depth mod 2;
        
        if (abs(_node.px - _tx) < 1 && abs(_node.py - _ty) < 1) {
            // Se houver réplicas agrupadas [xN], apenas reduz o contador
            if (_node.count > 1) {
                _node.count -= 1;
                array_pop(_node.duplicates);
                return _node;
            }
            // Substitui pelo menor elemento na dimensão _axis da subárvore direita
            if (_node.right != undefined) {
                var _min_n = _find_min_dim(_node.right, _axis, _depth + 1);
                _node.px = _min_n.px; _node.py = _min_n.py; _node.key = _min_n.key;
                _node.count = _min_n.count; _node.duplicates = _min_n.duplicates;
                _min_n.count = 1;
                _node.right = _remove_rec(_node.right, _min_n.px, _min_n.py, _depth + 1);
            } else if (_node.left != undefined) {
                // Se só tem esquerda, promove o mínimo da esquerda e transfere a subárvore
                var _min_l = _find_min_dim(_node.left, _axis, _depth + 1);
                _node.px = _min_l.px; _node.py = _min_l.py; _node.key = _min_l.key;
                _node.count = _min_l.count; _node.duplicates = _min_l.duplicates;
                _min_l.count = 1;
                _node.right = _remove_rec(_node.left, _min_l.px, _min_l.py, _depth + 1);
                _node.left = undefined;
            } else {
                return undefined; // Nó folha removido
            }
            return _node;
        }
        
        var _go_left = (_axis == 0) ? (_tx < _node.px) : (_ty < _node.py);
        if (_go_left) _node.left  = _remove_rec(_node.left,  _tx, _ty, _depth + 1);
        else          _node.right = _remove_rec(_node.right, _tx, _ty, _depth + 1);
        return _node;
    }

    // =========================================================================
    // FUNÇÃO: get_height(_node)
    // DESCRIÇÃO: Calcula recursivamente a altura máxima da árvore.
    // =========================================================================
    function get_height(_node) {
        if (_node == undefined) return 0;
        return 1 + max(get_height(_node.left), get_height(_node.right));
    }
    
    // =========================================================================
    // FUNÇÃO: draw_hyperplanes(_node, _x1, _y1, _x2, _y2)
    // DESCRIÇÃO: Desenha na arena os cortes X (vermelho) e Y (azul) delimitados
    //            pelas bordas do sub-quadrante de cada nó.
    // =========================================================================
    function draw_hyperplanes(_node, _x1, _y1, _x2, _y2) {
        if (_node == undefined) return;
        
        if (_node.axis == 0) {
            // Linha vertical (corte em X) limitada de _y1 até _y2
            draw_set_color(make_color_rgb(220, 60, 60));
            draw_set_alpha(0.45);
            draw_line(_node.px, _y1, _node.px, _y2);
            draw_set_alpha(1.0);
            
            draw_hyperplanes(_node.left,  _x1,      _y1, _node.px, _y2);
            draw_hyperplanes(_node.right, _node.px, _y1, _x2,      _y2);
        } else {
            // Linha horizontal (corte em Y) limitada de _x1 até _x2
            draw_set_color(make_color_rgb(60, 140, 255));
            draw_set_alpha(0.45);
            draw_line(_x1, _node.py, _x2, _node.py);
            draw_set_alpha(1.0);
            
            draw_hyperplanes(_node.left,  _x1, _y1,      _x2, _node.py);
            draw_hyperplanes(_node.right, _x1, _node.py, _x2, _y2);
        }
        
        // Desenha o círculo do inimigo (destacando a raiz em amarelo) e seu ID
        draw_set_color((_node == root) ? c_yellow : c_orange);
        draw_circle(_node.px, _node.py, (_node == root) ? 10 : 8, false);
        draw_set_color(c_white);
        var _tag = string(_node.key) + (_node.count > 1 ? " [x" + string(_node.count) + "]" : "");
        draw_text(_node.px + 10, _node.py - 8, _tag);
    }
}