clear ; clc ;

global ft_default
ft_default.spmversion = 'spm12';

[~,allsuj,~]    = xlsread('../../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{2}    = allsuj(2:15,1);
suj_group{1}    = allsuj(2:15,2);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                                         = suj_list{sb};
        ext_name                                    = 'CnD.AV.1t20Hz.M.1t40Hz.m800p2000msCov.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvoked.mat';
        list_cue                                    = {'V','N'};
        
        for ncue = 1:length(list_cue)
            
            fname_in                                = ['../../data/ageing_data/' suj '.' list_cue{ncue} ext_name];
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            cfg                                     = [];
            cfg.baseline                            = [-0.6 -0.2];
            cfg.baselinetype                        = 'relchange';
            freq                                    = ft_freqbaseline(cfg,freq);
            
            bn_width                                = 0;
            
            list_iaf                                = ageingrev_infunc_iaf(freq);
            allsuj_data{ngroup}{sb,ncue}            = ageingrev_infunc_adjustiaf(freq,list_iaf,bn_width);
            allsuj_data{ngroup}{sb,ncue}.suj        = suj;
            
        end
    end
end

clearvars -except allsuj_data list_* bn_width

list_group      = {'young','old'};
ls_group        = list_group;

fOUT            = ['../../documents/4R/ageingrev_alphatimecourse_adapted' num2str(bn_width) 'Hz_CUECAT.txt'];

fid             = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE_SIDE','CHAN','FREQ', ... 
    'TIME','POW','CUE_CAT','CUE_CONC','CUE_ORIG','MOD','HEMI','FREQ_CAT','CUE_POSITION','group_use','group_perc');

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        
        fprintf('Handling %s\n',num2str(sb));
        
        for ncue = 1:size(allsuj_data{ngroup},2)
            for nchan = 1:length(allsuj_data{ngroup}{sb,ncue}.label)
                
                tim_wind = 0.1;
                tim_list = 0.6:tim_wind:0.9;  

                for nfreq = 1
                    for ntime = 1:length(tim_list)
                        
                        original_cue_list   = list_cue;
                        ls_cue              = original_cue_list;
                        ls_threewise        = original_cue_list;
                        ls_cue_cat          = {'informative','uninformative'};
                        
                        ls_chan             = allsuj_data{ngroup}{sb,ncue}.label{nchan};
                        
                        if tim_list(ntime) < 1
                            ls_time  = ['0' num2str(tim_list(ntime)*1000) 'ms'];
                        elseif tim_list(ntime) == 1
                            ls_time  = [num2str(tim_list(ntime)*1000) 'ms'];
                        else
                            ls_time  = [num2str(tim_list(ntime)*1000) 'ms'];
                        end

                        ls_freq                 = 'iaf-adapted';
                        freq_cat                = ls_freq;
                        
                        name_chan               =  ls_chan;
                        name_parts              =  strsplit(name_chan,'_');
                        
                        %--%
                        chan_mod                = name_chan(1:3) ; % name_parts{1};
                        %--% 
                        chan_hemi               = [name_chan(end) '_Hemi'] ; % [name_parts{end} '_Hemi'];
                        %--%
                        
                        suj                     = allsuj_data{ngroup}{sb,ncue}.suj;
                        where_suj               = 'a';
                        
                        cue_check               = ls_cue{ncue};
                        group_rt                = cue_check;
                        
                        group_use               = 'a';
                        group_perc              = 'a';
                        
                        data    = allsuj_data{ngroup}{sb,ncue};
                                                
                        x1       = find(round(data.time,2)== round(tim_list(ntime),2));
                        x2       = find(round(data.time,2)== round(tim_list(ntime)+tim_wind,2));
                        
                        if isempty(x1) || isempty(x2)
                            error('ahhhh')
                        else
                            
                            pow      = nanmean(data.avg(nchan,x1:x2),2);
                            
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