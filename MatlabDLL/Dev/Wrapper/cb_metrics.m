function Result = cb_metrics(t_v, x_mat, y_mat, dTarget, szChecker, xCent, yCent, show_flag, dummy_flag)
%***********************************************************************************
% Function description: This function obtains checker-board corners' locations over
% time and generated temperature-induced and jitter metrics.
% Function Matlab name: 
% Result = cb_metrics(t_v, x_mat, y_mat, dTarget, szChecker, xCent, yCent, show_flag, dummy_flag)
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
% yCent: Double. Central pixel y-location.
% show_flag: Double. If set to 1, the function displays relevant graphs. Else set to 0.
% dummy_flag: Double. If set to 1, the function does nothing. Else set to 0.
% Output:
% Result.jitter_mean_x: Double. Jitter in x-direction, averaged over corners [pxl]
% Result.jitter_mean_y: Double. Jitter in y-direction, averaged over corners [pxl]
% Result.jitter_max_x: Double. Jitter in x-direction, worst corner result [pxl]
% Result.jitter_max_y: Double. Jitter in y-direction, worst corner result [pxl]
% Result.drift_offset_x: Double. (Thermal) drift in x-direction - offset
% value [pxl]. Offset correponds to center pixel movement.
% Result.drift_offset_y: Double. (Thermal) drift in y-direction - offset
% value [pxl]. Offset correponds to center pixel movement.
% Result.drift_scale_x: Double. (Thermal) drift in x-direction - scale
% value [pxl]. Scale correponds to pixel shift difference between the
% corners.
% Result.drift_scale_y: Double. (Thermal) drift in y-direction - scale
% value [pxl]. Scale correponds to pixel shift difference between the
% corners.
% Result.zenith_tilt_x: Double. Zenith x-tilt as estimated from the center checker [deg]
% Result.zenith_tilt_y: Double. Zenith y-tilt as estimated from the center checker [deg]
% Result.zenith_tilt_r: Double. Zenith r-tilt as estimated from the center checker [deg]
% Result.MatlabErrorCode: Double. Contains the error code (0 if no error exists).
% Result.MatlabErrorString: String. Contains the error description (‘none’ is no error exists).
%************************************************************************************
    Result.jitter_mean_x = 0;
    Result.jitter_mean_y = 0;
    Result.jitter_max_x = 0;
    Result.jitter_max_y = 0;
    Result.drift_offset_x = 0;
    Result.drift_offset_y = 0;
    Result.drift_scale_x = 0;
    Result.drift_scale_y = 0;
    Result.zenith_tilt_x = 0;
    Result.zenith_tilt_y = 0;
    Result.zenith_tilt_r = 0;
    Result.MatlabErrorCode = 0;
    Result.MatlabErrorString = '';

    if dummy_flag
        dump_file_name = [mfilename, cur_time_stamp_ut, '.mat'];
        save(['C:\Dump\', dump_file_name]);
        return;        
    end

    [Result_x, th_x_v, slope_v_x, pp_x] = cb_metrics_sa(t_v, x_mat, y_mat, dTarget, szChecker, xCent, 0, dummy_flag);
    [Result_y, th_y_v, slope_v_y, pp_y] = cb_metrics_sa(t_v, y_mat, x_mat, dTarget, szChecker, yCent, 0, dummy_flag);
    
    Result.jitter_mean_x = Result_x.jitter_mean;
    Result.jitter_mean_y = Result_y.jitter_mean;
    Result.jitter_max_x = Result_x.jitter_max;
    Result.jitter_max_y = Result_y.jitter_max;
    Result.drift_offset_x = Result_x.drift_offset;
    Result.drift_offset_y = Result_y.drift_offset;
    Result.drift_scale_x = Result_x.drift_scale;
    Result.drift_scale_y = Result_y.drift_scale;
    Result.zenith_tilt_x = Result_x.zenith_tilt;
    Result.zenith_tilt_y = Result_y.zenith_tilt;
    Result.zenith_tilt_r = asind(sqrt(sind(Result.zenith_tilt_x).^2 + sind(Result.zenith_tilt_y).^2));
    
    %% visualization
    if (show_flag)
        figure(hfig_gen_ut(mfilename)); clf;
        subplot(121)
        plot(th_x_v, slope_v_x, 'x', th_x_v, polyval(pp_x, th_x_v));
        title({sprintf('[X]: Scale: %.3f %%/degC, Offset: %.1f mdeg/degC,', Result.drift_scale_x, Result.drift_offset_x*1e3),
            sprintf('Jitter(max): %.1f(%.1f) mdeg, Tilt: %.2f deg', Result.jitter_mean_x*1e3, Result.jitter_max_x*1e3, Result.zenith_tilt_x)});
        ylabel('d\theta_x');
        xlabel('\theta_x');
        subplot(122)
        plot(th_y_v, slope_v_y, 'x', th_y_v, polyval(pp_y, th_y_v));
        title({sprintf('[Y]: Scale: %.3f %%/degC, Offset: %.1f mdeg/degC,', Result.drift_scale_y, Result.drift_offset_y*1e3),
            sprintf('Jitter(max): %.1f(%.1f) mdeg, Tilt: %.2f deg', Result.jitter_mean_y*1e3, Result.jitter_max_y*1e3, Result.zenith_tilt_y)});
        ylabel('d\theta_y');
        xlabel('\theta_y');
    end        
    
    
end