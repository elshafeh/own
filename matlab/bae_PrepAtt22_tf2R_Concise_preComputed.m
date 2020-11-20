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
        
        ext_name2               = 'AV5Neigh.50t120Hz.m800p2000msCov.waveletPOW.50t119Hz.m3000p3000.AvgTrialsMinEvoked100Slct';

        list_ix                 = {'R','L','NR','NL'};
        
        for ncue = 1:length(list_ix)
            
            fname_in                = ['../data/' suj '/field/' suj '.' list_ix{ncue} cond_main '.' ext_name2 '.mat'];
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            if size(freq.powspctrm,4) > 1
                freq                                    = ft_freqdescriptives([],freq);
            end
            
            cfg                                     = [];
            cfg.baseline                            = [-0.3 -0.1];
            cfg.baselinetype                        = 'relchange';
            freq                                    = ft_freqbaseline(cfg,freq);
            
            allsuj_data{ngroup}{sb,ncue}            = freq;
            allsuj_data{ngroup}{sb,ncue}.suj        = suj;
            
            clear new_freq cfg
            

        end
        
        %         cfg                                     = [];
        %         cfg.parameter                           = 'powspctrm';
        %         cfg.operation                           = 'x1-x2';
        %
        %         allsuj_data{ngroup}{sb,4}               = ft_math(cfg,allsuj_data{ngroup}{sb,1},allsuj_data{ngroup}{sb,3});
        %         allsuj_data{ngroup}{sb,5}               = ft_math(cfg,allsuj_data{ngroup}{sb,2},allsuj_data{ngroup}{sb,3});
        %
        %         allsuj_data{ngroup}{sb,4}.suj           = suj;
        %         allsuj_data{ngroup}{sb,5}.suj           = suj;
        
    end
end

clearvars -except allsuj_data big_freq

fOUT = '../documents/4R/all_control_5Neigh_gamma_no_index_with_minusCue_post_target_unf_separate.txt';

fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','CHAN','FREQ','TIME','POW','CUE_CAT','CUE_CONC','CUE_ORIG','MOD','HEMI','FREQ_CAT');

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        
        fprintf('Handling %s\n',num2str(sb));
        
        for ncue = 1:size(allsuj_data{ngroup},2)
            for nchan = 1:length(allsuj_data{ngroup}{1,ncue}.label)
                
                frq_win  = 40;
                frq_list = 60; %:frq_win:90;
                
                tim_wind = 0.1;
                tim_list = 1.2:tim_wind:2;
                
                for nfreq = 1:length(frq_list)
                    for ntime = 1:length(tim_list)
                        
                        %                         ls_cue              = {'R','L','RL','RmN','LmN'};
                        %                         ls_cue_cat          = {'informative','informative','uninformative','minus','minus'};
                        %                         ls_threewise        = {'R_Cue','L_Cue','N_Cue','RmN','LmN'};
                        %                         original_cue_list   = {'R','L','N','RmN','LmN'};
                        
                        if length(allsuj_data) > 1
                            ls_group            = {'old','young'};
                        else
                            ls_group            = {'allYoung'};
                        end
                        
                        ls_group            = {'14old'};
                        ls_cue              = {'R','L','R','L'};
                        ls_cue_cat          = {'informative','informative','uninformative','uninformative'};
                        ls_threewise        = {'R_Cue','L_Cue','N_Cue','N_Cue'};
                        original_cue_list   = {'R','L','NR','NL'};
                        
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
                        
                        suj = allsuj_data{ngroup}{sb,ncue}.suj;
                        
                        if frq_list(nfreq) < 11
                            freq_cat = 'low_freq';
                        else
                            freq_cat = 'high_freq';
                        end
                                                
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
                                
                                fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%.6f\t%s\t%s\t%s\t%s\t%s\t%s\n',ls_group{ngroup},suj,ls_cue{ncue},name_chan,ls_freq,ls_time,pow,ls_cue_cat{ncue},original_cue_list{ncue},ls_threewise{ncue},chan_mod,chan_hemi,freq_cat);
                                
                            end
                            
                        end
                    end
                end
            end
        end
    end
end

fclose(fid);