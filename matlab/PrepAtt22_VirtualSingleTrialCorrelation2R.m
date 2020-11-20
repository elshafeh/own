clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,allsuj,~]        = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_group{1}        = allsuj(2:15,1);
suj_group{2}        = allsuj(2:15,2);
list_group          = {'Old','Young'};

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        
        ext_nam1                = 'CnD.AV.1t20Hz.M.1t40Hz.m800p2000msCov';
        ext_nam2                = 'waveletPOW.1t20Hz.m3000p3000.KeepTrialsMinEvoked';
        
        ext_name                = [ext_nam1 '.' ext_nam2];
        
        fname_in                = ['../data/ageing_data/' suj '.' ext_name '.mat'];
        
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'check_trialinfo')
            freq = rmfield(freq,'check_trialinfo');
        end
        
        lmt1                                        = find(round(freq.time,3) == round(-0.6,3));
        lmt2                                        = find(round(freq.time,3) == round(-0.2,3));
        
        bsl                                         = mean(freq.powspctrm(:,:,:,lmt1:lmt2),4);
        bsl                                         = repmat(bsl,[1 1 1 size(freq.powspctrm,4)]);
        
        freq.powspctrm                              = freq.powspctrm ./ bsl ; clear bsl ;
        
        cfg                                         = [];
        cfg.latency                                 = [0.6 1];
        cfg.frequency                               = [7 15];
        freq                                        = ft_selectdata(cfg,freq);
        
        list_ix_cue                                 = 0:2;
        list_ix_tar                                 = 1:4;
        list_ix_dis                                 = 0;
        [~,~,~,~,strial_rt]                         = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
        
        allsuj_data{ngroup}{sb,1}.powspctrm         = [];
        allsuj_data{ngroup}{sb,1}.dimord            = 'chan_freq_time';
        
        allsuj_data{ngroup}{sb,1}.freq              = freq.freq; % freq_list;
        allsuj_data{ngroup}{sb,1}.time              = freq.time; % time_list;
        allsuj_data{ngroup}{sb,1}.label             = freq.label;
        
        fprintf('Calculating Correlation for %s\n',suj)
        
        for nfreq = 1:length(freq.freq)
            for ntime = 1:length(freq.time)
                
                data        = squeeze(freq.powspctrm(:,:,nfreq,ntime));
                
                [rho,p]     = corr(data,strial_rt , 'type', 'Spearman');
                
                rhoF        = .5.*log((1+rho)./(1-rho));
                
                allsuj_data{ngroup}{sb,1}.powspctrm(:,nfreq,ntime) = rhoF ; clear rho p data ;
                
            end
        end
        
    end
end

clearvars -except allsuj_data list_*

fOUT = '../documents/4R/ageing_CnD_virtual_singleTrialCorrelation.txt';

fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','FREQ','TIME','MOD','HEMI','FREQ_CAT','ZCORR');

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        
        fprintf('Handling %s\n',num2str(sb));
        
        frq_win  = 0;
        frq_list = allsuj_data{ngroup}{sb,1}.freq;
        
        tim_wind = 0;
        tim_list = allsuj_data{ngroup}{sb,1}.time;
        
        for nchan = 1:length(allsuj_data{ngroup}{sb,1}.label)
            for nfreq = 1:length(frq_list)
                for ntime = 1:length(tim_list)
                    
                    ls_chan             = allsuj_data{ngroup}{sb,1}.label{nchan};
                    
                    if tim_list(ntime) < 1
                        ls_time  = ['0' num2str(tim_list(ntime)*1000) 'ms'];
                    elseif tim_list(ntime) == 1
                        ls_time  = [num2str(tim_list(ntime)*1000) 'ms'];
                    else
                        ls_time  = [num2str(tim_list(ntime)*1000) 'ms'];
                    end
                    
                    if frq_list(nfreq) < 10
                        ls_freq             = ['0' num2str(round(frq_list(nfreq))) 'Hz'];
                    else
                        ls_freq             = [num2str(round(frq_list(nfreq))) 'Hz'];
                    end
                    
                    name_chan               =  ls_chan;
                    name_parts              =  strsplit(name_chan,'_');
                    
                    %--%
                    chan_mod                = name_chan(1:3) ; % name_parts{1};
                    %--%
                    chan_hemi               = [name_chan(end) '_Hemi'] ; % [name_parts{end} '_Hemi'];
                    %--%
                    
                    suj                     = [list_group{ngroup} num2str(sb)];
                    
                    if frq_list(nfreq) < 11
                        freq_cat = 'low_freq';
                    else
                        freq_cat = 'high_freq';
                    end
                    
                    x1       = find(round(allsuj_data{ngroup}{sb,1}.time,2)== round(tim_list(ntime),2));
                    x2       = find(round(allsuj_data{ngroup}{sb,1}.time,2)== round(tim_list(ntime)+tim_wind,2));
                    
                    y1       = find(round(allsuj_data{ngroup}{sb,1}.freq)== round(frq_list(nfreq)-frq_win));
                    y2       = find(round(allsuj_data{ngroup}{sb,1}.freq)== round(frq_list(nfreq)+frq_win));
                    
                    pow      = nanmean(allsuj_data{ngroup}{sb,1}.powspctrm(nchan,y1:y2,x1:x2),3);
                    pow      = squeeze(nanmean(pow,2));
                    
                    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%.5f\n',list_group{ngroup},suj,ls_freq,ls_time,chan_mod,chan_hemi,freq_cat,pow);

                end
            end
        end
    end
end

fclose(fid)