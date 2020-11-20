clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

lst_group       = {'old','young'};

for ngroup = 1:length(lst_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        
        cond_main               = 'CnD';
        
        ext_name1               = 'NewAVBroad.1t20Hz.m800p2000msCov.waveletPOW.1t19Hz.m3000p3000.KeepTrialsMinEvoked10MStep80Slct';
        
        fname_in                = ['../data/' suj '/field/' suj '.' cond_main '.' ext_name1 '.mat'];
        
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'check_trialinfo')
            freq = rmfield(freq,'check_trialinfo');
        end
        
        freq               = h_transform_freq(freq,{[1 3 5],[2 4 6],[7 9 11],[8 10 12]},{'occ_L','occ_R','aud_L','aud_R'});
        
        list_ix_cue        = {2,1,0};
        list_ix_tar        = {1:4,1:4,1:4};
        list_ix_dis        = {0,0,0};
        list_ix            = {'R','L','N'};
                
        for cnd = 1:length(list_ix_cue)
            
            cfg                         = [];
            cfg.trials                  = h_chooseTrial(freq,list_ix_cue{cnd},list_ix_dis{cnd},list_ix_tar{cnd}) ; 
            new_freq                    = ft_selectdata(cfg,freq);
            new_freq                    = ft_freqdescriptives([],new_freq);
            
            cfg                         = [];
            cfg.baseline                = [-0.6 -0.2];
            cfg.baselinetype            = 'relchange';
            new_freq                    = ft_freqbaseline(cfg, new_freq);
            
            for nchan = 1:length(new_freq.label)
                allsuj_data{ngroup}{sb,cnd,nchan}            = new_freq;
                allsuj_data{ngroup}{sb,cnd,nchan}.powspctrm  = new_freq.powspctrm(nchan,:,:);
                allsuj_data{ngroup}{sb,cnd,nchan}.label      = new_freq.label(nchan);
                allsuj_data{ngroup}{sb,cnd,nchan}.suj        = suj;
            end
            
            clear new_freq cfg
            
        end
    end
end

clearvars -except allsuj_data big_freq

fOUT = '../documents/4R/NewBroadMan_age_contrast_same_evoked_separate_time_separate_freq.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','CHAN','FREQ','TIME','POW','CUE_CAT','CUE_CONC','CUE_ORIG','MOD','HEMI','FREQ_CAT');

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        
        fprintf('Handling %s\n',num2str(sb));
        
        for ncue = 1:size(allsuj_data{ngroup},2)
            for nchan = 1:size(allsuj_data{ngroup},3)
                
                frq_win  = 0;
                frq_list = 7:15;
                
                tim_wind =  0.1;
                tim_list =  0.6:tim_wind:1;
                
                for nfreq = 1:length(frq_list)
                    for ntime = 1:length(tim_list)
                        
                        ls_group            = {'old','young','allyoung'};
                        
                        ls_cue              = {'R','L','RL'};
                        
                        ls_cue_cat          = {'informative','informative','uninformative'};
                        
                        ls_threewise        = {'R_Cue','L_Cue','N_Cue'};
                        
                        original_cue_list   = {'R','L','N'};
                        
                        ls_chan             = allsuj_data{ngroup}{sb,ncue,nchan}.label;
                        
                        if tim_list(ntime) < 1
                            ls_time  = ['0' num2str(tim_list(ntime)*1000) 'ms'];
                        else
                            ls_time  = [num2str(tim_list(ntime)*1000) 'ms'];
                        end
                        
                        if frq_list(nfreq) < 10
                            ls_freq             = ['0' num2str(frq_list(nfreq)) 'Hz'];
                        else
                            ls_freq             = [num2str(frq_list(nfreq)) 'Hz'];
                        end
                        
                        name_chan           =  ls_chan{:};
                        name_parts          =  strsplit(name_chan,'_');
                        
                        chan_mod            = name_parts{1};
                        chan_hemi           = [name_parts{end} '_Hemi'];
                        
                        suj = allsuj_data{ngroup}{sb,ncue,nchan}.suj;
                        
                        if frq_list(nfreq) < 11
                            freq_cat = 'low_freq';
                        else
                            freq_cat = 'high_freq';
                        end
                        
                        chn_prts = strsplit(name_chan,'_');
                        
                        x1       = find(round(allsuj_data{ngroup}{sb,ncue,nchan}.time,2)== round(tim_list(ntime),2));
                        x2       = find(round(allsuj_data{ngroup}{sb,ncue,nchan}.time,2)== round(tim_list(ntime)+tim_wind,2));
                        
                        y1       = find(round(allsuj_data{ngroup}{sb,ncue,nchan}.freq)== round(frq_list(nfreq)));
                        y2       = find(round(allsuj_data{ngroup}{sb,ncue,nchan}.freq)== round(frq_list(nfreq)+frq_win));
                        
                        if isempty(x1) || isempty(x2) || isempty(y1) || isempty(y2)
                            error('ahhhh')
                        else
                            pow      = mean(allsuj_data{ngroup}{sb,ncue,nchan}.powspctrm(1,y1:y2,x1:x2),3);
                            pow      = squeeze(mean(pow,2));
                            
                            if size(pow,1) > 1 || size(pow,2) > 1
                                error('oohhhhhhh')
                            else
                                
                                fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%.6f\t%s\t%s\t%s\t%s\t%s\t%s\n',ls_group{ngroup},suj,ls_cue{ncue},name_chan,ls_freq,ls_time,pow,ls_cue_cat{ncue},original_cue_list{ncue},ls_threewise{ncue},chan_mod,chan_hemi,freq_cat);
                                
                            end
                            
                        end
                    end
                end
            end
        end
    end
end

fclose(fid);