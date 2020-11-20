clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat

suj_group = suj_group(1:2);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup}; 
    
    for sb = 1:length(suj_list)
        
        suj                = suj_list{sb};
        cond_main          = 'CnD';
        
        if strcmp(suj(1:2),'oc')
            ext_name2               ='14AudOc.1t20Hz.m800p2000msCov.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvokedAllTrials';
        else
            ext_name2               ='14AudYc.1t20Hz.m800p2000msCov.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvokedAllTrials';
        end
        
        list_ix            = {'R','L','N'};
        
        for ncue = 1:length(list_ix)
            
            fname_in                = ['../data/pat22_data/' suj '.' list_ix{ncue} cond_main '.' ext_name2 '.mat'];
            
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            cfg                     = [];
            cfg.baseline            = [-0.6 -0.2];
            cfg.baselinetype        = 'relchange';
            new_freq                = ft_freqbaseline(cfg,freq);
            
            tmp{ncue}               = new_freq;
            
        end
        
        cfg                        = [];
        cfg.parameter              = 'powspctrm';
        cfg.operation              =  '(x1-x2)'; % '(x1-x2)/x2'; %
        allsuj_data{ngroup}{sb,1}  = ft_math(cfg,tmp{1},tmp{3});
        allsuj_data{ngroup}{sb,2}  = ft_math(cfg,tmp{2},tmp{3});
        
    end
end

clearvars -except allsuj_data ;

fOUT = '../documents/4R/PrepAtt2_Inf_minus_index_age_contrast_separateROIs_two_Freq_Sep_Time.txt';

fid  = fopen(fOUT,'W+');

fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','CHAN','FREQ','TIME','POW','MOD','HEMI','FREQ_CAT');

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        for ncue = 1:size(allsuj_data{ngroup},2)
            for nchan = 1:length(allsuj_data{ngroup}{sb,ncue}.label)
                
                frq_win     = 0;
                
                if ngroup == 1
                    frq_list = [10 12]; % you changed how you calculate !!!!!
                else
                    frq_list = [8 13]; % you changed how you calculate !!!!!
                end
                
                tim_wind = 0.1;
                tim_list = 0.6:tim_wind:1;
                
                for nfreq = 1:length(frq_list)
                    for ntime = 1:length(tim_list)
                        
                        ls_group            = {'old','young'};
                        ls_cue              = {'RminusN','LminusN'};
                                                
                        if tim_list(ntime) < 1
                            ls_time  = ['0' num2str(tim_list(ntime)*1000) 'ms'];
                        else
                            ls_time  = [num2str(tim_list(ntime)*1000) 'ms'];
                        end
                        
                        if strcmp(ls_time,'01000ms')
                            ls_time = '1000ms';
                        end
                        
                        if frq_list(nfreq) < 10
                            ls_freq             = ['0' num2str(frq_list(nfreq)) 'Hz'];
                        else
                            ls_freq             = [num2str(frq_list(nfreq)) 'Hz'];
                        end
                                                
                        name_chan           =  allsuj_data{ngroup}{sb,ncue}.label{nchan};
                        name_parts          =  strsplit(name_chan,'_');
                        
                        chan_mod            = name_parts{1};
                        chan_hemi           = [name_parts{end} '_Hemi'];
                        
                        if frq_list(nfreq) < 11
                            freq_cat = 'low_freq';
                        elseif frq_list(nfreq) > 11
                            freq_cat = 'high_freq';
                        else
                            freq_cat = 'eleven';
                        end
                        
                        chn_prts = strsplit(name_chan,'_');
                        
                        x1       = find(round(allsuj_data{ngroup}{sb,ncue}.time,2)== round(tim_list(ntime),2));
                        x2       = find(round(allsuj_data{ngroup}{sb,ncue}.time,2)== round(tim_list(ntime)+tim_wind,2));
                        
                        y1       = find(round(allsuj_data{ngroup}{sb,ncue}.freq)== round(frq_list(nfreq)));
                        y2       = find(round(allsuj_data{ngroup}{sb,ncue}.freq)== round(frq_list(nfreq)+frq_win));
                        
                        if isempty(x1) || isempty(x2) || isempty(y1) || isempty(y2)
                            error('ahhhh')
                        else
                            pow      = mean(allsuj_data{ngroup}{sb,ncue}.powspctrm(nchan,y1:y2,x1:x2),3);
                            pow      = squeeze(mean(pow,2));
                            
                            if size(pow,1) > 1 || size(pow,2) > 1
                                error('oohhhhhhh')
                            else
                                
                                fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%.2f\t%s\t%s\t%s\n',ls_group{ngroup},[ls_group{ngroup} num2str(sb)],ls_cue{ncue},name_chan,ls_freq,ls_time,pow,chan_mod,name_chan(end),freq_cat);
                                
                            end
                            
                        end
                    end
                end
            end
        end
    end
end

fclose(fid);