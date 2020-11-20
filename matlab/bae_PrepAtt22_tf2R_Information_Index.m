clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

[~,suj_group{3},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{3}        = suj_group{3}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        cond_main               = 'CnD';
        
        ext_name1               = '1t20Hz';
        ext_name2               = 'broadAreas.1t20Hz.m800p2000msCov.waveletPOW.1t19Hz.m3000p3000.KeepTrials';
        
        fname_in                = ['../data/' suj '/field/' suj '.' cond_main '.' ext_name2 '.mat'];
        
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'check_trialinfo')
            freq = rmfield(freq,'check_trialinfo');
        end
        
        list_ix_cue        = {2,1,0,0};
        list_ix_tar        = {[2 4],[1 3],[2 4],[1 3]};
        list_ix_dis        = {0,0,0,0};
        list_ix            = {'R','L','NR','NL'};
        
        for ncue = 1:length(list_ix_cue)
            
            cfg                    = [];
            cfg.trials             = h_chooseTrial(freq,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue}) ;
            new_freq               = ft_selectdata(cfg,freq);
            new_freq               = ft_freqdescriptives([],new_freq);
            
            %             cfg                     = [];
            %             cfg.baseline            = [-0.6 -0.2];
            %             cfg.baselinetype        = 'relchange';
            %             new_freq                = ft_freqbaseline(cfg,new_freq);
            
            tmp{ncue}                = new_freq;
            
        end
        
        cfg                         = [];
        cfg.parameter               = 'powspctrm';
        cfg.operation               = '(x1-x2)';
        new_tmp{1}                  = ft_math(cfg,tmp{1},tmp{3});
        new_tmp{2}                  = ft_math(cfg,tmp{2},tmp{4});
        
        clear tmp ;
        
        for ncue = 1:length(new_tmp)
            for nchan = 1:length(new_tmp{ncue}.label)
                
                allsuj_data{ngroup}{sb,ncue,nchan}            = new_tmp{ncue};
                allsuj_data{ngroup}{sb,ncue,nchan}.powspctrm  = new_tmp{ncue}.powspctrm(nchan,:,:);
                allsuj_data{ngroup}{sb,ncue,nchan}.label      = new_tmp{ncue}.label(nchan);
                
            end
        end
        
        clear new_tmp
        
    end
end

clearvars -except allsuj_data ;

fOUT = '../documents/4R/3Groups_BroadAuditoryOccipital_Information_Index_no_Baseline_Corrected.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','CHAN','FREQ','TIME','POW','MOD','HEMI','FREQ_CAT');

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        for ncue = 1:size(allsuj_data{ngroup},2)
            for nchan = 1:size(allsuj_data{ngroup},3)
                
                frq_win  = 0;
                
                frq_list = 7:15;
                
                tim_wind = 0.1;
                
                tim_list = 0.6:tim_wind:1;
                
                for nfreq = 1:length(frq_list)
                    for ntime = 1:length(tim_list)
                        
                        ls_group            = {'old','young','allyoung'};
                        ls_cue              = {'RmNR','LmNL'};
                        
                        ls_chan  = allsuj_data{ngroup}{sb,ncue,nchan}.label;
                        
                        ls_time  = [num2str(tim_list(ntime)*1000) 'ms'];
                        
                        ls_freq  = [num2str(frq_list(nfreq)) 'Hz'];
                        
                        name_chan =  ls_chan{:};
                        
                        if strcmp(name_chan(1),'V')
                            chan_mod = 'Occipital';
                        else
                            chan_mod = 'Auditory';
                        end
                        
                        if frq_list(nfreq) < 11
                            freq_cat = 'high_cat';
                        elseif frq_list(nfreq) > 11
                            freq_cat = 'high_freq';
                        else
                            freq_cat = 'eleven';
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
                                
                                fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%.2f\t%s\t%s\t%s\n',ls_group{ngroup},[ls_group{ngroup} num2str(sb)],ls_cue{ncue},ls_chan{:},ls_freq,ls_time,pow,chan_mod,chn_prts{end},freq_cat);
                                
                            end
                            
                        end
                    end
                end
            end
        end
    end
end

fclose(fid);