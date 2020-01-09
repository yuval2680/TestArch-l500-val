function Result = z_drift(t_v, z_im_cell, z2mm, show_flag, dummy_flag)
%***********************************************************************************
% Function description: This function obtains checker-board corners' locations over
% time and generated temperature-induced and jitter metrics.
% Function Matlab name: 
% Result = z_drift(t_v, z_mat_cell, z2mm, show_flag, dummy_flag)
% Input:
% t_v: Double.  1 x T vector. Temperature readings that correspond to each set of corners [degC].
% z_im_cell: Cell array. Size(1, T) cell array with M x N matrices. Gets corners' x-locations, where M is
% the image height, N is the image width and T is the frames dimension (over time).
% z2mm: Double. Conversion factor from z-materices values to real-world
% distances in mm.
% show_flag: Double. If set to 1, the function displays relevant graphs. Else set to 0.
% dummy_flag: Double. If set to 1, the function does nothing. Else set to 0.
% Output:
% Result.z_drift_slope: Double. (Thermal) drift in z-direction - slope [mm/degC].
% Result.z_drift_offset: Double. (Thermal) drift in z-direction - offset [mm].
% Result.MatlabErrorCode: Double. Contains the error code (0 if no error exists).
% Result.MatlabErrorString: String. Contains the error description ('' is no error exists).
%************************************************************************************
    Result.z_drift_slope = 0;
    Result.z_drift_offset = 0;
    Result.MatlabErrorCode = 0;
    Result.MatlabErrorString = '';

    if dummy_flag
        dump_file_name = [mfilename, cur_time_stamp_ut, '.mat'];
        save(['C:\Dump\', dump_file_name]);
        return;        
    end

    try
        %% preparation
        [sy, sx] = size(z_im_cell{1});
        st = length(t_v);

        z_im_raster_mat = double([z_im_cell{:}])/z2mm;
        z_im_raster_mat = reshape(z_im_raster_mat, [sy*sx, st]);

        %% calculation
        Result_sa = z_drift_sa(t_v, z_im_raster_mat);

        Result.z_drift_slope = Result_sa.z_drift_slope;
        Result.z_drift_offset = Result_sa.z_drift_offset;
        
    catch ME
        Result.MatlabErrorCode = 1;
        Result.MatlabErrorString = ME.identifier;
        return;
    end

    %% visualization
    if (show_flag)
        figure(hfig_gen_ut(mfilename)); clf;
        plot(t_v, Result_sa.z_median_v, t_v, t_v * Result.z_drift_slope + Result.z_drift_offset);
        title(sprintf('Z-drift is %.1e mm/degC', Result.z_drift_slope));
        xlabel('Temp. [degC]');
        ylabel('Z (median) [mm]');
    end               
end