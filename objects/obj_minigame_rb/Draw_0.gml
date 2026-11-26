var _max_node = rb_tree.get_max_node();
var _stats = "Nós: " + string(rb_tree.total_nodes) + 
             " | Alt: " + string(rb_tree.get_height(rb_tree.root)) + 
             " | Alt. Negra: " + string(rb_tree.get_black_height(rb_tree.root)) + 
             " | Rotações: " + string(rb_tree.rotation_count);

draw_split_layout(
    "MINI-JOGO 2: ÁRVORE RUBRO-NEGRA (RED-BLACK)",
    "Vermelho: Novo/Conflito | Preto: Estável | Altura Negra Constante",
    rb_tree.last_op_log,
    _stats
);

// Barra de comandos na arena esquerda
draw_set_color(make_color_rgb(10, 14, 20));
draw_rectangle(10, 44, 750, 68, false);
draw_set_color(c_aqua);
draw_text(20, 49, "[I / Click Esq] Invocar | [S] Inserir Crescente | [R] Repetido | [K / Click Dir] Atacar Maior");

// --- ARENA DE BATALHA RPG (ESQUERDA) ---
// Desenha o Herói (Tanque) à esquerda da arena
var _hero_x = 120;
var _hero_y = 380;
draw_set_color(make_color_rgb(60, 180, 255));
draw_circle(_hero_x, _hero_y, 26, false);
draw_set_color(c_white);
draw_circle(_hero_x, _hero_y, 26, true);
draw_set_halign(fa_center);
draw_text(_hero_x, _hero_y - 45, "HERÓI (TANQUE)");
draw_text(_hero_x, _hero_y - 8, "DEF");
draw_set_halign(fa_left);

// Lista os monstros ativos em fila de prioridade (do Maior Agro para o Menor)
var _sorted = [];
var _collect_desc = function(_n, _arr, _fn) {
    if (_n == undefined) return;
    _fn(_n.right, _arr, _fn);
    array_push(_arr, _n);
    _fn(_n.left, _arr, _fn);
};
_collect_desc(rb_tree.root, _sorted, _collect_desc);

draw_set_color(c_white);
draw_text(250, 85, "FILA DE AMEAÇA (MAIOR AGRO NO TOPO):");

var _max_show = min(14, array_length(_sorted));
for (var i = 0; i < _max_show; i++) {
    var _m = _sorted[i];
    var _by = 115 + i * 38;
    var _bx = 250;
    var _bar_w = clamp(_m.key * 3.2, 60, 460);
    
    // Cor da barra reflete a cor do nó na Árvore Rubro-Negra!
    var _col = (_m.color == "RED") ? make_color_rgb(200, 45, 45) : make_color_rgb(35, 38, 48);
    draw_set_color(_col);
    draw_rectangle(_bx, _by, _bx + _bar_w, _by + 30, false);
    
    // Destaque amarelo no alvo prioritário (Maior Agro)
    draw_set_color((i == 0) ? c_yellow : c_gray);
    draw_rectangle(_bx, _by, _bx + _bar_w, _by + 30, true);
    
    draw_set_color(c_white);
    var _txt = "#" + string(i + 1) + " | AGRO: " + string(_m.key) + " (" + _m.monsters[0] + ")";
    if (_m.count > 1) _txt += " [x" + string(_m.count) + "]";
    draw_text(_bx + 10, _by + 7, _txt);
    
    // Linha de ataque do Herói no alvo de maior Agro
    if (i == 0) {
        draw_set_color(c_yellow);
        draw_line_width(_hero_x + 26, _hero_y, _bx, _by + 15, 3);
    }
}

// --- INSPETOR TOPOLÓGICO (DIREITA) ---
// Reutiliza o desenhador do scr_visualizer destacando o monstro de maior Agro
draw_binary_tree_nodes(rb_tree.root, _max_node);