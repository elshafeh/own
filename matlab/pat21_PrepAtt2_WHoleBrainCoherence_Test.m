clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))] ;
    
    flist       = {'7t11Hz','11t15Hz'};
    tlist       = {'m600m200','p200p600','p600p1000','p1400p1800'};
    
    for f = 1:length(flist)
        for t = 1:length(tlist)
            
            for n_prt = 1:3
                
                fname_in      = ['../data/all_data/' suj '.pt' num2str(n_prt) '.CnD.' tlist{t} '.' flist{f} '.PCCSource1cm.mat'];
                fprintf('Loading %s\n',fname_in)
                load(fname_in)
                
                tmp(:,n_prt)  = network_full.degrees;
                template.pos  = source_conn.pos;
                template.dim  = source_conn.dim;

                clear network_full source_conn source_tmp
                
            end
            
            source_gavg{sb,f,t}.pow  = squeeze(mean(tmp,2)); clear tmp;
            source_gavg{sb,f,t}.pos  = template.pos;
            source_gavg{sb,f,t}.dim  = template.dim;
        end
    end
end

clearvars -except source_gavg

cfg                     =   [];
cfg.dim                 =   source_gavg{1,1}.dim;
cfg.method              =   'montecarlo';cfg.statistic           =   'depsamplesT';cfg.parameter           =   'pow';
cfg.correctm            =   'cluster';cfg.clusterstatistic    =   'maxsum';
cfg.numrandomization    =   1000;cfg.alpha               =   0.025;
cfg.tail                =   0;cfg.clustertail         =   0;cfg.design(1,:)         =   [1:14 1:14];cfg.design(2,:)         =   [ones(1,14) ones(1,14)*2];
cfg.uvar                =   1;cfg.ivar                =   2;

cfg.clusteralpha        =   0.05;             % First Threshold

for nfreq = 1:2
    for ntime = 2:4
        stat{nfreq,ntime-1}   =   ft_sourcestatistics(cfg,source_gavg{:,nfreq,ntime},source_gavg{:,nfreq,1}) ;
    end
end

for nfreq = 1
    for ntime = 1:3
        
        stat{nfreq,ntime}.mask      = stat{nfreq,ntime}.prob < 0.05;
        source.pos                  = stat{nfreq,ntime}.pos;
        source.dim                  = stat{nfreq,ntime}.dim;
        source.pow                  = stat{nfreq,ntime}.stat .* stat{nfreq,ntime}.mask;
        source.pow(source.pow == 0,:) = NaN;
        
        for iside = 1:3
            lst_side = {'left','right','both'}; lst_view = [-95 1;95,11;0 50];
            
            cfg                     =   [];
            cfg.method              =   'surface'; cfg.funparameter        =   'pow';
            cfg.funcolorlim         =   [-5 5]; cfg.opacitylim          =   [-3 3];
            cfg.opacitymap          =   'rampup';
            cfg.colorbar            =   'off'; cfg.camlight            =   'no';
            cfg.projthresh          =   0.2;
            cfg.projmethod          =   'nearest';
            cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat']; cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
            ft_sourceplot(cfg, source); view(lst_view(iside,1),lst_view(iside,2))
            
        end
    end
end