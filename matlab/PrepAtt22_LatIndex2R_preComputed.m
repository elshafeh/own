clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat

suj_group       = suj_group(1:2);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        
        cond_main               = 'CnD';
        
        ext_name2               ='AV.1t20Hz.M.1t40Hz.m800p2000msCov.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvoked';
        
        list_ix                 = {'R','L','N'};
        
        for ncue = 1:length(list_ix)
            
            fname_in            = ['../data/ageing_data/' suj '.' list_ix{ncue} cond_main '.' ext_name2 '.mat'];
            
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
            
            whereL                                      = find(strcmp(freq.label,'audL'));
            whereR                                      = find(strcmp(freq.label,'audR'));
            
            audL                                        = new_freq.powspctrm(whereL,:,:);
            audR                                        = new_freq.powspctrm(whereR,:,:);
            lIdx                                        = (audR-audL) ./ (audR+audL); % ((audR+audL)/2); % 

            allsuj_data{ngroup}{sb,ncue,1}              = new_freq;
            allsuj_data{ngroup}{sb,ncue,1}.label        = {'LatIndex_aud'};
            allsuj_data{ngroup}{sb,ncue,1}.powspctrm    = lIdx;
            allsuj_data{ngroup}{sb,ncue,1}.suj          = suj;
            
            %             visL                                        = new_freq.powspctrm(3,:,:);
            %             visR                                        = new_freq.powspctrm(4,:,:);
            %             lIdx                                        = (visR-visL) ./ ((visR+visL)/2);
            %             lIdx                                        = (visR-visL) ./ (visR+visL);
            %             allsuj_data{ngroup}{sb,ncue,2}             = new_freq;
            %             allsuj_data{ngroup}{sb,ncue,2}.label       = {'LatIndex_vis'};
            %             allsuj_data{ngroup}{sb,ncue,2}.powspctrm   = lIdx;
            %             allsuj_data{ngroup}{sb,ncue,2}.suj         = suj;

            clear lIdx audR audL
            
        end
        
        clc;
    end
end

clearvars -except allsuj_data list_ix

fOUT = '../documents/4R/ageing_attempt_lat_index_sep_time_sep_freq.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','CHAN','FREQ','TIME','POW','CUE_CAT','CUE_CONC','CUE_ORIG','MOD','HEMI','FREQ_CAT');

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        for ncue = 1:size(allsuj_data{ngroup},2)
            for nchan = 1:size(allsuj_data{ngroup},3)
                
                frq_win     = 0;
                frq_list    = 7:15;
                
                %                 if ngroup == 1
                %                     frq_list = [10 12]; % you changed how you calculate !!!!!
                %                 else
                %                     frq_list = [8 13]; % you changed how you calculate !!!!!
                %                 end
                
                tim_wind = 0.1;
                tim_list = 0.6:tim_wind:1;
                
                for nfreq = 1:length(frq_list)
                    for ntime = 1:length(tim_list)
                        
                        ls_group            = {'old','young'};
                        ls_cue              = {'R','L','N'};
                        ls_cue_cat          = {'informative','informative','uninformative'};
                        ls_threewise        = {'RCue','LCue','NCue'};
                        original_cue_list   = {'R','L','N'};
                        
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
                        
                        name_chan   =  allsuj_data{ngroup}{sb,ncue,nchan}.label{:};
                        chan_mod    = name_chan(end-2:end);
                        
                        suj         = allsuj_data{ngroup}{sb,ncue,nchan}.suj;
                        
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
                                
                                fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%.2f\t%s\t%s\t%s\t%s\t%s\t%s\n',ls_group{ngroup},suj,ls_cue{ncue},name_chan,ls_freq,ls_time,pow,ls_cue_cat{ncue},original_cue_list{ncue},ls_threewise{ncue},chan_mod,[name_chan(end) 'Hemi'],freq_cat);
                                
                            end
                            
                        end
                    end
                end
            end
        end
    end
end

fclose(fid);