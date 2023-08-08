function [w, h] = CHToolbox_BASIC_TransDVA2Pixel(dva, monitor, screen)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% used to calculate the stimulus size in pixel
% dva could be a number or a vector(width, height)
% only use h if it is 2D display
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pix_per_dva = 0.5*screen.resolution ./ atand(0.5*monitor.size/monitor.distance);
size_in_pixel = round(dva .* pix_per_dva);
w = size_in_pixel(1);
h = size_in_pixel(2);

end