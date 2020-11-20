clear ; clc ; dleiftrip_addpath ;

suj_list = [1:4 8:17];

ext_freq = {'60t100Hz'};
ext_time = {'m100m0','p0p100','p200p300','p300p400','p400p500','p500p600','p600p700','p700p799','p800p900','p900p1000','p1000p1100'};

ext_bsl  = 'm200m100';

cnd_freq    = 80;
cnd_time    = -0.1:0.1:1;

load ../data/template/source_struct_template_MNIpos.mat; template_source = source ; clear source ;

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    lst_cnd2compare = {'.MinSameEvokedSource.mat','.MinAdaptedEvokedSource.mat'};
    
    for ncond = 1:length(lst_cnd2compare)
        
        source_avg{sb,ncond}.pow    = zeros(length(template_source.pos),length(cnd_freq),length(cnd_time));
        source_avg{sb,ncond}.pos    = template_source.pos;
        source_avg{sb,ncond}.dim    = template_source.dim;
        source_avg{sb,ncond}.freq   = cnd_freq;
        source_avg{sb,ncond}.time   = cnd_time;
        
        for nfreq = 1:length(ext_freq)
            for ntime = 1:length(ext_time)
                
                src_carr{1} =[]; src_carr{2} =[];
                
                for npart = 1:3
                    
                    ext_lock    = 'NCnD';
                    ext_source  = lst_cnd2compare{ncond};
                    
                    fname = dir(['../data/source/' suj '.pt' num2str(npart) '.' ext_lock '.' ext_bsl '.' ext_freq{nfreq} ext_source]);
                    fprintf('Loading %50s\n',fname.name);load(['../data/source/' fname.name]);
                    
                    src_carr{1} = [src_carr{1} source]; clear source ;
                    
                    fname = dir(['../data/source/' suj '.pt' num2str(npart) '.' ext_lock '.' ext_time{ntime} '.' ext_freq{nfreq} ext_source]);
                    fprintf('Loading %50s\n',fname.name);load(['../data/source/' fname.name]);
                    
                    src_carr{2} = [src_carr{2} source]; clear source ;
                    
                end
                
                bsl                                             = nanmean(src_carr{1},2);
                act                                             = nanmean(src_carr{2},2);
                pow                                             = (act-bsl)./bsl; clear bsl act src_carr;
                %                 pow                                             = (act-bsl); clear bsl act src_carr;
                
                source_avg{sb,ncond}.pow(:,nfreq,ntime)    = pow ; clear pow;
                
            end
        end
    end
end

clearvars -except source_avg ;

cfg                     =   [];
cfg.dim                 =   source_avg{1,1}.dim;
cfg.method              =   'montecarlo';
cfg.statistic           =   'depsamplesT';
cfg.parameter           =   'pow';
cfg.correctm            =   'cluster';
cfg.clusterstatistic    =   'maxsum';
cfg.numrandomization    =   1000;
cfg.alpha               =   0.025;
cfg.tail                =   0;
cfg.clustertail         =   0;
cfg.design(1,:)         =   [1:14 1:14];
cfg.design(2,:)         =   [ones(1,14) ones(1,14)*2];
cfg.uvar                =   1;
cfg.ivar                =   2;
cfg.clusteralpha        =   0.05;             % First Threshold

stat                    =   ft_sourcestatistics(cfg,source_avg{:,1},source_avg{:,2}) ;

for cnd_s = 1:length(stat)
    [min_p,p_val]           =   h_pValSort(stat);
end

indxH               = h_createIndexfieldtrip;
atlas               = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii');

stat.mask = stat.prob < 0.3;
big_pow = stat.mask .* stat.stat;

for nregion = 1:length(atlas.tissuelabel)
    
    ix  = indxH(indxH(:,2)==nregion,1);
    pow = squeeze(nanmean(big_pow(ix,:,:),1));
    
    if nanmean(nanmean(pow)) ~= 0
        
        figure;
        avg            = pow;
        plot(stat.time,avg);
        title(atlas.tissuelabel(nregion));
        
    end
end