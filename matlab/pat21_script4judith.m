clear ; clc ;  dleiftrip_addpath ;

% let's say you have a freq structure
% you can apply a baseline

cfg                         = [];
cfg.baseline                = [-0.6 -0.2];
cfg.baselinetype            = 'relchange';
freq                        = ft_freqbaseline(cfg,freq);

c_list = 1:2; % let's you plot left and right STG
f_list = [7 15]; % and you wanna plot from 7 to 15
t_list = [-0.8 1]; % from -0.8 to 1 sec

f1 = find(round(freq.freq)      == round(f_list(f)));
f2 = find(round(freq.freq)      == round(f_list(end)));
t1 = find(round(freq.time,2)    == round(t_list(t),2));
t2 = find(round(freq.time,2)    == round(t_list(end),2));

data        = freq.powspctrm(c_list,f1:f2,t1:t2);

data = squeeze(mean(data,2) ; % average over frequency

% and then plot

x = t_list ;
y = data ; % may be its other way 

plot(x,y)