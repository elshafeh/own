clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list                    = [1:4 8:17];
    suj                         = ['yc' num2str(suj_list(sb))];
    ext_essai                   = 'CnD.Rama3Cov';
    
    %     fname_in                    = [suj '.' ext_essai];
    %
    %     fprintf('\nLoading %50s \n',fname_in);
    %     load(['../data/pe/' fname_in '.mat'])
    %
    %     cfg                         = [];
    %     cfg.method                  = 'wavelet';
    %     cfg.output                  = 'fourier';
    %     cfg.toi                     = -3:0.05:3;
    %     cfg.foi                     = 5:15;
    %     cfg.keeptrials              = 'yes';
    %     freq                        = ft_freqanalysis(cfg, virtsens);
    %
    %     ext_time                    = ['m' num2str(abs(cfg.toi(1))*1000) 'p' num2str(abs(cfg.toi(end))*1000)];
    %     ext_freq                    = [num2str(cfg.foi(1)) 't' num2str(cfg.foi(end)) 'Hz'];
    %
    %     fname_out                   = ['../data/tfr/' suj '.' ext_essai '.' cfg.method upper(cfg.output) '.' ext_freq '.' ext_time '.mat'];
    %     fprintf('\nSaving %50s \n\n',fname_out);
    %     save(fname_out,'freq','-v7.3');
    
    fname_in                    = ['../data/all_data/' suj '.' ext_essai '.waveletFOURIER.1t19Hz.m3000p3000.KeepTrials.mat'];
    fprintf('\nLoading %50s \n\n',fname_in);
    load(fname_in)
    
    %     load ../data/yctot/index/RamaAlphaFusion.mat
    %     group={find(cell2mat(final_rama_list(:,3))==1)};
        
    group={[1 2 6 7 8 9 10 11 12 13 14 15 16 17 20 23 24 26 ...
        44 45 52 53 54 55 56 74 75 76 77 82 83 92 93 97]};
    
    grp_lst = {'AllPlusAll'};
    
    lst_cue                 = {'N','L','R',''};
    
    load ../data/yctot/RamaTriaList.mat;
    
    for cnd = 1:length(lst_cue)
        for j = 1:length(grp_lst)
            
            cfg                     = [];
            %             cfg.channel             = group{j};
            cfg.frequency           = [5 15];
            cfg.latency             = [-0.8 2];
            
            if isempty(lst_cue{cnd})
                cfg.trials          = 'all';
            else
                cfg.trials          = find(round((freq.trialinfo-1000)/100)==cnd-1);
            end
            
            new_freq                = ft_selectdata(cfg,freq);
            
            %             cfg                     = [];
            %             cfg.method              = 'coh';
            %             freq_coh                = ft_connectivityanalysis(cfg, new_freq);
            %             cfg                     = [];
            %             cfg.method              = 'coh';
            %             cfg.complex             = 'imag';
            %             freq_coh_imag           = ft_connectivityanalysis(cfg, new_freq);
            %             freq_coh_imag.cohspctrm = abs(freq_coh_imag.cohspctrm);
            
            cfg                         = [];
            cfg.method                  = 'plv';
            freq_plv                    = ft_connectivityanalysis(cfg, new_freq);
            
            freq_plv .powspctrm         = freq_plv.plvspctrm;
            freq_plv                    = rmfield(freq_plv ,'plvspctrm');
            freq_plv                    = rmfield(freq_plv ,'dof');
            
            %             freq_coh.powspctrm      = freq_coh.cohspctrm;
            %             freq_coh                = rmfield(freq_coh,'cohspctrm');
            %             freq_coh_imag.powspctrm = freq_coh_imag.cohspctrm;
            %             freq_coh_imag           = rmfield(freq_coh_imag,'cohspctrm');
            %             suj_coh{1}              = freq_coh;
            %             suj_coh{2}              = freq_coh_imag;
            
            suj_coh{3}              = freq_plv;
            
            clear new_freq
            
            fname_out               = ['../data/all_data/' suj '.' lst_cue{cnd} ext_essai '.' grp_lst{j} '.OnlyPLV.mat'];
            
            fprintf('\nSaving %50s \n\n',fname_out);
            
            save(fname_out,'suj_coh','-v7.3');
            
            clear freq_*
            
        end
        
    end
    
    clear freq virtsens
    
end