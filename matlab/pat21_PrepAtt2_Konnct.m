clear ; clc ; dleiftrip_addpath;

for sb = 1:14
    
    cnd_list = {'CnD'};
    
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
    end
    
    virtsens = ft_appenddata([],data{:}) ; clear data ;
    
    ix_t = 0 ;
    
    cfg=[];
    cfg.channel = [6 11 12 13];
    virtsens = ft_selectdata(cfg,virtsens);
    
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
        coh_measures{sb,ix_t}           = ft_connectivityanalysis(cfg, freq_fft);
        coh_measures{sb,ix_t}           = rmfield(coh_measures{sb,ix_t,1},'cfg');
        
        clear poi freq freq_fft
        
    end
    
    for ix_t = 2
        
        x = coh_measures{sb,ix_t}.plvspctrm;
        y = coh_measures{sb,1}.plvspctrm;
        coh_measures{sb,ix_t}.plvspctrm = (x-y) ./ y ;
        
    end
    
    coh_measures{sb,1}.plvspctrm(:,:,:) = 0 ;
    
    clear virtsens
    
end

clearvars -except coh_measures

% ttest

ii = 0 ;

for chan1 = 1:length(coh_measures{1,1,1}.label)
    for chan2 = 1:length(coh_measures{1,1}.label)
        if chan1 ~= chan2
            
            ha = 0 ; %strcmp(coh_measures{1,1,1}.label{chan1}(1),'r');
            ho = 1 ; %strcmp(coh_measures{1,1,1}.label{chan2}(1),'r');
            
            if ha + ho == 1
                
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

for ix_t   = 2:4
    
    tmp = coh_measures{1,1};
    
    tres{ix_t-1} =  tmp;
    
    tres{ix_t-1}.plvspctrm = repmat(100,size(tmp.plvspctrm,1),size(tmp.plvspctrm,2),size(tmp.plvspctrm,3));
    
    for frq = 1:length(coh_measures{1,1}.freq)
        
        for c_c = 1:length(chan1_list)
            
            for sb = 1:size(coh_measures,1)
                x(sb) = coh_measures{sb,ix_t}.plvspctrm(chan1_list(c_c),chan2_list(c_c),frq) ;
                y(sb) = coh_measures{sb,1}.plvspctrm(chan1_list(c_c),chan2_list(c_c),frq) ;
            end
            
            p           = permutation_test([x' y'],1000);
            
            tres{ix_t-1}.plvspctrm(chan1_list(c_c),chan2_list(c_c),frq) = p ;
            
        end
        
    end
    
end

meas_list = {'plv'};
time_list = {'early','middle','late'};
chan_list = tres{1,1}.label ;
freq_list = round(tres{1,1}.freq);

ix_s = 0 ; Summary = [] ;

for ix_t = 1:2
    for frq = 1:4
        for chan1 = 1:length(tres{1,1,1}.label)
            for chan2 = 1:length(tres{1,1}.label)
                
                p         = tres{ix_t}.plvspctrm(chan1,chan2,frq);
                
                if p < 0.1 && p > 0
                    
                    ix_s = ix_s + 1;
                    
                    Summary(ix_s).measure   = meas_list{1};
                    Summary(ix_s).freq      = freq_list(frq);
                    Summary(ix_s).time      = time_list(ix_t);
                    Summary(ix_s).chan1     = chan_list{chan1};
                    Summary(ix_s).chan2     = chan_list{chan2};
                    Summary(ix_s).p         = p ;
                    
                end
                
            end
        end
    end
end

clearvars -except coh_measures chn_list chan1_list chan2_list chn_list tres Summary