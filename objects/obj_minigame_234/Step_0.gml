tree_handle_global_keys();
if (!variable_instance_exists(id, "paused")) paused = false;
if (keyboard_check_pressed(vk_space)) paused = !paused;

if (keyboard_check_pressed(vk_f1)) {
    tree_234 = new Tree234();
    var _loot_names = ["Poção", "Adaga", "Escudo", "Elmo", "Grimório", "Anel", "Cajado", "Espada"];
    repeat(22) tree_234.insert(irandom_range(10, 99), _loot_names[irandom(array_length(_loot_names) - 1)]);
}

var _clicked_btn = mouse_check_button_pressed(mb_left) && point_in_rectangle(mouse_x, mouse_y, btn_bal_x1, btn_bal_y1, btn_bal_x2, btn_bal_y2);

// [B] ou Clique no Botão: Mira propositalmente em um 4-nó dourado (3 chaves) para disparar SPLIT na hora!
if (keyboard_check_pressed(ord("B")) || _clicked_btn) {
    var _full_n = tree_234.find_full_node(tree_234.root);
    if (_full_n != undefined) {
        var _target_val = _full_n.keys[1] + 1;
        while (tree_234.search(tree_234.root, _target_val) != undefined) _target_val += 1;
        tree_234.insert(_target_val, "Relíquia Split");
    } else {
        tree_234.insert(irandom_range(10, 99), "Relíquia");
    }
}

if (!paused) {
    if (keyboard_check_pressed(ord("I")) || (mouse_check_button_pressed(mb_left) && !_clicked_btn && mouse_x < 750 && mouse_y > 70)) {
        var _loot_names = ["Poção", "Adaga", "Escudo", "Elmo", "Grimório", "Anel"];
        tree_234.insert(irandom_range(10, 99), _loot_names[irandom(array_length(_loot_names) - 1)]);
    }
    
    if (keyboard_check_pressed(ord("R"))) {
        var _min_g = tree_234.get_min_key();
        if (_min_g != undefined) tree_234.insert(_min_g, "Poção Extra");
    }
    
    if (keyboard_check_pressed(ord("K")) || mouse_check_button_pressed(mb_right)) {
        var _min_g = tree_234.get_min_key();
        if (_min_g != undefined) {
            player_gold += _min_g;
            items_sold += 1;
            tree_234.remove_key(_min_g);
        }
    }
}