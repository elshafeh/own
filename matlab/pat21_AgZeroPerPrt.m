clear ; clc ;

load ../data/template/source_struct_template_MNIpos.mat;
load ../data/yctot/rt/rt_CnD_adapt.mat ;
load ../data/yctot/rt/CnD_part_index.mat

template_source = source ; clear source ;

suj_list = [1:4 8:17];

cnd_time = {{'.m600m200','.p700p1100'},{'.m600m200','.p700p1100'},{'.m400m200','.p900p1100'}};

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    cnd_freq = {'7t11','11t15','7t15'} ;
    
    for cf = 1:3
        for ix = 1:2
            for cp = 1:3
                
                fname = dir(['../data/source/' suj '.pt' num2str(cp) ...
                    '.CnD.' cnd_freq{cf} 'Hz' ...
                    cnd_time{cf}{ix} '.SingleTrial.NewDpss.mat']);
                
                fname = fname.name;
                fprintf('Loading %50s\n',fname);
                load(['../data/source/' fname]);
                
                source = nanmean(source,2);
                
                if isstruct(source);
                    source = source.avg.pow;
                end
                
                src_carr{cp,ix} = source ; clear source ;
                
            end
        end
        
        for cp = 1:3
            data(cp,:) = (src_carr{cp,2} - src_carr{cp,1}) ./ src_carr{cp,1} ;
            rt(cp,1)   = median(rt_all{sb}(indx_pt(indx_pt(:,1)==sb & indx_pt(:,2) == cp,3)));
        end
        
        clear src_carr ;
        
        [rho,p]                                     = corr(data,rt , 'type', 'Spearman');
        rho(p < 0.05)                               = 0 ;
        rhoF                                        = .5.*log((1+rho)./(1-rho));
        
        source_avg{sb,cf,1}.pow                   = rhoF;             % act
        source_avg{sb,cf,2}.pow(length(rho),1)    = 0;                % bsl
        
        clear rho rhoF p data rt
        
        load ../data/template/source_struct_template_MNIpos.mat
        
        for cnd_rho = 1:2
            source_avg{sb,cf,cnd_rho}.pos    = source.pos;
            source_avg{sb,cf,cnd_rho}.dim    = source.dim;
        end
        
        clear source
    end
end

clearvars -except source_avg

for cf = 1:3
    cfg                                                     =   [];
    cfg.dim                                                 =   source_avg{1,1}.dim;
    cfg.method                                              =   'montecarlo';
    cfg.statistic                                           =   'depsamplesT';
    cfg.parameter                                           =   'pow';
    cfg.correctm                                            =   'cluster';
    cfg.clusteralpha                                        =   0.05;             % First Threshold
    cfg.clusterstatistic                                    =   'maxsum';
    cfg.numrandomization                                    =   1000;
    cfg.alpha                                               =   0.025;
    cfg.tail                                                =   0;
    cfg.clustertail                                         =   0;
    cfg.design(1,:)                                         =   [1:14 1:14];
    cfg.design(2,:)                                         =   [ones(1,14) ones(1,14)*2];
    cfg.uvar                                                =   1;
    cfg.ivar                                                =   2;
    stat{cf}                                                =   ft_sourcestatistics(cfg,source_avg{:,cf,1},source_avg{:,cf,2});
    stat{cf}.cfg                                            =   [];
end

for cf = 1:3
    [min_p(cf),p_val{cf}]       =   h_pValSort(stat{cf});
    vox_list{cf}                =   FindSigClusters(stat{cf},min_p(cf)+0.00001);
end

for cf = 1:3
    
    p_lim = min_p(cf)+0.0001 ;
    
    stat_int{cf}          = h_interpolate(stat{cf});
    stat_int{cf}.cfg      = [];
    stat_int{cf}.mask     = stat_int{cf}.prob < p_lim;
    
    cfg                     = [];
    cfg.method              = 'slice';
    cfg.funparameter        = 'stat';
    cfg.maskparameter       = 'mask';
    cfg.colorbar            = 'no';
    cfg.funcolorlim         = [-4 4];
    ft_sourceplot(cfg,stat_int{cf});clc;
    
end