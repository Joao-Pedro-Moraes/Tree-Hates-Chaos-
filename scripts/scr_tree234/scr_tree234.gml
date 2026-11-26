/// ============================================================================
/// SCRIPT: scr_tree234
/// ESTRUTURA: Árvore Não-Binária 2-3-4 (B-Tree de Ordem M = 4)
/// OBJETIVO: Armazenar de 1 a 3 chaves ordenadas por nó e até 4 filhos,
///           crescendo de baixo para cima via Splits e mantendo todas as
///           folhas exatamente na mesma profundidade (altura uniforme).
/// ============================================================================

/// ----------------------------------------------------------------------------
/// CONSTRUTOR: Node234(_is_leaf)
/// DESCRIÇÃO: Cria uma "prateleira" multi-chaves capaz de atuar como:
///            - 2-nó (1 chave, 2 filhos)
///            - 3-nó (2 chaves, 3 filhos)
///            - 4-nó (3 chaves, 4 filhos -> cheio, sofre Split)
/// ----------------------------------------------------------------------------
function Node234(_is_leaf) constructor {
    is_leaf  = _is_leaf; // true se for nó folha, false se for nó interno
    keys     = [];       // Array dinâmico com 1 a 3 valores em Ouro ordenados
    counts   = [];       // Quantidade de itens empilhados em cada chave [xN]
    items    = [];       // Lista de nomes de itens por chave
    children = [];       // Ponteiros para até 4 subárvores filhas
    
    // Coordenadas de renderização da caixa multi-chaves no Inspetor
    x        = 1015;
    y        = 80;
    target_x = 1015;
    target_y = 80;
    box_w    = 44;       // Largura proporcional ao número de chaves no nó
    
    function num_keys() { return array_length(keys); }      // Retorna 1, 2 ou 3
    function is_full()  { return array_length(keys) >= 3; } // true se for um 4-nó cheio
}

/// ----------------------------------------------------------------------------
/// CONSTRUTOR: Tree234()
/// DESCRIÇÃO: Gerencia busca multi-caminhos, Preemptive Splits, Redistribuição
///            e Merge (fusão) no underflow.
/// ----------------------------------------------------------------------------
function Tree234() constructor {
    root           = new Node234(true); // Inicia com uma folha vazia
    total_keys     = 0;                 // Total de chaves únicas no inventário
    split_count    = 0;                 // Contador de cisões (Splits) realizadas
    merge_count    = 0;                 // Contador de fusões (Merges) realizadas
    last_event     = undefined;         // Struct com detalhes do último Split/Merge
    last_op_log    = "Inventário 2-3-4 inicializado.";

    // =========================================================================
    // FUNÇÃO: search(_node, _gold)
    // DESCRIÇÃO: Localiza uma chave comparando-a contra as 1..3 chaves do nó
    //            e descendo pelo ponteiro de intervalo correspondente.
    // COMPLEXIDADE: O(log N)
    // =========================================================================
    function search(_node, _gold) {
        if (_node == undefined) return undefined;
        var _i = 0;
        var _n = _node.num_keys();
        
        // Avança enquanto a chave buscada for maior que a chave na posição _i
        while (_i < _n && _gold > _node.keys[_i]) _i += 1;
        
        // Se encontrou a chave exata neste nó, retorna o nó e o índice dela
        if (_i < _n && _gold == _node.keys[_i]) return { node: _node, index: _i };
        
        // Se chegou em uma folha e não achou, o item não existe
        if (_node.is_leaf) return undefined;
        
        // Desce pelo filho _i (entre keys[_i-1] e keys[_i])
        return search(_node.children[_i], _gold);
    }

    // =========================================================================
    // FUNÇÃO: insert(_gold, _item_name)
    // DESCRIÇÃO: Insere um item usando PREEMPTIVE SPLITS (divide qualquer 4-nó
    //            encontrado já no caminho de descida, antes de chegar à folha).
    // COMPLEXIDADE: O(log N)
    // =========================================================================
    function insert(_gold, _item_name) {
        // 1. Verifica se o preço já existe para empilhar [xN] (Política de Repetidos)
        var _existing = search(root, _gold);
        if (_existing != undefined) {
            var _idx = _existing.index;
            _existing.node.counts[_idx] += 1;
            array_push(_existing.node.items[_idx], _item_name);
            last_op_log = "Item repetido (" + string(_gold) + "g): empilhado [x" + string(_existing.node.counts[_idx]) + "].";
            return;
        }
        
        var _r = root;
        last_op_log = "Inserido '" + _item_name + "' (" + string(_gold) + "g).";
        
        // 2. Se a raiz está cheia (3 chaves), cria uma nova raiz vazia acima dela,
        //    divide a antiga raiz e aumenta a altura da árvore por cima!
        if (_r.is_full()) {
            var _s = new Node234(false);
            root = _s;
            array_push(_s.children, _r);
            _split_child(_s, 0);
            _insert_non_full(_s, _gold, _item_name);
        } else {
            _insert_non_full(_r, _gold, _item_name);
        }
        
        total_keys = count_keys(root);
        layout();
    }

    // =========================================================================
    // FUNÇÃO: _split_child(_parent, _child_idx)
    // DESCRIÇÃO: Divide o filho cheio _y [k0 | k1 | k2] em dois 2-nós [k0] e [k2],
    //            promovendo a chave mediana k1 para dentro do nó pai _parent.
    // =========================================================================
    function _split_child(_parent, _child_idx) {
        split_count += 1;
        var _y = _parent.children[_child_idx]; // 4-nó cheio que será dividido
        var _z = new Node234(_y.is_leaf);      // Novo nó irmão à direita
        
        var _k0 = _y.keys[0];
        var _k1 = _y.keys[1]; // Mediana que vai subir
        var _k2 = _y.keys[2];
        
        // Move a maior chave (k2) para o novo irmão _z
        array_push(_z.keys,   _y.keys[2]);
        array_push(_z.counts, _y.counts[2]);
        array_push(_z.items,  _y.items[2]);
        
        // Se não for folha, transfere os 2 filhos da direita para _z
        if (!_y.is_leaf) {
            array_push(_z.children, _y.children[2]);
            array_push(_z.children, _y.children[3]);
            array_resize(_y.children, 2);
        }
        
        var _mid_key   = _y.keys[1];
        var _mid_count = _y.counts[1];
        var _mid_items = _y.items[1];
        
        // Mantém apenas a menor chave (k0) no nó original _y
        array_resize(_y.keys,   1);
        array_resize(_y.counts, 1);
        array_resize(_y.items,  1);
        
        // Insere o novo irmão _z e a mediana promovida dentro do pai _parent
        array_insert(_parent.children, _child_idx + 1, _z);
        array_insert(_parent.keys,     _child_idx,     _mid_key);
        array_insert(_parent.counts,   _child_idx,     _mid_count);
        array_insert(_parent.items,    _child_idx,     _mid_items);
        
        // Registra o evento para exibir no Inspetor de Balanceamento
        last_event = {
            type: "PREEMPTIVE SPLIT (CISÃO DE 4-NÓ)",
            detail: "Nó cheio [" + string(_k0) + " | " + string(_k1) + " | " + string(_k2) + "] dividido em [" + string(_k0) + "] e [" + string(_k2) + "]",
            promoted: "Mediana " + string(_mid_key) + "g promovida ao nó pai!",
            highlight_node: _parent
        };
        last_op_log += " -> SPLIT! Mediana " + string(_mid_key) + "g subiu para o pai.";
    }

    // =========================================================================
    // FUNÇÃO: _insert_non_full(_x, _gold, _item_name)
    // DESCRIÇÃO: Desce até a folha garantindo que nenhum nó no caminho esteja cheio.
    // =========================================================================
    function _insert_non_full(_x, _gold, _item_name) {
        var _i = _x.num_keys() - 1;
        
        if (_x.is_leaf) {
            // Desloca chaves maiores e insere ordenadamente na folha
            while (_i >= 0 && _gold < _x.keys[_i]) _i -= 1;
            array_insert(_x.keys,   _i + 1, _gold);
            array_insert(_x.counts, _i + 1, 1);
            array_insert(_x.items,  _i + 1, [_item_name]);
        } else {
            while (_i >= 0 && _gold < _x.keys[_i]) _i -= 1;
            _i += 1;
            // Se o filho onde vamos entrar já é um 4-nó cheio, divide antes de descer!
            if (_x.children[_i].is_full()) {
                _split_child(_x, _i);
                if (_gold > _x.keys[_i]) _i += 1;
            }
            _insert_non_full(_x.children[_i], _gold, _item_name);
        }
    }

    // =========================================================================
    // FUNÇÃO: find_full_node(_node)
    // DESCRIÇÃO: Localiza qualquer 4-nó dourado na árvore (usado pelo botão [B]).
    // =========================================================================
    function find_full_node(_node) {
        if (_node == undefined) return undefined;
        if (_node.is_full()) return _node;
        for (var i = 0; i < array_length(_node.children); i++) {
            var _res = find_full_node(_node.children[i]);
            if (_res != undefined) return _res;
        }
        return undefined;
    }

    // =========================================================================
    // FUNÇÃO: get_min_key()
    // DESCRIÇÃO: Retorna o item mais barato (primeira chave da folha mais à esquerda).
    // =========================================================================
    function get_min_key() {
        var _curr = root;
        if (_curr == undefined || _curr.num_keys() == 0) return undefined;
        while (!_curr.is_leaf) _curr = _curr.children[0];
        return _curr.keys[0];
    }

    // =========================================================================
    // FUNÇÃO: remove_key(_gold)
    // DESCRIÇÃO: Remove uma chave evitando underflow via Redistribuição ou Merge.
    // COMPLEXIDADE: O(log N)
    // =========================================================================
    function remove_key(_gold) {
        if (root == undefined || root.num_keys() == 0) return;
        var _found = search(root, _gold);
        if (_found == undefined) return;
        
        // Se o item estiver empilhado [xN], apenas reduz a quantidade
        if (_found.node.counts[_found.index] > 1) {
            _found.node.counts[_found.index] -= 1;
            array_pop(_found.node.items[_found.index]);
            last_op_log = "Vendido 1 unidade de " + string(_gold) + "g (restam x" + string(_found.node.counts[_found.index]) + ").";
            return;
        }
        
        last_op_log = "Removido item de " + string(_gold) + "g.";
        _remove_rec(root, _gold);
        
        // Se a raiz ficou vazia após um Merge, seu único filho vira a nova raiz
        if (root.num_keys() == 0 && !root.is_leaf) {
            root = root.children[0];
            last_op_log += " -> Raiz fundida (altura diminuiu)!";
        }
        
        total_keys = count_keys(root);
        layout();
    }

    // =========================================================================
    // FUNÇÃO: _remove_rec(_x, _k)
    // DESCRIÇÃO: Executa a remoção recursiva garantindo que cada nó visitado
    //            tenha pelo menos 2 chaves antes de descer.
    // =========================================================================
    function _remove_rec(_x, _k) {
        var _idx = 0;
        while (_idx < _x.num_keys() && _x.keys[_idx] < _k) _idx += 1;
        
        // Caso A: A chave está neste nó _x
        if (_idx < _x.num_keys() && _x.keys[_idx] == _k) {
            if (_x.is_leaf) {
                array_delete(_x.keys,   _idx, 1);
                array_delete(_x.counts, _idx, 1);
                array_delete(_x.items,  _idx, 1);
            } else {
                var _left_c  = _x.children[_idx];
                var _right_c = _x.children[_idx + 1];
                if (_left_c.num_keys() >= 2) {
                    // Substitui pelo predecessor na subárvore esquerda
                    var _pred = _left_c;
                    while (!_pred.is_leaf) _pred = _pred.children[_pred.num_keys()];
                    var _last_i = _pred.num_keys() - 1;
                    _x.keys[_idx] = _pred.keys[_last_i]; _x.counts[_idx] = _pred.counts[_last_i]; _x.items[_idx] = _pred.items[_last_i];
                    _pred.counts[_last_i] = 1;
                    _remove_rec(_left_c, _pred.keys[_last_i]);
                } else if (_right_c.num_keys() >= 2) {
                    // Substitui pelo sucessor na subárvore direita
                    var _succ = _right_c;
                    while (!_succ.is_leaf) _succ = _succ.children[0];
                    _x.keys[_idx] = _succ.keys[0]; _x.counts[_idx] = _succ.counts[0]; _x.items[_idx] = _succ.items[0];
                    _succ.counts[0] = 1;
                    _remove_rec(_right_c, _succ.keys[0]);
                } else {
                    // Ambos os filhos adjacentes são 2-nós -> Funde ambos (Merge)
                    _merge_children(_x, _idx);
                    _remove_rec(_left_c, _k);
                }
            }
        } else {
            // Caso B: A chave está em uma subárvore filha
            if (_x.is_leaf) return;
            var _is_last = (_idx == _x.num_keys());
            // Se o filho alvo tem apenas 1 chave, reforça-o antes de descer
            if (_x.children[_idx].num_keys() < 2) _fill_child(_x, _idx);
            if (_is_last && _idx > _x.num_keys()) _remove_rec(_x.children[_idx - 1], _k);
            else _remove_rec(_x.children[_idx], _k);
        }
    }

    // =========================================================================
    // FUNÇÃO: _fill_child(_x, _idx)
    // DESCRIÇÃO: Evita underflow pedindo uma chave emprestada ao irmão
    //            (Redistribuição) ou fundindo dois irmãos (Merge).
    // =========================================================================
    function _fill_child(_x, _idx) {
        if (_idx != 0 && _x.children[_idx - 1].num_keys() >= 2) {
            // Redistribuição à Direita (empresta do irmão esquerdo via pai)
            var _child = _x.children[_idx];
            var _sib   = _x.children[_idx - 1];
            var _s_last = _sib.num_keys() - 1;
            
            array_insert(_child.keys, 0, _x.keys[_idx - 1]);
            array_insert(_child.counts, 0, _x.counts[_idx - 1]);
            array_insert(_child.items, 0, _x.items[_idx - 1]);
            if (!_child.is_leaf) {
                array_insert(_child.children, 0, _sib.children[_s_last + 1]);
                array_delete(_sib.children, _s_last + 1, 1);
            }
            _x.keys[_idx - 1] = _sib.keys[_s_last]; _x.counts[_idx - 1] = _sib.counts[_s_last]; _x.items[_idx - 1] = _sib.items[_s_last];
            array_delete(_sib.keys, _s_last, 1); array_delete(_sib.counts, _s_last, 1); array_delete(_sib.items, _s_last, 1);
            
            last_event = {
                type: "REDISTRIBUIÇÃO (ROTAÇÃO DE CHAVE)",
                detail: "Filho evitou underflow pedindo chave emprestada ao irmão esquerdo",
                promoted: "Chave " + string(_x.keys[_idx - 1]) + "g subiu ao pai para manter equilíbrio!",
                highlight_node: _child
            };
            last_op_log += " -> REDISTRIBUIÇÃO!";
        } else if (_idx != _x.num_keys() && _x.children[_idx + 1].num_keys() >= 2) {
            // Redistribuição à Esquerda (empresta do irmão direito via pai)
            var _child = _x.children[_idx];
            var _sib   = _x.children[_idx + 1];
            
            array_push(_child.keys, _x.keys[_idx]); array_push(_child.counts, _x.counts[_idx]); array_push(_child.items, _x.items[_idx]);
            if (!_child.is_leaf) {
                array_push(_child.children, _sib.children[0]);
                array_delete(_sib.children, 0, 1);
            }
            _x.keys[_idx] = _sib.keys[0]; _x.counts[_idx] = _sib.counts[0]; _x.items[_idx] = _sib.items[0];
            array_delete(_sib.keys, 0, 1); array_delete(_sib.counts, 0, 1); array_delete(_sib.items, 0, 1);
            
            last_event = {
                type: "REDISTRIBUIÇÃO (ROTAÇÃO DE CHAVE)",
                detail: "Filho evitou underflow pedindo chave emprestada ao irmão direito",
                promoted: "Chave " + string(_x.keys[_idx]) + "g subiu ao pai para manter equilíbrio!",
                highlight_node: _child
            };
            last_op_log += " -> REDISTRIBUIÇÃO!";
        } else {
            // Nenhum irmão tem chaves extras -> Executa Merge (Fusão)
            if (_idx != _x.num_keys()) _merge_children(_x, _idx);
            else _merge_children(_x, _idx - 1);
        }
    }

    // =========================================================================
    // FUNÇÃO: _merge_children(_x, _idx)
    // DESCRIÇÃO: Funde dois 2-nós filhos e a chave separadora do pai em um 4-nó.
    // =========================================================================
    function _merge_children(_x, _idx) {
        merge_count += 1;
        var _child = _x.children[_idx];
        var _sib   = _x.children[_idx + 1];
        var _down_k = _x.keys[_idx];
        
        // Desce a chave do pai para _child
        array_push(_child.keys, _x.keys[_idx]); array_push(_child.counts, _x.counts[_idx]); array_push(_child.items, _x.items[_idx]);
        // Incorpora todas as chaves e filhos do irmão _sib
        for (var i = 0; i < _sib.num_keys(); i++) {
            array_push(_child.keys, _sib.keys[i]); array_push(_child.counts, _sib.counts[i]); array_push(_child.items, _sib.items[i]);
        }
        if (!_child.is_leaf) {
            for (var i = 0; i < array_length(_sib.children); i++) array_push(_child.children, _sib.children[i]);
        }
        // Remove a chave separadora e o ponteiro para _sib do nó pai
        array_delete(_x.keys, _idx, 1); array_delete(_x.counts, _idx, 1); array_delete(_x.items, _idx, 1);
        array_delete(_x.children, _idx + 1, 1);
        
        last_event = {
            type: "MERGE (FUSÃO DE NÓS)",
            detail: "Dois 2-nós fundidos com a chave " + string(_down_k) + "g que desceu do pai",
            promoted: "Novo 4-nó formado mantendo todas as folhas no mesmo nível!",
            highlight_node: _child
        };
        last_op_log += " -> MERGE (Fusão)!";
    }

    // =========================================================================
    // FUNÇÕES DE MÉTRICAS, LAYOUT E RENDERIZAÇÃO MULTI-CHAVE
    // =========================================================================
    function count_keys(_node) {
        if (_node == undefined) return 0;
        var _sum = _node.num_keys();
        for (var i = 0; i < array_length(_node.children); i++) _sum += count_keys(_node.children[i]);
        return _sum;
    }

    function get_height() {
        // Como todas as folhas têm a mesma profundidade, basta descer pelo filho 0
        var _h = 0;
        var _curr = root;
        while (_curr != undefined && _curr.num_keys() > 0) {
            _h += 1;
            if (_curr.is_leaf) break;
            _curr = _curr.children[0];
        }
        return _h;
    }

    function layout() {
        // Distribui as folhas uniformemente no painel direito e centraliza os pais
        if (root == undefined || root.num_keys() == 0) return;
        var _leaves = _count_leaves(root);
        var _state = { leaf_idx: 0, total_leaves: max(1, _leaves) };
        _layout_rec(root, 0, _state);
    }

    function _count_leaves(_node) {
        if (_node.is_leaf) return 1;
        var _c = 0;
        for (var i = 0; i < array_length(_node.children); i++) _c += _count_leaves(_node.children[i]);
        return _c;
    }

    function _layout_rec(_node, _depth, _state) {
        _node.box_w = max(36, _node.num_keys() * 34);
        _node.target_y = 95 + _depth * 115;
        if (_node.is_leaf) {
            var _usable_w = 450;
            var _step = (_state.total_leaves > 1) ? (_usable_w / (_state.total_leaves - 1)) : 0;
            _node.target_x = (_state.total_leaves == 1) ? 1020 : (795 + _state.leaf_idx * _step);
            _state.leaf_idx += 1;
        } else {
            var _first_x = 0, _last_x = 0;
            var _num_c = array_length(_node.children);
            for (var i = 0; i < _num_c; i++) {
                _layout_rec(_node.children[i], _depth + 1, _state);
                if (i == 0) _first_x = _node.children[i].target_x;
                if (i == _num_c - 1) _last_x = _node.children[i].target_x;
            }
            _node.target_x = (_first_x + _last_x) * 0.5;
        }
    }

    function draw_tree(_node, _highlight_key) {
        if (_node == undefined || _node.num_keys() == 0) return;
        // Interpola suavemente a posição visual do nó (efeito de animação)
        _node.x = lerp(_node.x, _node.target_x, 0.15);
        _node.y = lerp(_node.y, _node.target_y, 0.15);
        
        var _num_c = array_length(_node.children);
        for (var i = 0; i < _num_c; i++) {
            var _c = _node.children[i];
            _c.x = lerp(_c.x, _c.target_x, 0.15);
            _c.y = lerp(_c.y, _c.target_y, 0.15);
            var _port_x = _node.x - (_node.box_w * 0.4) + (i / max(1, _num_c - 1)) * (_node.box_w * 0.8);
            if (_num_c == 1) _port_x = _node.x;
            draw_set_color(c_gray);
            draw_line_width(_port_x, _node.y + 15, _c.x, _c.y - 15, 2);
            draw_tree(_c, _highlight_key);
        }
        
        // Define a cor da caixa conforme a quantidade de chaves:
        // Azul = 2-nó (1 chave) | Verde = 3-nó (2 chaves) | Dourado = 4-nó (3 chaves)
        var _nk = _node.num_keys();
        var _bg_col = make_color_rgb(45, 95, 165);
        if (_nk == 2) _bg_col = make_color_rgb(45, 145, 110);
        if (_nk == 3) _bg_col = make_color_rgb(185, 115, 35);
        
        var _x1 = _node.x - _node.box_w * 0.5;
        var _y1 = _node.y - 15;
        var _x2 = _node.x + _node.box_w * 0.5;
        var _y2 = _node.y + 15;
        
        var _is_hl = (last_event != undefined && last_event.highlight_node == _node);
        
        draw_set_color(_bg_col);
        draw_rectangle(_x1, _y1, _x2, _y2, false);
        draw_set_color(_is_hl ? c_yellow : c_white);
        draw_rectangle(_x1 - (_is_hl ? 2 : 0), _y1 - (_is_hl ? 2 : 0), _x2 + (_is_hl ? 2 : 0), _y2 + (_is_hl ? 2 : 0), true);
        
        // Desenha cada compartimento interno e o valor da chave
        var _cell_w = _node.box_w / _nk;
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        for (var k = 0; k < _nk; k++) {
            var _cx = _x1 + (k + 0.5) * _cell_w;
            if (k > 0) {
                draw_set_color(c_white);
                draw_line(_x1 + k * _cell_w, _y1, _x1 + k * _cell_w, _y2);
            }
            draw_set_color((_node.keys[k] == _highlight_key) ? c_yellow : c_white);
            var _lbl = string(_node.keys[k]);
            if (_node.counts[k] > 1) _lbl += "x" + string(_node.counts[k]);
            draw_text(_cx, _node.y, _lbl);
        }
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}