clear;clc;

suj_list = [1:4 8:17];

for a = 1:length(suj_list);
    
    for b = 1:3
        
        lck = 'CnD' ;
        suj = ['yc' num2str(suj_list(a))] ;
        
        fname_in = [suj '.pt' num2str(b) '.' lck];
        fprintf('\n\nLoading %50s \n\n',fname_in);
        load(['../data/' suj '/elan/' fname_in '.mat'])
        
        data = data_elan ;
        
        clear data_elan
        
        st_point = [-0.6 0.6];
        
        for timep = 1:2
            
            tim_win     = 0.4;
            
            lm1 = st_point(timep)-0.025;
            lm2 = st_point(timep)+tim_win+0.025;
            
            cfg             = [];
            cfg.toilim      = [lm1 lm2];
            poi_t{timep}    = ft_redefinetrial(cfg, data);
            
        end
        
        poi = ft_appenddata([],poi_t{:});
        
        % Fourrier transform
        
        for d = 1:2;
            
            lst_frq = [9 13];
            
            f_focus = lst_frq(d);
            
            cfg               = [];
            cfg.method        = 'mtmfft';
            cfg.foi           = f_focus;
            cfg.tapsmofrq     = 3;
            cfg.output        = 'powandcsd';
            freq              = ft_freqanalysis(cfg,poi);
            
            ext_com = 'bsl';
            
            fprintf('\nLoading Leadfield and Common Filters\n');
            load(['../data/' suj  '/headfield/' suj '.VolGrid.5mm.mat']);
            
            formul = 2;
            
            load ../data/yctot/ArsenalIndex.mat ;
            
            cfg                     =   [];
            cfg.headmodel           =   vol;
            cfg.channel             =   poi.label;
            cfg.grid.pos            =   grid.pos(indx_tot(:,1),:);
            cfg.grad                =   poi.grad;
            cfg.channel             =   'MEG';
            nw_leadfield            =   ft_prepare_leadfield(cfg);
            
            cfg                     = [];
            cfg.method              = 'dics';
            cfg.frequency           = freq.freq;
            cfg.grid                = nw_leadfield;
            cfg.headmodel           = vol;
            cfg.dics.projectnoise   = 'yes';
            cfg.dics.lambda         = '5%';
            cfg.dics.keepfilter     = 'yes';
            source                  = ft_sourceanalysis(cfg, freq);
            com_filter              = source.avg.filter;
            
            cnct_f_ext = [num2str(f_focus-formul) 't' num2str(f_focus+formul)];
            
            fname_out = [suj '.pt' num2str(b) '.' lck  '.' cnct_f_ext '.filt&lead.' ext_com];
            
            fprintf('\n\nSaving %50s \n\n',fname_out);
            
            save(['../data/' suj '/filter/' fname_out '.5mm.mat'],'com_filter','nw_leadfield','-v7.3')
            
            clear com_filter nw_leadfield freq cnct_f_ext
            
        end
        
    end
    
    clearvars -except a suj_list
    
end