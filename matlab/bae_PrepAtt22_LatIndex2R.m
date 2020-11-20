clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

% [~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        cond_main               = 'CnD';
        
        ext_name1               = '1t20Hz';
        ext_name2               = 'broadAreas.1t20Hz.m800p2000msCov.waveletPOW.1t20Hz.m3000p3000.KeepTrialsMinEvoked10MStep';
        
        fname_in                = ['../data/' suj '/field/' suj '.' cond_main '.' ext_name2 '.mat'];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'check_trialinfo')
            freq = rmfield(freq,'check_trialinfo');
        end
                
        list_ix_cue        = {2,1,0};
        list_ix_tar        = {1:4,1:4,1:4};
        list_ix_dis        = {0,0,0};
        list_ix            = {'R','L','N'};
                
        for cnd = 1:length(list_ix_cue)
            
            cfg                         = [];
            cfg.trials                  = h_chooseTrial(freq,list_ix_cue{cnd},list_ix_dis{cnd},list_ix_tar{cnd});
            cfg.channel                 = [7 8];
            new_freq                    = ft_selectdata(cfg,freq);
            new_freq                    = ft_freqdescriptives([],new_freq);
            
            audL                        = new_freq.powspctrm(1,:,:);
            audR                        = new_freq.powspctrm(2,:,:);
            lIdx                        = (audR-audL) ./ ((audR+audL)/2); %% !! 
            
            allsuj_data{ngroup}{sb,cnd}             = new_freq;
            allsuj_data{ngroup}{sb,cnd}.label       = {'LatIndex'};
            allsuj_data{ngroup}{sb,cnd}.powspctrm   = lIdx;
            
            clear lIdx audR audL
            
        end
        
        clc;
    end
end

clearvars -except allsuj_data list_ix

fOUT = '../documents/4R/BroadMan_AgeContrast_Alpha_LatIndex_AllTrials_p600p1100_7t15Hz_addFreqTime_MinEvoked.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','CHAN','FREQ','TIME','POW','CUE_CAT','CUE_CONC','CUE_ORIG','MOD','HEMI','FREQ_CAT');

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        for ncue = 1:size(allsuj_data{ngroup},2)
            
            frq_win  = 0;
            frq_list = 7:15;
            
            tim_wind = 0.1;
            tim_list = 0.6:tim_wind:1;
            
            for nfreq = 1:length(frq_list)
                for ntime = 1:length(tim_list)
                    
                    ls_group            = {'old','young'};
                    
                    ls_cue              = {'R','L','RL'};
                    ls_cue_cat          = {'informative','informative','uninformative'};
                    
                    ls_threewise        = {'RCue','LCue','NCue'};
                    original_cue_list   = {'R','L','N'};
                    
                    ls_chan  = allsuj_data{ngroup}{sb,ncue}.label;
                    ls_time  = [num2str(tim_list(ntime)*1000) 'ms'];
                    ls_freq  = [num2str(frq_list(nfreq)) 'Hz'];
                    
                    name_chan =  allsuj_data{ngroup}{sb,ncue}.label{:};
                    
                    chan_mod = 'Auditory';
                    
                    if frq_list(nfreq) < 11
                        freq_cat = 'low_freq';
                    else
                        freq_cat = 'high_freq';
                    end
                    
                    chn_prts = strsplit(name_chan,'_');
                    
                    x1       = find(round(allsuj_data{ngroup}{sb,ncue}.time,2)== round(tim_list(ntime),2));
                    x2       = find(round(allsuj_data{ngroup}{sb,ncue}.time,2)== round(tim_list(ntime)+tim_wind,2));
                    
                    y1       = find(round(allsuj_data{ngroup}{sb,ncue}.freq)== round(frq_list(nfreq)));
                    y2       = find(round(allsuj_data{ngroup}{sb,ncue}.freq)== round(frq_list(nfreq)+frq_win));
                  
                    if isempty(x1) || isempty(x2) || isempty(y1) || isempty(y2)
                        error('ahhhh')
                    else
                        pow      = mean(allsuj_data{ngroup}{sb,ncue}.powspctrm(1,y1:y2,x1:x2),3);
                        pow      = squeeze(mean(pow,2));
                        
                        if size(pow,1) > 1 || size(pow,2) > 1
                            error('oohhhhhhh')
                        else
                            
                            fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%.2f\t%s\t%s\t%s\t%s\t%s\t%s\n',ls_group{ngroup},[ls_group{ngroup} num2str(sb)],ls_cue{ncue},name_chan,ls_freq,ls_time,pow,ls_cue_cat{ncue},original_cue_list{ncue},ls_threewise{ncue},chan_mod,[name_chan(end) 'Hemi'],freq_cat);
                            
                        end
                        
                    end
                end
            end
        end
    end
end

fclose(fid);