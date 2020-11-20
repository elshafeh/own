clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        
        cond_main               = 'CnD';
        
        ext_name2               = 'NewAVBroad.50t120Hz.m800p2000msCov.waveletPOW.50t120Hz.m2500p2500.AvgTrialsMinEvoked10MStep100Slct';
        
        list_ix                 = {'R','L','NR','NL'};
        
        for ncue = 1:length(list_ix)
            
            fname_in                = ['../data/' suj '/field/' suj '.' list_ix{ncue} cond_main '.' ext_name2 '.mat'];
            
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            new_freq                    = freq;
            
            %             new_freq                    = ft_freqdescriptives([],freq); clear freq ;
            %             audL                        = mean(new_freq.powspctrm([7 9 11],:,:),1);
            %             audR                        = mean(new_freq.powspctrm([8 10 12],:,:),1);
            %             visL                        = mean(new_freq.powspctrm([1 3 5],:,:),1);
            %             visR                        = mean(new_freq.powspctrm([2 4 6],:,:),1);
            
            audL                        = new_freq.powspctrm(3,:,:);
            audR                        = new_freq.powspctrm(4,:,:);
            lIdx                        = (audR-audL) ./ ((audR+audL)/2);
            
            allsuj_data{ngroup}{sb,ncue,1}             = new_freq;
            allsuj_data{ngroup}{sb,ncue,1}.label       = {'LatIndex_aud'};
            allsuj_data{ngroup}{sb,ncue,1}.powspctrm   = lIdx;
            
            visL                        = new_freq.powspctrm(1,:,:);
            visR                        = new_freq.powspctrm(2,:,:);
            lIdx                        = (visR-visL) ./ ((visR+visL)/2);
            
            %             allsuj_data{ngroup}{sb,ncue,2}             = new_freq;
            %             allsuj_data{ngroup}{sb,ncue,2}.label       = {'LatIndex_vis'};
            %             allsuj_data{ngroup}{sb,ncue,2}.powspctrm   = lIdx;
            
            clear lIdx audR audL
            
        end
        
        clc;
    end
end

clearvars -except allsuj_data list_ix

fOUT = '../documents/4R/NewAV_allyoung_Gamma_LatIndex_p600p1100_7t15Hz_addFreqTime_MinEvoked_Slct_alltime.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','CHAN','FREQ','TIME','POW','CUE_CAT','CUE_CONC','CUE_ORIG','MOD','HEMI','FREQ_CAT');

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        for ncue = 1:size(allsuj_data{ngroup},2)
            for nchan = 1:size(allsuj_data{ngroup},3)
                
                frq_win  = 10;
                frq_list = 50:frq_win:110;
                
                tim_wind = 0.1;
                tim_list = 0:tim_wind:1.9;
                
                for nfreq = 1:length(frq_list)
                    for ntime = 1:length(tim_list)
                        
                        ls_group            = {'allyoung'};
                        
                        ls_cue              = {'R','L','R','L'};
                        %                         ls_cue              = {'R','L','RL'};

                        ls_cue_cat          = {'informative','informative','uninformative','uninformative'};
                        %                         ls_cue_cat          = {'informative','informative','uninformative'};
                        
                        ls_threewise        = {'RCue','LCue','NCue','NCue'};
                        %                         ls_threewise        = {'RCue','LCue','NCue'};
                        
                        original_cue_list   = {'R','L','NR','NL'};
                        %                         original_cue_list   = {'R','L','NL'};

                        if tim_list(ntime) < 1
                            ls_time  = ['0' num2str(tim_list(ntime)*1000) 'ms'];
                        else
                            ls_time  = [num2str(tim_list(ntime)*1000) 'ms'];
                        end
                        
                        if frq_list(nfreq) < 100
                            ls_freq             = ['0' num2str(frq_list(nfreq)) 'Hz'];
                        else
                            ls_freq             = [num2str(frq_list(nfreq)) 'Hz'];
                        end
                        
                        name_chan   =  allsuj_data{ngroup}{sb,ncue,nchan}.label{:};
                        chan_mod    = name_chan(end-2:end);
                        
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
                                
                                fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%.2f\t%s\t%s\t%s\t%s\t%s\t%s\n',ls_group{ngroup},[ls_group{ngroup} num2str(sb)],ls_cue{ncue},name_chan,ls_freq,ls_time,pow,ls_cue_cat{ncue},original_cue_list{ncue},ls_threewise{ncue},chan_mod,[name_chan(end) 'Hemi'],freq_cat);
                                
                            end
                            
                        end
                    end
                end
            end
        end
    end
end

fclose(fid);