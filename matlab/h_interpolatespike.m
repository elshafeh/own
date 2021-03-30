function data_out = h_interpolatespike(data_in,interpolate_window,interpolate_method)

data_out                                    = data_in;
ft_progress('init','text',    'Please wait...');

% go channel by channel and find the max from single trial
for nchan = 1:length(data_in.label)
    for ntrial = 1:length(data_in.time)
        
        % part to show function progress instead of a blank screen
        a                                   = nchan;
        b                                   = length(data_in.label);
        ft_progress(a/b, 'removing spikes channel %d from %d\n', a, b);
        
        % find max on average and then remove it
        % extract data
        % define arbitrary window where spike lives
        spikewindow                         = [0 0.015];
        
        data_matrix                       	= data_in.trial{ntrial}(nchan,:);
        time_axis                           = data_in.time{ntrial};
        
        %         % zoom in on window and find max value
        %         t1                                  = nearest(time_axis,spikewindow(1));
        %         t2                                  = nearest(time_axis,spikewindow(2));
        %         mtrx                                = zeros(1,length(data_matrix));
        %         mtrx(t1:t2)                         = data_matrix(t1:t2);
        %         t_max                               = time_axis(find(mtrx == max(mtrx)));
        %         t_max                               = t_max(1); clear mtrx t1 t2
        %         t_max                               = 0.0075;
        %         window_width                        = 0.0075;
        
        lm1                                 = nearest(time_axis, interpolate_window(1));
        lm2                                 = nearest(time_axis, interpolate_window(2));
        
        replace                             = zeros(1,length(time_axis));
        replace(lm1:lm2) = 1;
        
        x                                   = time_axis;
        y                                   = data_matrix;
        
        if length(x) ~= length(y)
            error('time and data do not match')
        end
        
        xx                                  = x; % this is where we want to know the interpolated values
        x                                   = x(~replace); % remove the part that needs to be interpolated
        y                                   = y(~replace); % remove the part that needs to be interpolated
        
        if strcmp(interpolate_method,'zero')
            yy                              = data_matrix;
            yy(lm1:lm2)                     = 0;
        elseif strcmp(interpolate_method,'nan')
            yy                              = data_matrix;
            yy(lm1:lm2)                     = NaN;
        elseif strcmp(interpolate_method,'average')
            yy                              = data_matrix;
            yy(lm1:lm2)                     = mean(y);
        else
            yy                            	= interp1(x, y, xx, interpolate_method); % this may contain nans
        end
        
        data_out.trial{ntrial}(nchan,:)     = yy; 
        
        clear x y xx yy replace data_matrix;
        
    end
end