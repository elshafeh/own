clear ; clc ; dleiftrip_addpath ;

% for sb = 1:14
%
%     suj_list    = [1:4 8:17];
%     suj         = ['yc' num2str(suj_list(sb))] ;
%
%     flist       = {'7t11Hz','11t15Hz'};
%     tlist       = {'m600m200','p200p600','p600p1000','p1400p1800'};
%
%     for f = 1:length(flist)
%         for t = 1:length(tlist)
%
%             for n_prt = 1:3
%
%                 fname_in = ['../data/all_data/' suj '.pt' num2str(n_prt) '.CnD.' tlist{t} '.' flist{f} '.PCCSource1cm.mat'];
%                 fprintf('Loading %s\n',fname_in)
%                 load(fname_in)
%
%                 tmp(:,:,n_prt)  = source_plv.plvspctrm;
%                 template.pos    = source_conn.pos;
%                 template.dim    = source_conn.dim;
%
%                 clear network_full source_conn source_tmp source_plv
%
%             end
%
%             source_gavg{sb,f,t}.pow  = squeeze(mean(tmp,3)); clear tmp;
%             source_gavg{sb,f,t}.pos  = template.pos;
%             source_gavg{sb,f,t}.dim  = template.dim;
%
%         end
%     end
% end
%
% clearvars -except source_gavg;
%
% save('../data/yctot/WholeBrainPLVPack.mat','-v7.3');

load('../data/yctot/WholeBrainPLVPack.mat');

indxH           = h_createIndexfieldtrip(source_gavg{1,1,1});
lst_flg{1}      = indxH(indxH(:,2)==79 | indxH(:,2)==81,1);
lst_flg{2}      = indxH(indxH(:,2)==80 | indxH(:,2)==82,1);

for sb = 1:size(source_gavg,1)
    for nfreq = 1:size(source_gavg,2)
        for ntime = 1:size(source_gavg,3)
            for nroi = 1:length(lst_flg)
                
                new_source{sb,nfreq,ntime,nroi}       = source_gavg{sb,nfreq,ntime};
                
                new_source{sb,nfreq,ntime,nroi}.pow   = new_source{sb,nfreq,ntime,nroi}.pow(lst_flg{nroi},:);
                
                new_source{sb,nfreq,ntime,nroi}.pow   = mean(new_source{sb,nfreq,ntime,nroi}.pow,1);
                
                new_source{sb,nfreq,ntime,nroi}.pow   = squeeze(new_source{sb,nfreq,ntime,nroi}.pow)';
                
            end
        end
    end
end

clearvars -except new_source source_gavg ;

cfg                     =   [];
cfg.dim                 =   new_source{1,1}.dim;
cfg.method              =   'montecarlo';
cfg.statistic           =   'depsamplesT';
cfg.parameter           =   'pow';
cfg.correctm            =   'cluster';
cfg.clusteralpha        =   0.05;             % First Threshold
cfg.clusterstatistic    =   'maxsum';
cfg.numrandomization    =   1000;
cfg.alpha               =   0.025;
cfg.tail                =   0;
cfg.clustertail         =   0;
cfg.design(1,:)         =   [1:14 1:14];
cfg.design(2,:)         =   [ones(1,14) ones(1,14)*2];
cfg.uvar                =   1;
cfg.ivar                =   2;

for nfreq = 1:size(new_source,2)
    for ntime = 2:size(new_source,3)
        for nroi = 1:size(new_source,4)
            stat{nfreq,ntime-1,nroi}                                = ft_sourcestatistics(cfg,new_source{:,nfreq,ntime,nroi},new_source{:,nfreq,1,nroi}) ;
            [min_p(nfreq,ntime-1,nroi),p_val{nfreq,ntime-1,nroi}]   = h_pValSort(stat{nfreq,ntime-1,nroi});
            clc;
        end
    end
end

for nfreq = 1%:size(stat,1)
    for ntime = 1:size(stat,2)
        for nroi = 2%1:size(stat,3)
            
            stat{nfreq,ntime,nroi}.mask         = stat{nfreq,ntime,nroi}.prob < 0.2;
            
            source2plot                         = [];
            source2plot.pos                     = stat{nfreq,ntime,nroi}.pos;
            source2plot.dim                     = stat{nfreq,ntime,nroi}.dim;
            source2plot.pow                     = stat{nfreq,ntime,nroi}.stat .* stat{nfreq,ntime,nroi}.mask;
            
            source2plot.pow(source2plot.pow==0) = NaN;
            
            cfg                     =   [];
            cfg.method              =   'surface';
            cfg.funparameter        =   'pow';
            cfg.funcolorlim         =   [-5 5];
            cfg.opacitylim          =   [-5 5];
            cfg.opacitymap          =   'rampup';
            cfg.colorbar            =   'off';
            cfg.camlight            =   'no';
            cfg.funcolormap         =   'jet';
            cfg.projthresh          =   0.2;
            cfg.projmethod          =   'nearest';
            cfg.surffile            =   'surface_white_both.mat';
            cfg.surfinflated        =   'surface_inflated_both_caret.mat';
            ft_sourceplot(cfg, source2plot);
            
        end
    end
end