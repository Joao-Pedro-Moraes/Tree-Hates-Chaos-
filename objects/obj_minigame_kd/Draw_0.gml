var _nearest = kd_tree.find_nearest(player_x, player_y);
var _bal_ok = kd_tree.is_balanced();

var _stats = "Nós: " + string(kd_tree.total_nodes) + 
             " | Alt: " + string(kd_tree.get_height(kd_tree.root)) + 
             " | Checks: " + string(kd_tree.last_checks) + "/" + string(kd_tree.total_nodes) +
             " | " + (_bal_ok ? "BALANCEADA" : "DESBALANCEADA [Aperte B]");

draw_split_layout(
    "MINI-JOGO 1: ÁRVORE BINÁRIA k-D (k = 2)",
    "Vermelho: Corte X | Azul: Corte Y | [B] Balancear pela Mediana",
    kd_tree.last_op_log,
    _stats
);

draw_set_color(make_color_rgb(10, 14, 20));
draw_rectangle(10, 44, 750, 68, false);
draw_set_color(c_aqua);
draw_text(20, 49, "[Setas] Mover | [Click Esq] Inserir | [S] Diagonal (Torta) | [B] Mediana | [K] Atirar");

// Botão Clicável [B]
draw_set_color(!_bal_ok ? make_color_rgb(200, 50, 50) : make_color_rgb(35, 110, 75));
draw_rectangle(btn_bal_x1, btn_bal_y1, btn_bal_x2, btn_bal_y2, false);
draw_set_color(!_bal_ok ? c_yellow : c_white);
draw_rectangle(btn_bal_x1, btn_bal_y1, btn_bal_x2, btn_bal_y2, true);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text((btn_bal_x1 + btn_bal_x2) * 0.5, (btn_bal_y1 + btn_bal_y2) * 0.5, !_bal_ok ? "[B] RECONSTRUIR MEDIANA!" : "[B] BALANCEAR MEDIANA");
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Inspetor da Mediana
draw_set_color(make_color_rgb(22, 26, 36));
draw_rectangle(245, 76, 740, 168, false);
draw_set_color(!_bal_ok ? c_yellow : make_color_rgb(70, 90, 120));
draw_rectangle(245, 76, 740, 168, true);
draw_set_color(c_yellow);
draw_text(258, 82, "INSPETOR DE BALANCEAMENTO ESTÁTICO (DIVISÃO PELA MEDIANA):");

if (kd_tree.balance_info != undefined) {
    var _bi = kd_tree.balance_info;
    draw_set_color(c_white);
    draw_text(258, 105, "Pivô Mediana (Raiz X): Nó #" + string(_bi.pivot_id) + " em (" + string(_bi.pivot_px) + ", " + string(_bi.pivot_py) + ")");
    draw_text(258, 126, "Partição: " + string(_bi.left_count) + " nós à Esquerda  |  " + string(_bi.right_count) + " nós à Direita");
    draw_set_color(c_lime);
    draw_text(258, 146, "Altura antes: " + string(_bi.old_h) + "  ->  Altura otimizada: " + string(_bi.new_h));
} else {
    draw_set_color(c_ltgray);
    draw_text_ext(258, 105, "Sem rotação! Para balancear, ordena os pontos por X/Y e elege o elemento central como raiz.\nAperte [B] para calcular a mediana e achatar a árvore.", 19, 470);
}

// Arena Espacial
draw_set_color(make_color_rgb(14, 18, 26));
draw_rectangle(20, 178, 740, 668, false);
draw_set_color(c_dkgray);
draw_rectangle(20, 178, 740, 668, true);

kd_tree.draw_hyperplanes(kd_tree.root, 20, 178, 740, 668);

// Nave do Jogador + Raio de Poda Espacial
if (_nearest != undefined) {
    var _dist = point_distance(player_x, player_y, _nearest.px, _nearest.py);
    draw_set_color(c_lime);
    draw_set_alpha(0.35);
    draw_circle(player_x, player_y, _dist, true);
    draw_set_alpha(1.0);
    draw_line_width(player_x, player_y, _nearest.px, _nearest.py, 2);
}

draw_set_color(c_aqua);
draw_circle(player_x, player_y, 9, false);
draw_set_color(c_white);
draw_circle(player_x, player_y, 9, true);

// Inspetor Topológico
draw_binary_tree_nodes(kd_tree.root, _nearest);