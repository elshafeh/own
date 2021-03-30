function data_out = h_interpolatespike_onavg(data_in)

data_out                                = data_in;
avg                                     = ft_timelockanalysis([],data_in);

ft_progress('init','text',    'Please wait...');

% go channel by channel and find the max on the AVERAGED signal
for nchan = 1:length(data_in.label)
    
    % part to show function progress instead of a blank screen
    a                                   = nchan;
    b                                   = length(data_in.label);
    ft_progress(a/b, 'removing spikes channel %d from %d\n', a, b);
    
    % find max on average and then remove it 
    % extract data
    data_matrix                         = avg.avg(nchan,:);
    time_axis                           = avg.time;
    % define arbitrary window where spike lives
    spikewindow                         = [0 0.015];
    
    % zoom in on window and find max value
    t1                                  = nearest(time_axis,spikewindow(1));
    t2                                  = nearest(time_axis,spikewindow(2));
    
    mtrx                                = zeros(1,length(data_matrix));
    mtrx(t1:t2)                         = data_matrix(t1:t2);
    
    t_max                               = time_axis(find(mtrx == max(mtrx)));
    t_max                               = t_max(1);
    
    window_width                        = 0.005;
    lm1                                 = nearest(time_axis, t_max-window_width);
    lm2                                 = nearest(time_axis,t_max+window_width);
    
    replace                             = zeros(1,length(time_axis));
    replace(lm1:lm2) = 1;
    
    begsample                           = 1;
    endsample                           = length(data_matrix);
    
    x                                   = time_axis(begsample:endsample);
    y                                   = data_matrix(begsample:endsample);
    xx                                  = x; % this is where we want to know the interpolated values
    x                                   = x(~replace(begsample:endsample)); % remove the part that needs to be interpolated
    y                                   = y(~replace(begsample:endsample)); % remove the part that needs to be interpolated
    yy                                  = interp1(x, y, xx, 'nearest'); % this may contain nans
    
    for ntrial = 1:length(data_in.time)
        data_matrix                     = data_in.trial{ntrial}(nchan,:);
        data_matrix(lm1:lm2)            = yy(lm1:lm2);
        data_out.trial{ntrial}(nchan,:)	= data_matrix; clear data_matrix;
    end
    
end