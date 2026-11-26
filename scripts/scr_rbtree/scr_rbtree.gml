/// ============================================================================
/// SCRIPT: scr_rbtree
/// ESTRUTURA: Árvore Binária Rubro-Negra (Red-Black Tree)
/// OBJETIVO: Garantir busca, inserção e remoção em O(log N) no pior caso através
///           de cores (RED/BLACK) e rotações locais baseadas em Pai, Tio e Avô.
/// ============================================================================

/// ----------------------------------------------------------------------------
/// CONSTRUTOR: RBNode(_agro_key, _monster_name)
/// DESCRIÇÃO: Cria um nó de monstro indexado pelo seu nível de ameaça (Agro).
/// ----------------------------------------------------------------------------
function RBNode(_agro_key, _monster_name) constructor {
    key    = _agro_key;       // Chave numérica de ordenação (nível de Agro)
    color  = "RED";           // Todo nó recém-inserido nasce VERMELHO
    
    // Política de repetidos: monstros com mesmo Agro são empilhados no nó
    count    = 1;             // Quantidade de monstros com este Agro
    monsters = [_monster_name]; // Lista de nomes dos monstros agrupados
    
    // Ponteiros topológicos (inclui 'parent' para subir até Tio e Avô em O(1))
    left   = undefined;       // Filho esquerdo (Agro menor)
    right  = undefined;       // Filho direito (Agro maior)
    parent = undefined;       // Ponteiro para o nó Pai
    
    // Coordenadas de renderização no Inspetor Topológico
    x        = 1015;
    y        = 80;
    target_x = 1015;
    target_y = 80;
}

/// ----------------------------------------------------------------------------
/// CONSTRUTOR: RBTree()
/// DESCRIÇÃO: Gerencia rotações, recolorações, modo passo a passo [B] e remoção.
/// ----------------------------------------------------------------------------
function RBTree() constructor {
    root           = undefined; // Ponteiro para a raiz (sempre PRETA)
    total_nodes    = 0;         // Total de nós únicos na árvore
    rotation_count = 0;         // Contador de rotações realizadas
    auto_balance   = false;     // false = pausa no conflito para apertar [B]
    pending_z      = undefined; // Ponteiro para o nó vermelho em conflito atual
    last_op_log    = "Árvore Rubro-Negra pronta.";

    // =========================================================================
    // FUNÇÃO: rotate_left(_x)
    // DESCRIÇÃO: Rotação simples à esquerda em torno de _x em O(1).
    //            O filho direito _y sobe para o lugar de _x, e _x desce à esquerda.
    // =========================================================================
    function rotate_left(_x) {
        if (_x == undefined || _x.right == undefined) return;
        rotation_count += 1;
        
        var _y = _x.right;          // _y será o novo topo da subárvore
        _x.right = _y.left;         // Subárvore esquerda de _y passa a ser direita de _x
        if (_y.left != undefined) _y.left.parent = _x;
        
        _y.parent = _x.parent;      // Conecta _y ao antigo pai de _x
        if (_x.parent == undefined) {
            root = _y;              // Se _x era raiz, _y torna-se a nova raiz
        } else if (_x == _x.parent.left) {
            _x.parent.left = _y;
        } else {
            _x.parent.right = _y;
        }
        
        _y.left = _x;               // _x torna-se filho esquerdo de _y
        _x.parent = _y;
    }

    // =========================================================================
    // FUNÇÃO: rotate_right(_y)
    // DESCRIÇÃO: Rotação simples à direita em torno de _y em O(1).
    //            O filho esquerdo _x sobe para o lugar de _y, e _y desce à direita.
    // =========================================================================
    function rotate_right(_y) {
        if (_y == undefined || _y.left == undefined) return;
        rotation_count += 1;
        
        var _x = _y.left;           // _x será o novo topo da subárvore
        _y.left = _x.right;         // Subárvore direita de _x passa a ser esquerda de _y
        if (_x.right != undefined) _x.right.parent = _y;
        
        _x.parent = _y.parent;      // Conecta _x ao antigo pai de _y
        if (_y.parent == undefined) {
            root = _x;              // Se _y era raiz, _x torna-se a nova raiz
        } else if (_y == _y.parent.right) {
            _y.parent.right = _x;
        } else {
            _y.parent.left = _x;
        }
        
        _x.right = _y;              // _y torna-se filho direito de _x
        _y.parent = _x;
    }

    // =========================================================================
    // FUNÇÃO: insert(_key, _monster_name)
    // DESCRIÇÃO: Insere como em uma BST comum (cor VERMELHA) e dispara ou pausa
    //            a correção de balanceamento conforme a flag 'auto_balance'.
    // COMPLEXIDADE: O(log N)
    // =========================================================================
    function insert(_key, _monster_name) {
        // Se havia um conflito anterior pendente, finaliza antes da nova inserção
        while (pending_z != undefined) {
            balance_step();
        }
        
        var _y = undefined; // Guardará o pai onde o novo nó será conectado
        var _x = root;      // Cursor de descida
        
        while (_x != undefined) {
            _y = _x;
            if (_key == _x.key) {
                // Chave repetida: agrupa internamente sem criar novo nó
                _x.count += 1;
                array_push(_x.monsters, _monster_name);
                last_op_log = "Agro repetido (" + string(_key) + "): agrupado [x" + string(_x.count) + "].";
                return;
            } else if (_key < _x.key) {
                _x = _x.left;
            } else {
                _x = _x.right;
            }
        }
        
        var _z = new RBNode(_key, _monster_name);
        _z.parent = _y;
        
        if (_y == undefined) {
            root = _z;
            root.color = "BLACK"; // Regra 2: A raiz é obrigatoriamente PRETA
            last_op_log = "Raiz " + string(_key) + " inserida (sempre PRETA).";
        } else {
            if (_z.key < _y.key) _y.left = _z;
            else _y.right = _z;
            
            pending_z = _z; // Marca _z para verificação de conflito Vermelho-Vermelho
            
            if (auto_balance) {
                while (pending_z != undefined) balance_step();
            } else {
                if (!has_violation()) {
                    pending_z = undefined;
                    if (root != undefined) root.color = "BLACK";
                    last_op_log = "Inserido " + string(_key) + " (VERMELHO). Sem conflito (Pai Preto).";
                } else {
                    last_op_log = "CONFLITO VERMELHO-VERMELHO em " + string(_key) + "! Compare Pai/Tio/Avô e aperte [B].";
                }
            }
        }
        
        total_nodes = binary_tree_count(root);
        binary_tree_layout(root);
    }

    // =========================================================================
    // FUNÇÃO: has_violation()
    // DESCRIÇÃO: Retorna true se houver dois nós VERMELHOS consecutivos (Pai e Filho).
    // =========================================================================
    function has_violation() {
        if (root != undefined && root.color == "RED") return true;
        if (pending_z != undefined && pending_z != root && pending_z.parent != undefined && pending_z.parent.color == "RED") {
            return true;
        }
        return false;
    }

    // =========================================================================
    // FUNÇÃO: get_family_info()
    // DESCRIÇÃO: Identifica Filho (Z), Pai (P), Tio (U) e Avô (G) do conflito
    //            atual e determina qual dos 3 casos da Rubro-Negra será aplicado.
    // =========================================================================
    function get_family_info() {
        if (pending_z == undefined || !has_violation()) return undefined;
        
        var _z = pending_z;
        var _p = _z.parent;
        var _g = (_p != undefined) ? _p.parent : undefined;
        var _u = undefined;
        
        if (_g != undefined) {
            // O Tio é o outro filho do Avô
            _u = (_p == _g.left) ? _g.right : _g.left;
        }
        
        var _u_color = (_u == undefined) ? "BLACK (NIL)" : _u.color;
        var _case_desc = "";
        
        if (_z == root) {
            _case_desc = "Raiz Vermelha -> Pintar de PRETO";
        } else if (_g != undefined) {
            if (_u != undefined && _u.color == "RED") {
                _case_desc = "CASO 1 (Tio Vermelho) -> Recolorir Pai, Tio e Avô";
            } else if ((_p == _g.left && _z == _p.right) || (_p == _g.right && _z == _p.left)) {
                _case_desc = "CASO 2 (Triângulo / Tio Preto) -> Rotação no PAI";
            } else {
                _case_desc = "CASO 3 (Linha / Tio Preto) -> Rotação no AVÔ + Recolor";
            }
        }
        
        return { z: _z, p: _p, u: _u, g: _g, u_color: _u_color, case_desc: _case_desc };
    }

    // =========================================================================
    // FUNÇÃO: balance_step()
    // DESCRIÇÃO: Executa exatamente 1 etapa de recoloração ou rotação (botão [B]).
    // =========================================================================
    function balance_step() {
        if (pending_z == undefined) {
            if (root != undefined && root.color == "RED") {
                root.color = "BLACK";
                last_op_log = "Raiz convertida para PRETA (Regra 2).";
            } else {
                last_op_log = "Árvore já está perfeitamente balanceada!";
            }
            return;
        }
        
        var _z = pending_z;
        
        // Se chegou na raiz ou o pai já é preto, o conflito acabou
        if (_z == root || _z.parent == undefined || _z.parent.color == "BLACK") {
            if (root != undefined) root.color = "BLACK";
            pending_z = undefined;
            last_op_log = "Balanceamento concluído! Altura Negra preservada.";
            total_nodes = binary_tree_count(root);
            binary_tree_layout(root);
            return;
        }
        
        var _p = _z.parent;
        var _g = _p.parent;
        if (_g == undefined) {
            root.color = "BLACK";
            pending_z = undefined;
            return;
        }
        
        // Ramo Esquerdo: Pai é filho esquerdo do Avô
        if (_p == _g.left) {
            var _uncle = _g.right;
            
            // CASO 1: Tio é VERMELHO -> Apenas recoloração (Pai e Tio = Preto, Avô = Vermelho)
            if (_uncle != undefined && _uncle.color == "RED") {
                _p.color = "BLACK";
                _uncle.color = "BLACK";
                _g.color = "RED";
                pending_z = _g; // Sobe o cursor para verificar se o Avô gerou novo conflito
                last_op_log = "PASSO [Caso 1]: Tio (" + string(_uncle.key) + ") era VERMELHO -> Pai e Tio viram PRETOS, Avô (" + string(_g.key) + ") vira VERMELHO.";
            } else {
                // CASO 2: Tio é PRETO e _z forma um Triângulo -> Rotação à Esquerda no Pai
                if (_z == _p.right) {
                    pending_z = _p;
                    rotate_left(_p);
                    last_op_log = "PASSO [Caso 2]: Tio PRETO em Triângulo -> Rotação à ESQUERDA no Pai (" + string(_p.key) + ").";
                } else {
                    // CASO 3: Tio é PRETO e _z forma uma Linha -> Recolore Pai/Avô e Gira Avô à Direita
                    _p.color = "BLACK";
                    _g.color = "RED";
                    rotate_right(_g);
                    pending_z = undefined;
                    last_op_log = "PASSO [Caso 3]: Tio PRETO em Linha -> Rotação à DIREITA no Avô (" + string(_g.key) + ") + Recolor!";
                }
            }
        } else {
            // Ramo Direito (Simétrico): Pai é filho direito do Avô
            var _uncle = _g.left;
            
            if (_uncle != undefined && _uncle.color == "RED") {
                _p.color = "BLACK";
                _uncle.color = "BLACK";
                _g.color = "RED";
                pending_z = _g;
                last_op_log = "PASSO [Caso 1]: Tio (" + string(_uncle.key) + ") era VERMELHO -> Pai e Tio viram PRETOS, Avô (" + string(_g.key) + ") vira VERMELHO.";
            } else {
                if (_z == _p.left) {
                    pending_z = _p;
                    rotate_right(_p);
                    last_op_log = "PASSO [Caso 2]: Tio PRETO em Triângulo -> Rotação à DIREITA no Pai (" + string(_p.key) + ").";
                } else {
                    _p.color = "BLACK";
                    _g.color = "RED";
                    rotate_left(_g);
                    pending_z = undefined;
                    last_op_log = "PASSO [Caso 3]: Tio PRETO em Linha -> Rotação à ESQUERDA no Avô (" + string(_g.key) + ") + Recolor!";
                }
            }
        }
        
        // Garante que a raiz nunca termine vermelha
        if (root != undefined) {
            root.color = "BLACK";
            if (pending_z == root) pending_z = undefined;
        }
        
        total_nodes = binary_tree_count(root);
        binary_tree_layout(root);
    }

    // =========================================================================
    // FUNÇÕES AUXILIARES E REMOÇÃO COMPLETA (COM CORREÇÃO DUPLO-PRETO)
    // =========================================================================
    function _get_color(_node) {
        return (_node == undefined) ? "BLACK" : _node.color; // Folhas NIL são sempre pretas
    }

    function _transplant(_u, _v) {
        // Substitui a subárvore enraizada em _u pela subárvore _v
        if (_u.parent == undefined) root = _v;
        else if (_u == _u.parent.left) _u.parent.left = _v;
        else _u.parent.right = _v;
        if (_v != undefined) _v.parent = _u.parent;
    }

    function _minimum(_node) {
        while (_node.left != undefined) _node = _node.left;
        return _node;
    }

    function get_max_node() {
        // Retorna o nó mais à direita (maior nível de Agro da batalha) em O(log N)
        if (root == undefined) return undefined;
        var _curr = root;
        while (_curr.right != undefined) _curr = _curr.right;
        return _curr;
    }

    function remove_key(_key) {
        while (pending_z != undefined) balance_step();
        
        var _z = root;
        while (_z != undefined && _z.key != _key) {
            _z = (_key < _z.key) ? _z.left : _z.right;
        }
        if (_z == undefined) return;
        
        // Se houver monstros repetidos no nó, decrementa apenas o contador
        if (_z.count > 1) {
            _z.count -= 1;
            array_pop(_z.monsters);
            last_op_log = "Derrotada 1 réplica de Agro " + string(_key) + " (restam x" + string(_z.count) + ").";
            return;
        }
        
        var _y = _z;
        var _y_orig_color = _y.color;
        var _x = undefined;
        var _x_parent = undefined;
        
        if (_z.left == undefined) {
            _x = _z.right;
            _x_parent = _z.parent;
            _transplant(_z, _z.right);
        } else if (_z.right == undefined) {
            _x = _z.left;
            _x_parent = _z.parent;
            _transplant(_z, _z.left);
        } else {
            _y = _minimum(_z.right);
            _y_orig_color = _y.color;
            _x = _y.right;
            if (_y.parent == _z) {
                _x_parent = _y;
            } else {
                _x_parent = _y.parent;
                _transplant(_y, _y.right);
                _y.right = _z.right;
                _y.right.parent = _y;
            }
            _transplant(_z, _y);
            _y.left = _z.left;
            _y.left.parent = _y;
            _y.color = _z.color;
        }
        
        last_op_log = "Removido Agro " + string(_key) + ".";
        // Se o nó removido era PRETO, corrige o Duplo-Preto para manter a Altura Negra
        if (_y_orig_color == "BLACK") {
            _fix_delete(_x, _x_parent);
        }
        
        total_nodes = binary_tree_count(root);
        binary_tree_layout(root);
    }

    function _fix_delete(_x, _parent) {
        // Restaura a contagem de nós pretos (Black-Height) nos 4 casos de remoção
        while (_x != root && _get_color(_x) == "BLACK") {
            if (_parent == undefined) break;
            if (_x == _parent.left) {
                var _w = _parent.right;
                if (_w == undefined) break;
                if (_get_color(_w) == "RED") {
                    _w.color = "BLACK";
                    _parent.color = "RED";
                    rotate_left(_parent);
                    _w = _parent.right;
                    if (_w == undefined) break;
                }
                if (_get_color(_w.left) == "BLACK" && _get_color(_w.right) == "BLACK") {
                    _w.color = "RED";
                    _x = _parent;
                    _parent = _x.parent;
                } else {
                    if (_get_color(_w.right) == "BLACK") {
                        if (_w.left != undefined) _w.left.color = "BLACK";
                        _w.color = "RED";
                        rotate_right(_w);
                        _w = _parent.right;
                        if (_w == undefined) break;
                    }
                    _w.color = _parent.color;
                    _parent.color = "BLACK";
                    if (_w.right != undefined) _w.right.color = "BLACK";
                    rotate_left(_parent);
                    _x = root;
                }
            } else {
                var _w = _parent.left;
                if (_w == undefined) break;
                if (_get_color(_w) == "RED") {
                    _w.color = "BLACK";
                    _parent.color = "RED";
                    rotate_right(_parent);
                    _w = _parent.left;
                    if (_w == undefined) break;
                }
                if (_get_color(_w.right) == "BLACK" && _get_color(_w.left) == "BLACK") {
                    _w.color = "RED";
                    _x = _parent;
                    _parent = _x.parent;
                } else {
                    if (_get_color(_w.left) == "BLACK") {
                        if (_w.right != undefined) _w.right.color = "BLACK";
                        _w.color = "RED";
                        rotate_left(_w);
                        _w = _parent.left;
                        if (_w == undefined) break;
                    }
                    _w.color = _parent.color;
                    _parent.color = "BLACK";
                    if (_w.left != undefined) _w.left.color = "BLACK";
                    rotate_right(_parent);
                    _x = root;
                }
            }
        }
        if (_x != undefined) _x.color = "BLACK";
        last_op_log += " -> Duplo-Preto corrigido (Altura Negra OK).";
    }

    function get_height(_node) {
        if (_node == undefined) return 0;
        return 1 + max(get_height(_node.left), get_height(_node.right));
    }

    function get_black_height(_node) {
        // Conta quantos nós pretos existem até a folha NIL (invariante da RB-Tree)
        if (_node == undefined) return 1;
        var _add = (_node.color == "BLACK") ? 1 : 0;
        return _add + get_black_height(_node.left);
    }
}