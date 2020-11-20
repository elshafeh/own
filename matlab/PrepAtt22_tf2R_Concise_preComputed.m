clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

% load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat
% suj_group       = suj_group(1:2);

suj_group{1} = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        cond_main               = 'CnD';
        
        ext_nam1                = 'prep21.maxAVMsepVoxel5per.50t120Hz.m800p2000msCov';
        ext_nam2                = 'waveletPOW.50t120Hz.m2000p2000.MinEvokedAvgTrials';
        
        ext_name                = [ext_nam1 '.' ext_nam2];
        
        list_ix                 = {'R','L','NR','NL'}; % {'R','L','N'}; % 
        
        for ncue = 1:length(list_ix)
            
            fname_in                = ['../data/paper_data/' suj '.' list_ix{ncue} cond_main '.' ext_name '.mat'];
            
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            %             freq                            = h_transform_freq(freq,{1:5,6:10,[11:15 21:25],[16:20 26:30]},{'occ_L','occ_R','aud_L','aud_R'});
            
            %             cfg = []; cfg.channel = 1:4; freq = ft_selectdata(cfg,freq);
            %             for nchan = 1:length(freq.label)
            %                 freq.label{nchan} = [freq.label{nchan}(1:3) '_' freq.label{nchan}(end)];
            %             end
            
            cfg                                     = [];
            % --- %
            cfg.baseline                            = [-0.4 -0.2];
            % --- %
            cfg.baselinetype                        = 'relchange';
            freq                                    = ft_freqbaseline(cfg,freq);
            
            allsuj_data{ngroup}{sb,ncue}            = freq;
            allsuj_data{ngroup}{sb,ncue}.suj        = suj;
            
            
            clear new_freq cfg
            
        end
    end
end

clearvars -except allsuj_data big_freq

fOUT = '../documents/4R/new_post_target_gamma_60t100Hz_tight_wind.txt';

fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE_SIDE','CHAN','FREQ','TIME','POW','CUE_CAT','CUE_CONC','CUE_ORIG','MOD','HEMI','FREQ_CAT','CUE_POSITION','group_use','group_perc');

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        
        fprintf('Handling %s\n',num2str(sb));
        
        for ncue = 1:size(allsuj_data{ngroup},2)
            for nchan = 1:length(allsuj_data{ngroup}{sb,ncue}.label)
                
                frq_win  = 5; % 5;
                frq_list = [65 75 85 95]; % [9 13] ; % you changed how you calculate !!!!!
                
                tim_wind = 0.05;
                tim_list = 1.3:tim_wind:1.4; % 0.6:tim_wind:0.9; %  

                for nfreq = 1:length(frq_list)
                    for ntime = 1:length(tim_list)
                        
                        ls_group            = {'prep21'} ; % {'old','young'}; %
                        
                        if size(allsuj_data{ngroup},2) > 3
                            ls_cue              = {'R','L','R','L'};
                            ls_cue_cat          = {'informative','informative','uninformative','uninformative'};
                            ls_threewise        = {'R_Cue','L_Cue','NR_Cue','NL_Cue'}; 
                            original_cue_list   = {'RCue','LCue','NCue','NCue'};
                        else
                            ls_cue              = {'R','L','RL'}; 
                            ls_cue_cat          = {'informative','informative','uninformative'};
                            ls_threewise        = {'R_Cue','L_Cue','N_Cue'};
                            original_cue_list   = {'RCue','LCue','NCue'}; 
                        end
                        
                        %                         ls_cue              = {'R','L','RL'};
                        %                         ls_cue_cat          = {'informative','informative','uninformative'};
                        %                         ls_threewise        = {'R_Cue','L_Cue','NRL_Cue'};
                        %                         original_cue_list   = {'RCue','LCue','NCue'};
                        
                        ls_chan             = allsuj_data{ngroup}{sb,ncue}.label{nchan};
                        
                        if tim_list(ntime) < 1
                            ls_time  = ['0' num2str(tim_list(ntime)*1000) 'ms'];
                        elseif tim_list(ntime) == 1
                            ls_time  = [num2str(tim_list(ntime)*1000) 'ms'];
                        else
                            ls_time  = [num2str(tim_list(ntime)*1000) 'ms'];
                        end
                        
                        if frq_list(nfreq) < 10
                            ls_freq             = ['0' num2str(frq_list(nfreq)) 'Hz'];
                        else
                            ls_freq             = [num2str(frq_list(nfreq)) 'Hz'];
                        end
                        
                        name_chan               =  ls_chan;
                        name_parts              =  strsplit(name_chan,'_');
                        
                        %--%
                        chan_mod                = name_chan(1:3) ; % name_parts{1};
                        %--% 
                        chan_hemi               = [name_chan(end) '_Hemi'] ; % [name_parts{end} '_Hemi'];
                        %--%
                        
                        suj                     = allsuj_data{ngroup}{sb,ncue}.suj;
                        where_suj               = 'a';%find(strcmp(allsuj_behav(:,2),suj));
                        
                        cue_check               = ls_cue{ncue};
                        
                        if strcmp(chan_hemi,'L_Hemi')
                            
                            if strcmp(cue_check,'L')
                                group_rt                = 'ipsilateral';
                            elseif strcmp(cue_check,'R')
                                group_rt                = 'contralateral';
                            elseif strcmp(cue_check,'RL')
                                group_rt                = 'uninformative';
                            end
                            
                        elseif strcmp(chan_hemi,'R_Hemi')
                            
                            if strcmp(cue_check,'L')
                                group_rt                = 'contralateral';
                            elseif strcmp(cue_check,'R')
                                group_rt                = 'ipsilateral';
                            elseif strcmp(cue_check,'RL')
                                group_rt                = 'uninformative';
                            end
                            
                        end
                        
                        group_use               = 'a';
                        group_perc              = 'a';
                        
                        if frq_list(nfreq) < 11
                            freq_cat = 'low_freq';
                        else
                            freq_cat = 'high_freq';
                        end
                                                
                        x1       = find(round(allsuj_data{ngroup}{sb,ncue}.time,2)== round(tim_list(ntime),2));
                        x2       = find(round(allsuj_data{ngroup}{sb,ncue}.time,2)== round(tim_list(ntime)+tim_wind,2));
                        
                        y1       = find(round(allsuj_data{ngroup}{sb,ncue}.freq)== round(frq_list(nfreq)-frq_win));
                        y2       = find(round(allsuj_data{ngroup}{sb,ncue}.freq)== round(frq_list(nfreq)+frq_win));
                        
                        if isempty(x1) || isempty(x2) || isempty(y1) || isempty(y2)
                            error('ahhhh')
                        else
                            
                            pow      = nanmean(allsuj_data{ngroup}{sb,ncue}.powspctrm(nchan,y1:y2,x1:x2),3);
                            pow      = squeeze(nanmean(pow,2));
                            
                            if size(pow,1) > 1 || size(pow,2) > 1
                                error('oohhhhhhh')
                            else
                                
                                fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%.10f\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',ls_group{ngroup},suj,ls_cue{ncue},...
                                    name_chan,ls_freq,ls_time,pow,ls_cue_cat{ncue},original_cue_list{ncue},...
                                    ls_threewise{ncue},chan_mod,chan_hemi,freq_cat,....
                                    group_rt,group_use,group_perc);
                                
                                
                                clear group_rt name_chan ls_freq ls_time pow chan_mod chan_hemi freq_cat group_rt group_use group_perc;
                                
                            end
                            
                        end
                    end
                end
            end
        end
    end
end

fclose(fid);