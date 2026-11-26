randomize();
tree_init_display();

rb_tree = new RBTree();
rb_tree.auto_balance = true; // Popula os 22 iniciais balanceados...
paused = false;
seq_counter = 100;

// Coordenadas do botão clicável [B] BALANCEAR na arena
btn_bal_x1 = 25;
btn_bal_y1 = 80;
btn_bal_x2 = 230;
btn_bal_y2 = 122;

var _names = ["Goblin", "Orc", "Esqueleto", "Gárgula", "Troll", "Lich", "Dragão"];
repeat(22) {
    rb_tree.insert(irandom_range(5, 95), _names[irandom(array_length(_names) - 1)]);
}

// ...e ativa o Modo Didático Passo a Passo para a sua apresentação!
rb_tree.auto_balance = false;
rb_tree.last_op_log = "22 nós prontos. Aperte [S] ou [I] para gerar conflito e [B] para balancear!";