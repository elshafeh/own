clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_group{1}       = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        
        cond_main               = 'CnD';
        ext_name2               = 'MaxAudVizMotor.BigCov.VirtTimeCourse.waveletPOW.1t20Hz.m3000p3000.KeepTrialsMinEvoked';
        list_ix                 = {'N','L','R'};
        
        for ncue          = 1:length(list_ix)
            
            fname_in                = ['../data/paper_data/' suj '.' list_ix{ncue} cond_main '.' ext_name2 '.mat'];
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            lmt1                                    = find(round(freq.time,3) == round(-0.6,3)); % baseline period
            lmt2                                    = find(round(freq.time,3) == round(-0.2,3)); % baseline period
            
            bsl                                     = mean(freq.powspctrm(:,:,:,lmt1:lmt2),4);
            bsl                                     = repmat(bsl,[1 1 1 size(freq.powspctrm,4)]);
            
            freq.powspctrm                          = freq.powspctrm ./ bsl ; clear bsl ;
            
            lmt1                                    = find(round(freq.time,3) == round(0.6,3)); % baseline period
            lmt2                                    = find(round(freq.time,3) == round(1,3)); % baseline period
            pow                                     = mean(freq.powspctrm(:,:,:,lmt1:lmt2),4);

            freq.powspctrm                          = pow;
            freq.time                               = 0.8;
            
            allsuj_data{ngroup}{sb,ncue}.powspctrm  = [];
            allsuj_data{ngroup}{sb,ncue}.dimord     = 'chan_freq_time';
            
            allsuj_data{ngroup}{sb,ncue}.freq       = freq.freq ; %freq_list;
            allsuj_data{ngroup}{sb,ncue}.time       = freq.time ; %time_list;
            allsuj_data{ngroup}{sb,ncue}.label      = freq.label;
            allsuj_data{ngroup}{sb,ncue}.suj        = suj;
            
            fprintf('Calculating Correlation for %s\n',suj)
            
            for nfreq = 1:length(freq.freq)
                for ntime = 1:length(freq.time)
                    
                    data            = squeeze(freq.powspctrm(:,:,nfreq,ntime));
                    
                    load ../data/yctot/rt/rt_cond_classified.mat
                    
                    new_strl_rt     = rt_classified{sb,ncue};
                    
                    [rho,p]         = corr(data,new_strl_rt , 'type', 'Spearman');
                    
                    rhoF            = .5.*log((1+rho)./(1-rho));
                    
                    allsuj_data{ngroup}{sb,ncue}.powspctrm(:,nfreq,ntime) = rhoF ; % !!!
                    clear rho p data ;
                    
                end
            end
        end
    end
end

clearvars -except allsuj_data ;

fOUT = '../documents/4R/prep_21_spearman_correlation_MinEvoked_laterality_time_averaged_sep_freq.txt';

fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','CHAN','FREQ','TIME','SCoeff','CUE_CAT','CUE_CONC','CUE_ORIG','MOD','HEMI','FREQ_CAT','CUE_POSITION','group_use','group_perc');

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        
        fprintf('Handling %s\n',num2str(sb));
        
        for ncue = 1:size(allsuj_data{ngroup},2)
            for nchan = 1:length(allsuj_data{ngroup}{sb,ncue}.label)
                
                frq_win  = 0;
                frq_list = 7:15; % you changed how you calculate !!!!!
                
                tim_wind = 0;
                tim_list = 0.8; %0.6:tim_wind:0.9;

                for nfreq = 1:length(frq_list)
                    for ntime = 1:length(tim_list)
                        
                        ls_group            = {'paper_yc'};
                        ls_cue              = {'N','L','R'};
                        ls_cue_cat          = {'uninformative','informative','informative'};
                        ls_threewise        = {'N_Cue','L_Cue','R_Cue'};
                        original_cue_list   = ls_cue;
                        
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
                        
                        chan_mod                = name_parts{1};
                        chan_hemi               = [name_parts{end} '_Hemi'];
                        
                        suj                     = allsuj_data{ngroup}{sb,ncue}.suj;
                        where_suj               = 'a';%find(strcmp(allsuj_behav(:,2),suj));
                        
                        if strcmp(chan_hemi,'L_Hemi')
                            
                            if strcmp(ls_cue{ncue},'L')
                                group_rt                = 'ipsilateral';
                            elseif strcmp(ls_cue{ncue},'R')
                                group_rt                = 'contralateral';
                            else
                                group_rt                = 'uninformative';
                            end
                            
                        elseif strcmp(chan_hemi,'R_Hemi')
                            
                            if strcmp(ls_cue{ncue},'L')
                                group_rt                = 'contralateral';
                            elseif strcmp(ls_cue{ncue},'R')
                                group_rt                = 'ipsilateral';
                            else
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
                        
                        chn_prts = strsplit(name_chan,'_');
                        
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