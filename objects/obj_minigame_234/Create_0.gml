randomize();
tree_init_display();

tree_234 = new Tree234();
paused = false;
player_gold = 500;
items_sold = 0;

btn_bal_x1 = 25;
btn_bal_y1 = 78;
btn_bal_x2 = 235;
btn_bal_y2 = 120;

var _loot_names = ["Poção", "Adaga", "Escudo", "Elmo", "Grimório", "Anel", "Cajado", "Espada"];
repeat(22) {
    tree_234.insert(irandom_range(10, 99), _loot_names[irandom(array_length(_loot_names) - 1)]);
}
tree_234.last_op_log = "22 chaves prontas. Aperte [B] para forçar Split em um 4-nó ou [K] para testar Merge!";