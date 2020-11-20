clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

lst_group       = {'allyoung'};

for ngroup = 1:length(lst_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        cond_main               = 'CnD';
        list_ix                 = {'R','L','NR','NL'};
        
        for cnd = 1:length(list_ix)
            
            fname_in                = ['../data/' suj '/field/' suj '.' list_ix{cnd} cond_main '.AllYungSeparatePlusCombined.50t120Hz.m800p2000msCov.waveletPOW.40t120Hz.m1000p2000.AvgTrials.100Slct.AudLR.MinEvoked.mat'];
            
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            cfg                                                 = [];
            cfg.channel                                         = 2;
            freq                                                = ft_selectdata(cfg,freq);
            
            cfg                                                 = [];
            cfg.baseline                                        = [-0.3 -0.1];
            cfg.baselinetype                                    = 'relchange';
            freq                                                = ft_freqbaseline(cfg,freq);
            
            for nchan = 1:length(freq.label)
                allsuj_data{ngroup}{sb,cnd,nchan}               = freq;
                allsuj_data{ngroup}{sb,cnd,nchan}.powspctrm     = freq.powspctrm(nchan,:,:);
                allsuj_data{ngroup}{sb,cnd,nchan}.label         = freq.label(nchan);
            end
            
            clear freq
            
        end
    end
end

clearvars -except allsuj_data big_freq

fOUT = '../documents/4R/AllYoungControlGamma.AllYungIndex.AudR.MinEvoked.100Slct.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','CHAN','FREQ','TIME','POW','CUE_CAT','CUE_CONC','CUE_ORIG');

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        for ncue = 1:size(allsuj_data{ngroup},2)
            for nchan = 1:size(allsuj_data{ngroup},3)
                
                frq_win  = 5;
                
                frq_list = 50:frq_win:95;
                
                tim_wind = 0.1;
                
                tim_list = 0.2:tim_wind:1.9;
                
                for nfreq = 1:length(frq_list)
                    for ntime = 1:length(tim_list)
                        
                        ls_group            = {'young'};
                        
                        ls_cue              = {'R','L','R','L'};
                        ls_cue_cat          = {'informative','informative','uninformative','uninformative'};
                        ls_threewise        = {'RCue','LCue','NCue','NCue'};
                        original_cue_list   = {'R','L','NR','NL'};
                        
                        ls_chan  = allsuj_data{ngroup}{sb,ncue,nchan}.label;
                        
                        ls_time  = [num2str(tim_list(ntime)*1000) 'ms'];
                        
                        ls_freq  = [num2str(frq_list(nfreq)) 'Hz'];
                        
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
                                
                                fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%.2f\t%s\t%s\t%s\n',ls_group{ngroup},['yc' num2str(sb)],ls_cue{ncue},ls_chan{:},ls_freq,ls_time,pow,ls_cue_cat{ncue},original_cue_list{ncue},ls_threewise{ncue});
                                
                            end
                        end
                    end
                end
            end
        end
    end
end

fclose(fid);