warning('off','all')

clear all
clc

dump_file_name = [mfilename, cur_time_stamp_ut];
diary(['.\Results\', dump_file_name, '.txt']);

disp('Initializing...');

%%
show_flag = 1;
dummy_flag = 0;

%%
disp('CB metric...');
list_length = 81;
SN = '205'; %BAD (1939)
%SN = '205'; %GOOD (1944)

tmp = load(['..\Data\', SN, '\xMat.mat']);
x_mat = tmp.xMat;
x_mat(:, :, list_length:end) = [];
tmp = load(['..\Data\', SN, '\yMat.mat']);
y_mat = tmp.yMat;
y_mat(:, :, list_length:end) = [];

sz = size(x_mat);
t_v = (0:(sz(3)-1))*0.96;

x_mat_cell = {};
y_mat_cell = {};
for ii = 1:sz(3)
    x_mat_cell{ii} = x_mat(:, :, ii);
    y_mat_cell{ii} = y_mat(:, :, ii);
end

xCent = 320;
yCent = 240;
szChecker = 105;
dTarget = 672.7;
%%
Result = cb_metrics(t_v, x_mat_cell, y_mat_cell, dTarget, szChecker, xCent, yCent, show_flag, dummy_flag)
save_figure('cb_metrics', 'C:\GitHub\TesArch-l500-val\MatlabDLL\Dev\Regression\Results\', 'cb_metrics');


%%
disp('Z-drift metric...');
work_dir = '..\Data\Z-drift\';

fnames = dir([work_dir, 'Z_*.bin']);

n_files = length(fnames);
width = 1024;
height = 768;
z2mm = 4;

z_im_cell = cell(1, n_files);
for ii=1:n_files
    cur_f = [work_dir, fnames(ii).name];
    fid = fopen(cur_f, 'r');
    z_im_cell{ii} = reshape(fread(fid, 'int16=>int16'), width, height)';
    fclose(fid);
end

%%
z2mm = 4;
t_v = 0:(n_files-1);
Result = z_drift(t_v, z_im_cell, z2mm, show_flag, dummy_flag)
save_figure('z_drift', 'C:\GitHub\TesArch-l500-val\MatlabDLL\Dev\Regression\Results\', 'z_drift');

%%
diary off