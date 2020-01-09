function [Result] = z_drift_sa(t_v, z_im_raster_mat)
%Z_DRIFT_SA Summary of this function goes here
%   Detailed explanation goes here
    z_median_v = nanmedian(z_im_raster_mat, 1);
    z_drift_offset = mean(z_median_v);
    z_no_offset_v = z_median_v - z_drift_offset;

    
    Result.z_drift_slope = t_v' \ z_no_offset_v';
    Result.z_drift_offset = z_drift_offset;
    Result.z_median_v = z_median_v;
end

