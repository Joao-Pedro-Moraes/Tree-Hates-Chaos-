tree_handle_global_keys();
if (!variable_instance_exists(id, "paused")) paused = false;

if (keyboard_check_pressed(vk_space)) paused = !paused;

// [F1] Reinicia com 22 monstros balanceados
if (keyboard_check_pressed(vk_f1)) {
    rb_tree = new RBTree();
    rb_tree.auto_balance = true;
    seq_counter = 100;
    var _names = ["Goblin", "Orc", "Esqueleto", "Gárgula", "Troll", "Lich", "Dragão"];
    repeat(22) {
        rb_tree.insert(irandom_range(5, 95), _names[irandom(array_length(_names) - 1)]);
    }
    rb_tree.auto_balance = false;
    rb_tree.last_op_log = "Horda reiniciada. Modo Passo a Passo ativo ([B] Balanceia).";
}

// [T] Alterna entre Modo Passo a Passo (para apresentação) e Auto-Balanceamento
if (keyboard_check_pressed(ord("T"))) {
    rb_tree.auto_balance = !rb_tree.auto_balance;
    if (rb_tree.auto_balance) {
        while (rb_tree.pending_z != undefined) rb_tree.balance_step();
    }
    rb_tree.last_op_log = "Auto-Balanceamento: " + (rb_tree.auto_balance ? "ON (Instantâneo)" : "OFF (Passo a Passo com [B])");
}

// [B] ou Clique no botão [BALANCEAR PASSO]: Executa 1 passo de rotação/recoloração
var _clicked_btn = mouse_check_button_pressed(mb_left) && point_in_rectangle(mouse_x, mouse_y, btn_bal_x1, btn_bal_y1, btn_bal_x2, btn_bal_y2);
if (keyboard_check_pressed(ord("B")) || _clicked_btn) {
    rb_tree.balance_step();
}

if (!paused) {
    // [I] ou Clique Esquerdo fora do botão: Invoca novo monstro
    if (keyboard_check_pressed(ord("I")) || (mouse_check_button_pressed(mb_left) && !_clicked_btn && mouse_x < 750 && mouse_y > 70)) {
        rb_tree.insert(irandom_range(1, 99), "Invasor");
    }
    
    // [S] Insere em ordem crescente (105, 110, 115...) para forçar rotações na direita
    if (keyboard_check_pressed(ord("S"))) {
        seq_counter += 5;
        rb_tree.insert(seq_counter, "Onda Crescente");
    }
    
    // [R] Insere repetido [xN]
    if (keyboard_check_pressed(ord("R")) && rb_tree.root != undefined) {
        rb_tree.insert(rb_tree.root.key, "Clone da Raiz");
    }
    
    // [K] ou Clique Direito: Derrota monstro de maior Agro
    if (keyboard_check_pressed(ord("K")) || mouse_check_button_pressed(mb_right)) {
        var _top_threat = rb_tree.get_max_node();
        if (_top_threat != undefined) {
            rb_tree.remove_key(_top_threat.key);
        }
    }
}