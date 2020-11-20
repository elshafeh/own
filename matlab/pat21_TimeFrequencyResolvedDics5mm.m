clear;clc;

for sb = 5:14;
    
    for cond = {'RCnD','LCnD','NCnD'}
        
        for pt = 1:3
            
            suj_list = [1:4 8:17];
            
            st_point = -3;
            
            suj = ['yc' num2str(suj_list(sb))] ;
            
            fname_in = [suj '.pt' num2str(pt) '.' cond{:}];
            fprintf('Loading %50s \n\n',fname_in);
            load(['../data/' suj '/elan/' fname_in '.mat'])
            
            data = data_elan ;
            
            clear data_elan
            
            tim_win  = 6;
            
            lm1 = st_point;
            lm2 = st_point+tim_win;
            
            cfg             = [];
            cfg.toilim      = [lm1 lm2];
            poi             = ft_redefinetrial(cfg, data);
            
            % Fourrier transform
            
            fq_list = 5:1:15;
            
            cfg                 = [];
            cfg.method          = 'mtmconvol';
            cfg.taper           = 'dpss';
            cfg.output          = 'powandcsd';
            cfg.foi             = fq_list;
            cfg.toi             = -4:0.05:4;
            cfg.t_ftimwin       = 4./cfg.foi;
            cfg.tapsmofrq       = 0.3.*cfg.foi;
            
            freq                = ft_freqanalysis(cfg,poi);
            
            tResolvedAvg.pow = [];
            
            load(['../data/' suj '/headfield/' suj '.pt' num2str(pt) '.adjusted.leadfield.5mm.mat']);
            load(['../data/' suj  '/headfield/' suj '.VolGrid.5mm.mat']);
            
            fname_filt = [suj '.pt' num2str(pt) '.TResolved.commonFilter' ];
            fprintf('\n\nLoading %50s \n\n',fname_filt);
            load(['../data/' suj '/filter/' fname_filt '.mat'])
            
            for f = 1:length(fq_list);
                
                mini_win    = 0.1 ;
                tm_list     = -0.6:mini_win:2;
                
                tResolvedAvg.time   = tm_list;
                tResolvedAvg.freq   = fq_list;
                
                for t = 1:length(tm_list)
                    
                    cfg                     = [];
                    cfg.latency             = [tm_list(t) tm_list(t)+mini_win];
                    cfg.frequency           = fq_list(f);
                    cfg.avgovertime         = 'yes';
                    freq_slct               = ft_selectdata(cfg,freq);
                    freq_slct.dimord        = 'chan_freq';
                    freq_slct               = rmfield(freq_slct,'time');
                    
                    cfg                     = [];
                    cfg.method              = 'dics';
                    cfg.frequency           = freq_slct.freq;
                    cfg.grid                = leadfield;
                    cfg.grid.filter         = com_filter;
                    cfg.headmodel           = vol;
                    cfg.dics.projectnoise   = 'yes';
                    cfg.dics.fixedori        = 'yes';
                    cfg.dics.lambda         = '5%';
                    source                  = ft_sourceanalysis(cfg,freq_slct);
                    
                    tResolvedAvg.pow(:,f,t) = source.avg.pow;
                    
                    clear source freq_slct
                    
                end
                
            end
            
            save(['../data/' suj '/source/' suj '.pt' num2str(pt) '.' cond{:} '.tfResolved.5t15Hz.m700p2000ms1Hz100msRes.mat'],'tResolvedAvg','-v7.3');
            
            clearvars -except sb cond pt
            
        end

    end
    
end

%         for f = 1:size(tResolvedSource,2)
%             for n = 1:size(tResolvedSource{1,1},1)
%                 for t =1:size(tResolvedSource{1,1},2)
%                     tResolvedAvg.pow(n,f,t) = mean([tResolvedSource{1,f}(n,t) tResolvedSource{2,f}(n,t) tResolvedSource{3,f}(n,t)]);
%                 end
%             end
%         end
%         clear tResolvedSource n
%         suj_list = [1:4 8:17];
%         suj = ['yc' num2str(suj_list(sb))] ;