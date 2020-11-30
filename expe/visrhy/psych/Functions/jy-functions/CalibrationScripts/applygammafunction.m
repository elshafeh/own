%% Create gamma function


load(calibratiofile)

num_colors = 255;	% number of gray levels to use in mpcmaplist, should be uneven
mpc_map_list = zeros(256,3);	% color look-up table of 256 RGB values, RANGE 0-1

% make grayscale gradient
temp_trial = linspace(mean_lum-amp,mean_lum+amp,num_colors)';

% Get background, black and white index
bgd_color_idx = find(temp_trial==.5) -1;	% idx of background colour in mpcmaplist, subtract 1 for range 0-255
black_idx = find(temp_trial==0) -1;
white_idx = find(temp_trial==1) -1;

mpc_map_list(1:num_colors,:) = repmat(temp_trial, [1 3]);
mpc_map_list(256,1:3) = 1;
mpc_map_list = round(map2map(mpc_map_list,gamInverse));


%% Apply gamma function


% Allow alpha blending
Screen('BlendFunction', wptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('LoadCLUT', wptr, mpc_map_list);