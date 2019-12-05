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

%%
xCent = 320;
szChecker = 105;
dTarget = 672.7;
show_flag = 1;
%%
dx_mat_hz = x_mat(:, 1:end-1, :) - x_mat(:, 2:end, :);
dx_mat_vr = x_mat(1:end-1, :, :) - x_mat(2:end, :, :);
dy_mat_hz = y_mat(:, 1:end-1, :) - y_mat(:, 2:end, :);
dy_mat_vr = y_mat(1:end-1, :, :) - y_mat(2:end, :, :);

r_mat_hz = sqrt(dx_mat_hz.^2 + dy_mat_hz.^2);
r_mat_vr = sqrt(dx_mat_vr.^2 + dy_mat_vr.^2);

px2mm_x = szChecker./squeeze(mean(squeeze(mean(r_mat_hz, 1)), 1));

ii_v = 1:sz(3);
pp = polyfit(ii_v, px2mm_x, 2);
px2mm_x_fit = polyval(pp, 1);


%%
th_x_mat = atand((x_mat - xCent).*px2mm_x_fit./dTarget);
dth_x_mat = th_x_mat - th_x_mat(:, :, 1);

%% tilt metric
x_mat0 = squeeze(x_mat(:, :, 1));
x_mean = mean(x_mat0(:));
dth_x = atand((x_mean - xCent)*px2mm_x_fit./dTarget);

%% drift metrics
tic
dth_x_mat_stack = reshape(dth_x_mat, [sz(1)* sz(2), sz(3)]);
th_x_v = reshape(th_x_mat(:, :, 1), [sz(1) * sz(2), 1])';
mean_func_y_v = mean(dth_x_mat_stack, 2);
dth_x_mat_stack_adj = dth_x_mat_stack - mean_func_y_v;
mean_func_x = mean(t_v);
t_adj = t_v' - mean_func_x;
slope_v = t_adj \ dth_x_mat_stack_adj';
pp = polyfit(th_x_v, slope_v, 1);
offset = pp(2);
scale = pp(1)*100;

%% jitter metrics
fit_mat = kron(t_adj', slope_v');
resid_dth = dth_x_mat_stack_adj - fit_mat;
resid_std_v = squeeze(std(resid_dth, [], 2));
jitter_mean = mean(resid_std_v);
jitter_max = max(resid_std_v);

%% Results population
Result.jitter_mean = jitter_mean;
Result.jitter_max = jitter_max;
Result.drift_offset = offset;
Result.drift_scale = scale;
Result.zenith_tilt = dth_x;


if (show_flag)
    figure(hfig_gen_ut(mfilename)); clf;
    plot(th_x_v, slope_v, 'x', th_x_v, polyval(pp, th_x_v));
    title({sprintf('Scale: %.3f %%/degC, Offset: %.1f mdeg/degC,', Result.drift_scale, Result.drift_offset*1e3),
        sprintf('Jitter(max): %.1f(%.1f) mdeg, Tilt: %.2f deg', Result.jitter_mean*100, Result.jitter_max*100, Result.zenith_tilt)});
    ylabel('d\theta');
    xlabel('\theta');
end        
%%
tic
func_x = t_v' - mean(t_v);
for r=1:sz(1)
    for c=1:sz(2)
        func_y = squeeze(dth_x_mat(r, c, :));
        func_y = func_y - mean(func_y);
        pp = polyfit(func_x, func_y, 1);
    end
end
toc