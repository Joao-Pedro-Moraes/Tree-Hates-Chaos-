tree_handle_global_keys();
if (!variable_instance_exists(id, "paused")) paused = false;
if (keyboard_check_pressed(vk_space)) paused = !paused;

if (keyboard_check_pressed(vk_f1)) {
    kd_tree = new KDTree();
    diag_step = 0;
    repeat(20) kd_tree.insert(irandom_range(40, 720), irandom_range(190, 650));
    kd_tree.balance();
}

var _clicked_btn = mouse_check_button_pressed(mb_left) && point_in_rectangle(mouse_x, mouse_y, btn_bal_x1, btn_bal_y1, btn_bal_x2, btn_bal_y2);
if (keyboard_check_pressed(ord("B")) || _clicked_btn) {
    kd_tree.balance();
}

if (!paused) {
    var _spd = 4;
    if (keyboard_check(vk_left))  player_x -= _spd;
    if (keyboard_check(vk_right)) player_x += _spd;
    if (keyboard_check(vk_up))    player_y -= _spd;
    if (keyboard_check(vk_down))  player_y += _spd;
    player_x = clamp(player_x, 30, 730);
    player_y = clamp(player_y, 185, 660);

    // Clique na arena insere nave na posição do mouse
    if (mouse_check_button_pressed(mb_left) && !_clicked_btn && mouse_x > 25 && mouse_x < 735 && mouse_y > 180 && mouse_y < 665) {
        kd_tree.insert(mouse_x, mouse_y);
        kd_tree.balance_info = undefined;
        kd_tree.last_op_log = "Nave inserida em (" + string(round(mouse_x)) + ", " + string(round(mouse_y)) + ").";
    }
    
    // [S] Insere em diagonal crescente (pior caso -> cria árvore torta!)
    if (keyboard_check_pressed(ord("S"))) {
        diag_step = (diag_step + 1) mod 12;
        var _dx = 80 + diag_step * 52;
        var _dy = 200 + diag_step * 36;
        kd_tree.insert(_dx, _dy);
        kd_tree.balance_info = undefined;
        kd_tree.last_op_log = "Inserção Diagonal (" + string(_dx) + ", " + string(_dy) + ") -> Árvore entortando!";
    }
    
    // [K] ou Clique Direito: Destrói alvo mais próximo
    if (keyboard_check_pressed(ord("K")) || mouse_check_button_pressed(mb_right)) {
        var _target = kd_tree.find_nearest(player_x, player_y);
        if (_target != undefined) {
            kd_tree.remove_point(_target);
            kd_tree.balance_info = undefined;
            kd_tree.last_op_log = "Alvo #" + string(_target.key) + " destruído!";
        }
    }
}