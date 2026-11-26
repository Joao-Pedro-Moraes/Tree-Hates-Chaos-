randomize();
tree_init_display();

kd_tree = new KDTree();
paused = false;
player_x = 380;
player_y = 420;
diag_step = 0;

btn_bal_x1 = 20;
btn_bal_y1 = 76;
btn_bal_x2 = 235;
btn_bal_y2 = 114;

repeat(20) {
    kd_tree.insert(irandom_range(40, 720), irandom_range(190, 650));
}
kd_tree.balance();
kd_tree.last_op_log = "20 naves balanceadas. Aperte [S] para inserir em diagonal (desbalancear) e [B] para reconstruir!";