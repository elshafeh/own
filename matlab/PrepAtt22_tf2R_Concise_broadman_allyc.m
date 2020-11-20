clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

% [~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_group{1}        = suj_group{1}(2:22);

suj_group{1} = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        cond_main               = 'CnD';
        
        ext_name1               = '1t20Hz';
        ext_name2               = 'MaxAudVizMotor.BigCov.VirtTimeCourse.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvoked';
        
        fname_in                = ['../data/paper_data/' suj '.' cond_main '.' ext_name2 '.mat'];
        
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'check_trialinfo')
            freq = rmfield(freq,'check_trialinfo');
        end
        
        if isfield(freq,'hidden_trialinfo')
            freq = rmfield(freq,'hidden_trialinfo');
        end
        
        %         load(['../data/' suj '/field/' suj '.CnD.100Slct.RLNRNL.mat']);
        %         cfg                = [];
        %         cfg.trials         = [trial_array{:}];
        %         freq               = ft_selectdata(cfg,freq);
        %         freq               = h_transform_freq(freq,{[1 2],[3 5],[4 6]},{'occ','audL','audR'});
        
        list_ix_cue        = {2,1,0};
        list_ix_tar        = {1:4,1:4,1:4};
        list_ix_dis        = {0,0,0};
        list_ix            = {'R','L','N'};
              
        %         cfg                = [];
        %         cfg.channel        = [1:8 16:22];
        %         freq               = ft_selectdata(cfg,freq);
        
        for cnd = 1:length(list_ix_cue)
            
            cfg                         = [];
            cfg.trials                  = h_chooseTrial(freq,list_ix_cue{cnd},list_ix_dis{cnd},list_ix_tar{cnd}) ; %trial_array{cnd};% 
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
            end
            
            clear new_freq cfg
            
        end
    end
end

clearvars -except allsuj_data big_freq

fOUT = '../documents/4R/paper_min_evoked_two_freq_sep_time.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','CHAN','FREQ','TIME','POW','CUE_CAT','CUE_CONC','CUE_ORIG','MOD','HEMI','FREQ_CAT');

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        for ncue = 1:size(allsuj_data{ngroup},2)
            for nchan = 1:size(allsuj_data{ngroup},3)
                
                frq_win  = 4;
                frq_list = [7 11];
                
                tim_wind = 0.1;
                tim_list = 0.6:tim_wind:1;
                
                for nfreq = 1:length(frq_list)
                    for ntime = 1:length(tim_list)
                        
                        ls_group            = {'paper_young'};
                        
                        ls_cue              = {'R','L','RL'};
                        ls_cue_cat          = {'informative','informative','uninformative'};
                        
                        ls_threewise        = {'RCue','LCue','NCue'};
                        original_cue_list   = {'R','L','RL'};
                        
                        ls_chan  = allsuj_data{ngroup}{sb,ncue,nchan}.label;
                        
                        if frq_list(nfreq) > 10
                            ls_freq  = [num2str(frq_list(nfreq)) 'Hz'];
                        else
                            ls_freq  = ['0' num2str(frq_list(nfreq)) 'Hz'];
                        end
                        
                        if tim_list(ntime) < 1
                            ls_time  = ['0' num2str(tim_list(ntime)*1000) 'ms'];
                        else
                            ls_time  = [num2str(tim_list(ntime)*1000) 'ms'];
                        end

                        name_chan =  ls_chan{:};
                        
                        chan_mod     = 'TD';
                        
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
                                
                                fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%.5f\t%s\t%s\t%s\t%s\t%s\t%s\n',ls_group{ngroup},[ls_group{ngroup} num2str(sb)],ls_cue{ncue},ls_chan{:},ls_freq,ls_time,pow,ls_cue_cat{ncue},original_cue_list{ncue},ls_threewise{ncue},chan_mod,[name_chan(end) 'Hemi'],freq_cat);
                                
                            end
                            
                        end
                    end
                end
            end
        end
    end
end

fclose(fid);