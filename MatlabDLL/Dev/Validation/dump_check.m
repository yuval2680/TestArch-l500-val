load('\\143.185.124.250\Users\Dror\For Yuval\z_drift1578516048.137.mat')

dummy_flag = 0;

%Result = cb_metrics(t_v, x_mat_cell, y_mat_cell, dTarget, szChecker, xCent, yCent, show_flag, dummy_flag)
Result = z_drift(t_v, z_im_cell, z2mm, 1, 0)