var _min_gold = tree_234.get_min_key();
var _has_4node = (tree_234.find_full_node(tree_234.root) != undefined);

var _stats = "Chaves: " + string(tree_234.total_keys) + 
             " | Alt. Uniforme: " + string(tree_234.get_height()) + 
             " | Splits: " + string(tree_234.split_count) + 
             " | Merges: " + string(tree_234.merge_count);

draw_split_layout(
    "MINI-JOGO 3: ÁRVORE NÃO-BINÁRIA 2-3-4",
    "Azul: 2-nó | Verde: 3-nó | Dourado: 4-nó (Cheio -> Split com [B])",
    tree_234.last_op_log,
    _stats
);

draw_set_color(make_color_rgb(10, 14, 20));
draw_rectangle(10, 44, 750, 68, false);
draw_set_color(c_yellow);
draw_text(20, 49, "[I] Saquear | [B] Forçar Split (4-nó) | [R] Repetido | [K] Vender (Merge/Redist)");

// Botão Clicável [B] FORÇAR SPLIT
draw_set_color(_has_4node ? make_color_rgb(185, 115, 35) : make_color_rgb(35, 110, 75));
draw_rectangle(btn_bal_x1, btn_bal_y1, btn_bal_x2, btn_bal_y2, false);
draw_set_color(c_yellow);
draw_rectangle(btn_bal_x1, btn_bal_y1, btn_bal_x2, btn_bal_y2, true);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text((btn_bal_x1 + btn_bal_x2) * 0.5, (btn_bal_y1 + btn_bal_y2) * 0.5, _has_4node ? "[B] DIVIDIR 4-NÓ (SPLIT)" : "[B] INSERIR E ENCHER");
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Inspetor de Balanceamento Bottom-Up (Split / Redistribuição / Merge)
draw_set_color(make_color_rgb(22, 26, 36));
draw_rectangle(245, 78, 740, 175, false);
draw_set_color(c_orange);
draw_rectangle(245, 78, 740, 175, true);

draw_set_color(c_yellow);
draw_text(258, 84, "INSPETOR DE BALANCEAMENTO MULTI-CAMINHOS (SPLIT / MERGE):");

if (tree_234.last_event != undefined) {
    var _ev = tree_234.last_event;
    draw_set_color(c_aqua);
    draw_text(258, 106, "Operação: " + _ev.type);
    draw_set_color(c_white);
    draw_text(258, 128, _ev.detail);
    draw_set_color(c_lime);
    draw_text(258, 150, _ev.promoted);
} else {
    draw_set_color(c_ltgray);
    draw_text_ext(258, 108, "Aperte [B] para dividir um 4-nó dourado e promover sua mediana para cima,\nou aperte [K] para vender itens e disparar Redistribuição / Merge.", 19, 470);
}

// Painel do Mercador
draw_set_color(make_color_rgb(35, 30, 22));
draw_rectangle(25, 185, 735, 222, false);
draw_set_color(c_orange);
draw_rectangle(25, 185, 735, 222, true);
draw_set_color(c_yellow);
draw_text(40, 196, "MERCADOR RPG | OURO: " + string(player_gold) + "g | VENDIDOS: " + string(items_sold) + " | MENOR ITEM: " + ((_min_gold != undefined) ? (string(_min_gold) + "g") : "Vazio"));

// Catálogo Ordenado
var _inv_list = [];
var _collect_in_order = function(_n, _arr, _fn) {
    if (_n == undefined) return;
    var _nk = _n.num_keys();
    for (var i = 0; i < _nk; i++) {
        if (!_n.is_leaf) _fn(_n.children[i], _arr, _fn);
        array_push(_arr, { gold: _n.keys[i], count: _n.counts[i], name: _n.items[i][0] });
    }
    if (!_n.is_leaf) _fn(_n.children[_nk], _arr, _fn);
};
_collect_in_order(tree_234.root, _inv_list, _collect_in_order);

var _cols = 4;
var _slot_w = 170;
var _slot_h = 66;
var _max_slots = min(24, array_length(_inv_list));

for (var i = 0; i < _max_slots; i++) {
    var _item = _inv_list[i];
    var _c = i mod _cols;
    var _r = i div _cols;
    var _sx = 25 + _c * (_slot_w + 8);
    var _sy = 234 + _r * (_slot_h + 8);
    
    draw_set_color(make_color_rgb(28, 34, 46));
    draw_rectangle(_sx, _sy, _sx + _slot_w, _sy + _slot_h, false);
    draw_set_color((i == 0) ? c_yellow : make_color_rgb(80, 100, 130));
    draw_rectangle(_sx, _sy, _sx + _slot_w, _sy + _slot_h, true);
    
    draw_set_color(c_aqua);
    draw_text(_sx + 10, _sy + 9, _item.name + (_item.count > 1 ? " [x" + string(_item.count) + "]" : ""));
    draw_set_color(c_yellow);
    draw_text(_sx + 10, _sy + 35, "Valor: " + string(_item.gold) + " Ouro");
}

// Inspetor Topológico 2-3-4
tree_234.draw_tree(tree_234.root, _min_gold);