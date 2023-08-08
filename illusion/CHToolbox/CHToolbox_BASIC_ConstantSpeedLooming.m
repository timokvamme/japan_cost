function [size_in_pixel_vector] = CHToolbox_BASIC_ConstantSpeedLooming(max_size, speed, duration, monitor, screen)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% use to calculate the size of the looming stimulus at each frame
% max_size the end size of the looming stimulus, in degree
% speed cm/s
% only use h if it is 2D display
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pix_per_dva = 0.5*screen.resolution ./ atand(0.5*monitor.size/monitor.distance);
r0 = monitor.distance * tand(max_size);
t = 0 : screen.ifi : ceil(duration/screen.ifi)*screen.ifi;
for i = 1: length(duration)
	dva_all{i} = atand(r0 ./ (monitor.distance + speed*(duration(i)-t)));
	size_in_pixel_vector{i} = round(dva_all{i} * pix_per_dva(2));
end

end