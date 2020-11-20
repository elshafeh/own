clear ; clc ; dleiftrip_addpath ;

suj_list = [1:4 8:17];

cnd_freq = 1:4;
cnd_time = 0:0.1:1;

load ../data/template/source_struct_template_MNIpos.mat; template_source = source ; clear source ;

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    for conditions = 1:2
        source_avg{sb,conditions}.pow    = zeros(length(template_source.pos),length(cnd_freq),length(cnd_time));
        source_avg{sb,conditions}.pos    = template_source.pos;
        source_avg{sb,conditions}.dim    = template_source.dim;
        source_avg{sb,conditions}.freq   = cnd_freq;
        source_avg{sb,conditions}.time   = cnd_time;
    end
    
end

cfg                     =   [];cfg.dim                 =   source_avg{1,1}.dim;cfg.method              =   'montecarlo';
cfg.statistic           =   'depsamplesT';
cfg.parameter           =   'pow';cfg.correctm            =   'cluster';
cfg.clusterstatistic    =   'maxsum';cfg.numrandomization    =   1000;
cfg.alpha               =   0.025;cfg.tail                =   0;cfg.clustertail         =   0;cfg.design(1,:)         =   [1:14 1:14];
cfg.design(2,:)         =   [ones(1,14) ones(1,14)*2];cfg.uvar                =   1;cfg.ivar                =   2;
cfg.clusteralpha        =   0.05;             % First Threshold
stat                    =   ft_sourcestatistics(cfg,source_avg{:,2},source_avg{:,1}) ;