work_dir = '\\143.185.124.250\Users\Netanel\IV2 Val Tester integration\development of Z over temp-time\every ~1 sec\';

fnames = dir([work_dir, 'Z_*.bin']);

n_files = length(fnames);
width = 1024;
height = 768;
z2mm = 4;

z_im_arr = cell(1, n_files);
h = waitbar(0, 'Current status');
for ii=1:n_files
    cur_f = [work_dir, fnames(ii).name];
    fid = fopen(cur_f, 'r');
    z_im_arr{ii} = reshape(fread(fid, 'int16=>int16'), width, height)';
    fclose(fid);
    waitbar(ii/n_files, h);
end

%%
z2mm = 4;
t_v = 0:(n_files-1);

[sy, sx] = size(z_im_arr{1});
st = length(z_im_arr);

z_im_raster_mat = double([z_im_arr{:}])/z2mm;
z_im_raster_mat = reshape(z_im_raster_mat, [sy*sx, st]);


z_median_v = median(z_im_raster_mat, 1);
z_no_offset_v = z_median_v - mean(z_median_v);
z_drift_slope = t_v' \ z_no_offset_v';


%%
plot(t_v, z_median_v, t_v, t_v * z_drift_slope + mean(z_median_v))
title(sprintf('Z-drift is %.1e mm/degC', z_drift_slope));
xlabel('Temp. [degC]');
ylabel('Z (median) [mm]');
