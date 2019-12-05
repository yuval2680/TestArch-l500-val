list_length = 81;
SN = '205' %BAD (1939)
%SN = '205'; %GOOD (1944)

tmp = load(['..\Data\', SN, '\xMat.mat']);
x_mat = tmp.xMat;
x_mat(:, :, list_length:end) = [];
tmp = load(['..\Data\', SN, '\yMat.mat']);
y_mat = tmp.yMat;
y_mat(:, :, list_length:end) = [];

sz = size(x_mat);
t_v = (0:(sz(3)-1))*0.96;

xCent = 320;
yCent = 240;
szChecker = 105;
dTarget = 672.7;
show_flag = 1;
dummy_flag = 0;
%%
Result = cb_metrics(t_v, x_mat, y_mat, dTarget, szChecker, xCent, yCent, show_flag, dummy_flag)