/// @description Controlador global de layout split-screen, fullscreen e desenho auto-ajustável de árvores

function tree_init_display() {
    window_set_fullscreen(true);
    display_set_gui_size(1280, 720);
    var _fnt = asset_get_index("Font1");
    if (_fnt != -1) {
        draw_set_font(_fnt);
    }
}

function tree_handle_global_keys() {
    if (keyboard_check_pressed(ord("1")) && room != rm_kdtree) room_goto(rm_kdtree);
    if (keyboard_check_pressed(ord("2")) && room != rm_rbtree) room_goto(rm_rbtree);
    if (keyboard_check_pressed(ord("3")) && room != rm_234tree) room_goto(rm_234tree);
    
    if (keyboard_check_pressed(vk_f11)) {
        window_set_fullscreen(!window_get_fullscreen());
    }
}

function draw_split_layout(_title, _subtitle, _log_text, _stats_text) {
    // Fundo geral
    draw_clear(make_color_rgb(18, 22, 30));
    
    // Painel Direito (Inspetor Topológico: 760px a 1280px)
    draw_set_color(make_color_rgb(26, 31, 42));
    draw_rectangle(760, 0, 1280, 720, false);
    
    // Linha divisória central
    draw_set_color(make_color_rgb(70, 130, 180));
    draw_line_width(760, 0, 760, 720, 3);
    
    // Cabeçalho do Painel Direito
    draw_set_color(c_white);
    draw_text(775, 12, _title);
    draw_set_color(c_ltgray);
    draw_text(775, 32, _subtitle);
    
    // Rodapé de Estatísticas e Log (y: 615 até 712)
    draw_set_color(make_color_rgb(15, 18, 25));
    draw_rectangle(770, 615, 1270, 712, false);
    draw_set_color(c_aqua);
    draw_text(780, 623, _stats_text);
    draw_set_color(c_yellow);
    draw_text_ext(780, 648, "LOG: " + _log_text, 18, 480);
    
    // Barra de navegação superior esquerda
    draw_set_color(make_color_rgb(0, 0, 0));
    draw_set_alpha(0.6);
    draw_rectangle(10, 10, 750, 42, false);
    draw_set_alpha(1.0);
    draw_set_color(c_white);
    draw_text(20, 18, "[1] k-D  [2] Rubro-Negra  [3] 2-3-4 | [F1] 22 Nós | [ESPAÇO] Pausar | [F11] Tela");
}

function binary_tree_count(_node) {
    if (_node == undefined) return 0;
    return 1 + binary_tree_count(_node.left) + binary_tree_count(_node.right);
}

function binary_tree_max_depth(_node) {
    if (_node == undefined) return 0;
    return 1 + max(binary_tree_max_depth(_node.left), binary_tree_max_depth(_node.right));
}

// Calcula target_x e target_y auto-escalando largura e altura para caber 100% no painel direito
function binary_tree_layout(_root) {
    if (_root == undefined) return;
    var _total = binary_tree_count(_root);
    var _max_d = max(1, binary_tree_max_depth(_root) - 1);
    
    // Espaço vertical útil: de y=80 até y=590 (510px disponíveis)
    var _step_y = min(56, 510 / _max_d);
    
    var _state = { 
        index: 0, 
        total: _total,
        step_y: _step_y
    };
    _assign_inorder_coords(_root, 0, _state);
}

function _assign_inorder_coords(_node, _depth, _state) {
    if (_node == undefined) return;
    
    _assign_inorder_coords(_node.left, _depth + 1, _state);
    
    // Margem horizontal segura: 785 até 1245 (460px úteis)
    var _usable_w = 460;
    var _step_x = (_state.total > 1) ? (_usable_w / (_state.total - 1)) : 0;
    
    _node.target_x = (_state.total == 1) ? 1015 : (785 + _state.index * _step_x);
    _node.target_y = 80 + _depth * _state.step_y;
    _state.index += 1;
    
    _assign_inorder_coords(_node.right, _depth + 1, _state);
}

// Interpola posição suave e desenha arestas + nós sem cortar
function draw_binary_tree_nodes(_node, _highlight_node) {
    if (_node == undefined) return;
    
    var _total = binary_tree_count(_node);
    var _radius = (_total > 20) ? 11 : 14;
    _draw_binary_rec(_node, _highlight_node, _radius);
}

function _draw_binary_rec(_node, _highlight_node, _radius) {
    if (_node == undefined) return;
    
    _node.x = lerp(_node.x, _node.target_x, 0.15);
    _node.y = lerp(_node.y, _node.target_y, 0.15);
    
    if (_node.left != undefined) {
        _node.left.x = lerp(_node.left.x, _node.left.target_x, 0.15);
        _node.left.y = lerp(_node.left.y, _node.left.target_y, 0.15);
        draw_set_color(c_gray);
        draw_line_width(_node.x, _node.y, _node.left.x, _node.left.y, 2);
        _draw_binary_rec(_node.left, _highlight_node, _radius);
    }
    
    if (_node.right != undefined) {
        _node.right.x = lerp(_node.right.x, _node.right.target_x, 0.15);
        _node.right.y = lerp(_node.right.y, _node.right.target_y, 0.15);
        draw_set_color(c_gray);
        draw_line_width(_node.x, _node.y, _node.right.x, _node.right.y, 2);
        _draw_binary_rec(_node.right, _highlight_node, _radius);
    }
    
    // Cor do nó (suporta k-D Tree e Rubro-Negra)
    var _fill_col = make_color_rgb(50, 120, 200);
    if (variable_struct_exists(_node, "axis")) {
        _fill_col = (_node.axis == 0) ? make_color_rgb(200, 60, 60) : make_color_rgb(50, 110, 220);
    }
    if (variable_struct_exists(_node, "color")) {
        _fill_col = (_node.color == "RED") ? make_color_rgb(210, 45, 45) : make_color_rgb(30, 30, 35);
    }
    
    // Destaque se for o nó alvo/ativo
    if (_node == _highlight_node) {
        draw_set_color(c_yellow);
        draw_circle(_node.x, _node.y, _radius + 3, false);
    }
    
    draw_set_color(_fill_col);
    draw_circle(_node.x, _node.y, _radius, false);
    draw_set_color(c_white);
    draw_circle(_node.x, _node.y, _radius, true);
    
    // Texto interno do nó
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var _label = string(_node.key);
    if (_node.count > 1) _label += "\n[x" + string(_node.count) + "]";
    draw_text(_node.x, _node.y, _label);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}