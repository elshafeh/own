clear ; clc ; 

load ../data/yctot/gavg/VN_DisfDis.pe.mat

for cdis = 1:2   
%     gavg{cdis} = ft_timelockgrandaverage([],allsuj{:,cdis,:});
    gavg{cdis} = ft_timelockgrandaverage([],allsuj{:,:,cdis});
end

cfg         = [];
cfg.layout  = 'CTF275.lay';
cfg.zlim    = [-40 40];
cfg.xlim    = 0:0.1:0.5;
cfg.comment = 'no';
ft_topoplotER(cfg,gavg{1}) ; figure ;
ft_topoplotER(cfg,gavg{2}) ;
