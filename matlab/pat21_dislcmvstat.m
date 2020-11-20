clear ; clc ; close all ; dleiftrip_addpath;

suj_list = [1:4 8:17];
load ../data/template/source_struct_template_MNIpos.mat
indx = h_createIndexfieldtrip(source);

for sb = 1:length(suj_list)
    
    suj         = ['yc' num2str(suj_list(sb))];
    ext_comp    = '';
    lst_time    = {'N1','P3a','P3b'};
    lst_dis     = {'','f'};
    
    for cnd = 1:3
        for cdis = 1:2
            
            source_carr = [];
            
            for prt = 1:3
                fname = dir(['../data/source/' suj '.pt' num2str(prt) '.' lst_dis{cdis} 'DIS.*' lst_time{cnd} '*']);
                fname = fname.name;
                fprintf('\nLoading %50s',fname);
                load(['../data/source/' fname]);
                source_carr = [source_carr source] ; clear source
            end
            
            source_avg{sb,cnd,cdis}.pow = nanmean(source_carr,2); clear source_carr;
            load ../data/template/source_struct_template_MNIpos.mat
            source_avg{sb,cnd,cdis}.pos            = source.pos ;
            source_avg{sb,cnd,cdis}.dim            = source.dim ;
            clear source;
            source_avg{sb,cnd,cdis}.pow(indx(indx(:,2) > 90,1)) = 0 ;
        end
    end
    
end

clearvars -except source_avg

close all ; cfg                 = h_prepare_cluster_source(0.003,source_avg{1,1});

for cnd = 1
    stat{cnd}                   = ft_sourcestatistics(cfg, source_avg{:,cnd,1},source_avg{:,cnd,2});
    stat{cnd}                   = rmfield(stat{cnd} ,'cfg');
    [min_p(cnd),p_val{cnd}]     = h_pValSort(stat{cnd});
    list{cnd}                   = FindSigClusters(stat{cnd},0.05);
end

for cnd = 1
    
    stat_int{cnd}            = h_interpolate(stat{cnd});
    stat_int{cnd}.mask       = stat_int{cnd}.prob < 0.05;
    stat_int{cnd}.stat       = stat_int{cnd}.stat .* stat_int{cnd}.mask;
    
    lft                      = stat_int{cnd}.stat(stat_int{cnd}.stat ~= 0);
    lft                      = lft(~isnan(lft));
    lim                      = median(lft);
    stat_int{cnd}.mask(stat_int{cnd}.stat < lim) = 0;
    
    cfg                         = [];
    cfg.method                  = 'slice';
    cfg.funparameter            = 'stat';
    cfg.maskparameter           = 'mask';
    cfg.nslices                 = 16;
    cfg.slicerange              = [70 84];
    cfg.funcolorlim             = [-5 5];
    ft_sourceplot(cfg,stat_int{cnd});clc;
    
end
