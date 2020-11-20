clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);
suj_list     = suj_group{1};

clearvars -except *suj_list ;

for sb = 1:length(suj_list)
    
    suj                 = suj_list{sb};
    cond_main           = 'CnD';
    fname_in            = ['../data/' suj '/field/' suj '.' cond_main '.3Cov.waveletFOURIER.7t15Hz.m1500p1500.KeepTrials.mat'];
    
    fprintf('\nLoading %50s \n\n',fname_in);
    
    load(fname_in)
   
    if isfield(freq,'check_trialinfo');
        freq = rmfield(freq,'check_trialinfo');
    end
    
    list_ix_cond       = {'','R','L','NL','NR'};
    list_ix_cue        = {0:2,2,1,0,0};
    list_ix_tar        = {1:4,[2 4],[1 3],[1 3],[2 4]};
    list_ix_dis        = {0,0,0,0,0};
    
    for cnd = 1:length(list_ix_cond)
        
        lst_done           = {};
        lst_plv            = {};
        i                  = 0;
        
        for chan = 3:length(freq.label)
            
            fprintf('\nHandling Channel %d\n',chan);
            
            cfg                     = [];
            cfg.latency             = [-0.8 1.2];
            cfg.frequency           = [7 15];
            cfg.channel             = [1 2 chan];
            cfg.trials              = h_chooseTrial(freq,list_ix_cue{cnd},list_ix_dis{cnd},list_ix_tar{cnd});
            new_freq                = ft_selectdata(cfg,freq);
            
            name_ext_freq           = [num2str(cfg.frequency(1)) 't' num2str(cfg.frequency(2)) 'Hz'];
            name_ext_time           = ['m' num2str(abs(cfg.latency(1))*1000) 'p' num2str(abs(cfg.latency(end))*1000) 'ms'];
            
            cfg                     = [];
            cfg.method              = 'plv';
            freq_plv                = ft_connectivityanalysis(cfg, new_freq);
            
            freq_plv.powspctrm      = freq_plv.plvspctrm;
            freq_plv                = rmfield(freq_plv,'plvspctrm');
            
            aud_list                = 1:2;
            
            if chan == 3
                chan_list               = 1:3;
            else
                chan_list               = 3;
            end
            
            for x = 1:length(aud_list)
                for y = 1:length(chan_list)
                    if aud_list(x) ~= chan_list(y)
                        
                        %                         flg = [num2str(aud_list(x)) '.' num2str(chan_list(y))];
                        %                         if isempty(find(strcmp(lst_done,flg)))
                        
                        i                                = i + 1;
                        
                        lst_plv{i}.time                  = freq_plv.time;
                        lst_plv{i}.freq                  = freq_plv.freq;
                        lst_plv{i}.dimord                = 'chan_freq_time';
                        lst_plv{i}.label                 = {[freq_plv.label{aud_list(x)} ' ' freq_plv.label{chan_list(y)}]};
                        
                        
                        lst_done{end+1}                  = [num2str(aud_list(x)) '.' num2str(chan_list(y))];
                        %                         lst_done{end+1}                  = [num2str(chan_list(y)) '.' num2str(aud_list(x))];
                        lst_plv{i}.powspctrm             = zeros(1,length(freq_plv.freq),length(freq_plv.time));
                        lst_plv{i}.powspctrm(1,:,:)      = squeeze(freq_plv.powspctrm(aud_list(x),chan_list(y),:,:));
                        
                        %                         end
                        
                    end
                end
            end
        end
        
        lst_plv                 = lst_plv([1:2 4:162]);
        
        cfg=[];cfg.parameter='powspctrm';cfg.appendim ='chan';freq_plv=ft_appendfreq(cfg,lst_plv{:});clear lst_plv;
        
        fname_out               = ['../data/' suj '/field/' suj '.' list_ix_cond{cnd} cond_main '.' name_ext_freq '.' name_ext_time '.Aud2All.plv.mat'];
        
        fprintf('\nSaving %50s \n\n',fname_out);
        
        save(fname_out,'freq_plv','-v7.3');
        
        clear freq_*
        
    end 
end