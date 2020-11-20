clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))] ;
    
    flist       = {'7t11Hz','11t15Hz'};
    tlist       = {'m600m200','p200p600','p600p1000','p1400p1800'};
    
    for f = 1:length(flist)
        for t = 1:length(tlist)
            
            for n_prt = 1:3
                
                fname_in = ['../data/all_data/' suj '.pt' num2str(n_prt) '.CnD.' tlist{t} '.' flist{f} '.PCCSource1cm.mat'];
                fprintf('Loading %s\n',fname_in)
                load(fname_in)
                
                tmp(:,n_prt)  = network_full.degrees;
                template.pos  = source_conn.pos;
                template.dim  = source_conn.dim;

                clear network_full source_conn source_tmp
                
            end
            
            source_gavg(:,sb,f,t)  = squeeze(mean(tmp,2)); clear tmp;

        end
    end
end

clearvars -except source_gavg template; 

for nfreq = 2
    for ntime = 1:4
        
        source2plot                       = [];
        source2plot.pos                   = template.pos;
        source2plot.dim                   = template.dim;
        %         source2plot.pow                   = squeeze(mean(source_gavg(:,:,nfreq,ntime),2));
       
        
        %         figure;
        cfg               = [];
        cfg.funcolorlim   = [0 130];
        
        cfg.method        = 'surface';
        cfg.funparameter  = 'pow';
        cfg.funcolormap   = 'jet';
        ft_sourceplot(cfg, source2plot);
        %         view([-150 30]);
        
    end
end