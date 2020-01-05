function [Result, th_x_v, slope_v, pp] = cb_metrics_sa(t_v, x_mat, y_mat, dTarget, szChecker, xCent, show_flag)
%***********************************************************************************
% Function description: This function obtains checker-board corners' locations over
% time and generated temperature-induced and jitter metrics.
% Function Matlab name: 
% Result = cb_metrics_sa(t_v, x_mat, y_mat, dTarget, szChecker, xCent, show_flag, dummy_flag)
% Input:
% t_v: Double.  1 x T vector. Temperature readings that correspond to each set of corners [degC].
% x_mat: Double. M x N x T matrix. Gets corners' x-locations, where M is
% the y-direciton dimention, N is the x-direction dimention and T
% is the frames dimention (over time).
% y_mat: Double. M x N x T matrix. Gets corners' y-locations, where M is
% the y-direciton dimention, N is the x-direction dimention and T
% is the frames dimention (over time). x_mat and y_mat dimentions must
% agree.
% dTarget: Double. Distane of target from DUT.
% szChecker: Double. Checker size.
% xCent: Double. Central pixel x-location.
% show_flag: Double. If set to 1, the function displays relevant graphs. Else set to 0.
% Output:
% Result.jitter_mean: Double. Jitter in x-direction, averaged over corners [deg]
% Result.jitter_max: Double. Jitter in x-direction, worst corner result [deg]
% Result.drift_offset: Double. (Thermal) drift in x-direction - offset value [deg/degC].
% Result.drift_scale: Double. (Thermal) drift in x-direction - scale value [%/degC].
% Result.zenith_tilt: Double. Zenith x-tilt as estimated from the center checker [deg]
% th_x_v: Double. vector of corners' locations (for visualization).
% slope_v: Double. vector of corners' shifts (for visualization).
% pp: Double. Polynomial fit coefficients (for visualization).
%************************************************************************************
    sz = size(x_mat);
    
    dx_mat_hz = x_mat(:, 1:end-1, :) - x_mat(:, 2:end, :);
    dy_mat_hz = y_mat(:, 1:end-1, :) - y_mat(:, 2:end, :);

    r_mat_hz = sqrt(dx_mat_hz.^2 + dy_mat_hz.^2);

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
    fit_mat = (t_adj*slope_v)'; %kron(t_adj', slope_v');
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


    %% visualization
    if (show_flag)
        figure(hfig_gen_ut(mfilename)); clf;
        plot(th_x_v, slope_v, 'x', th_x_v, polyval(pp, th_x_v));
        title({sprintf('Scale: %.3f %%/degC, Offset: %.1f mdeg/degC,', Result.drift_scale, Result.drift_offset*1e3),
            sprintf('Jitter(max): %.1f(%.1f) mdeg, Tilt: %.2f deg', Result.jitter_mean*1e3, Result.jitter_max*1e3, Result.zenith_tilt)});
        ylabel('d\theta');
        xlabel('\theta');
    end        
end