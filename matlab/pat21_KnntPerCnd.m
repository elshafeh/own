clear ; clc ; dleiftrip_addpath;

for sb = 1:14
    
    cnd_list = {'RCnD','LCnD','NCnD'};
    
    for cnd = 1:length(cnd_list)
        
        for prt = 1:3
            
            suj_list = [1:4 8:17];
            
            suj = ['yc' num2str(suj_list(sb))];
            
            ext_essai   = 'Paper';
            fname_in    = ['../data/' suj '/pe/' suj '.pt' num2str(prt) '.' cnd_list{cnd} '.' ext_essai '.TimeCourse.mat'];
            fprintf('Loading %50s\n',fname_in);
            load(fname_in);
            
            data{prt} = virtsens ;
            
            clear virtsens
            
        end
        
        
        virtsens = ft_appenddata([],data{:}) ; clear data ;
        
        ix_t = 0 ;
        
        for t_point = [-0.6 0.6]
            
            ix_t = ix_t + 1;
            
            cfg                 = [];
            cfg.toilim          = [t_point t_point+0.4];
            poi                 = ft_redefinetrial(cfg, virtsens);
            
            cfg                 = [];
            cfg.output          = 'fourier';
            cfg.method          = 'mtmfft';
            cfg.foilim          = [6 14];
            cfg.tapsmofrq       = 2;
            cfg.keeptrials      = 'yes';
            freq_fft            = ft_freqanalysis(cfg, poi);
            
            cfg                             = [];
            cfg.method                      = 'plv';
            tmp{ix_t}       = ft_connectivityanalysis(cfg, freq_fft);
            tmp{ix_t}       = rmfield(tmp{ix_t},'cfg');
            
            clear poi freq freq_fft
            
        end
            
            x    = tmp{2}.plvspctrm;
            y    = tmp{1}.plvspctrm;
            z    = (x-y) ./ y;
            zF   = .5.*log((1+z)./(1-z));
            
            coh_measures{sb,cnd}                = tmp{1};
            coh_measures{sb,cnd}.plvspctrm      = zF;
        
        clear virtsens tmp z zF
        
    end
    
end

clearvars -except coh_measures

ii = 0 ;

for chan1 = 1:length(coh_measures{1,1,1}.label)
    for chan2 = 1:length(coh_measures{1,1}.label)
        if chan1 ~= chan2
            
            ha = strcmp(coh_measures{1,1}.label{chan1}(1),'r');
            ho = strcmp(coh_measures{1,1}.label{chan2}(1),'r');
            
            if ha + ho < 2
                
                ii = ii + 1;
                tmp = [chan1 chan2];
                tmp = sort(tmp);
                chn_list{ii} =[num2str(tmp(1)) '.' num2str(tmp(2))];
                
                clear tmp
                
            end
        end
    end
end

chn_list = unique(chn_list);

chan1_list = [];
chan2_list = [];

for ii = 1:length(chn_list)
    
    dotdot = strfind(chn_list{ii},'.');
    
    chan1_list(end+1) = str2num(chn_list{ii}(1:dotdot-1));
    chan2_list(end+1) = str2num(chn_list{ii}(dotdot+1:end));
    
end

clearvars -except coh_measures chn_list chan1_list chan2_list chn_list