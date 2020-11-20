clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))] ;
    
    flist       = {'7t11Hz','11t15Hz'};
    tlist       = {'m600m200','p200p600','p600p1000','p1400p1800'};
    
    for f = 1
        for t = 1:length(tlist)
            
            for n_prt = 1:3
                
                fname_in = ['../data/all_data/' suj '.pt' num2str(n_prt) '.CnD.' tlist{t} '.' flist{f} '.PCCSource1cm.mat'];
                fprintf('Loading %s\n',fname_in)
                load(fname_in)
                
                tmp(:,:,n_prt)  = source_plv.plvspctrm;
                template.pos    = source_conn.pos;
                template.dim    = source_conn.dim;
                
                clear network_full source_conn source_tmp source_plv
                
            end
            
            source_gavg(:,:,sb,f,t)  = squeeze(mean(tmp,3)); clear tmp;
            
        end
    end
end

clearvars -except source_gavg template;

source      = [];
source.pos  = template.pos;
source.dim  = template.dim;
source.pow  = ones(length(source.pos),1);
indxH       = h_createIndexfieldtrip(source);

for roi = 80
    for nfreq = 1
        for ntime = 1:4
            
            source2plot                       = [];
            source2plot.pos                   = template.pos;
            source2plot.dim                   = template.dim;
            source2plot.pow                   = squeeze(mean(source_gavg(:,:,:,nfreq,ntime),3));
            
            bsl                               = squeeze(mean(source_gavg(:,:,:,nfreq,1),3));
            
            source2plot.pow                   = source2plot.pow -bsl;
            
            flg                               = indxH(indxH(:,2)==roi,1);
            source2plot.pow                   = squeeze(mean(source2plot.pow(flg,:),1))';
            
            source2plot.pow(source2plot.pow==0) = NaN;
            
            cfg                     =   [];
            cfg.method              =   'surface';
            cfg.funparameter        =   'pow';
            cfg.funcolorlim         =   [-0.1 0.1];
            cfg.opacitylim          =   [-0.1 0.1];
            cfg.opacitymap          =   'rampup';
            cfg.colorbar            =   'off';
            cfg.camlight            =   'no';
            cfg.funcolormap         = 'jet';
            cfg.projthresh          =   0.2;
            cfg.projmethod          =   'nearest';
            cfg.surffile            =   'surface_white_both.mat';
            cfg.surfinflated        =   'surface_inflated_both_caret.mat';
            ft_sourceplot(cfg, source2plot);
            
            %         view([-150 30]);
            
        end
    end
end