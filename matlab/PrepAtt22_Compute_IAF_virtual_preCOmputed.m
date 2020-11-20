clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat
suj_group       = suj_group(1:2);

% [~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B'); % suj_group{1}        = suj_group{1}(2:22); % suj_group{1}        = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

fOUT                = '../documents/4R/age_contrast_broadman_w_motor_MinEvoked_iaf_p600p1000_1Cue_two_occ.txt';
fid                 = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','CHAN','TIME','CUE_CAT','CUE_CONC','CUE_ORIG','MOD','HEMI','IAF');

list_group          = {'old','young'};

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        
        ext_name                = 'AV.1t20Hz.M.1t40Hz.m800p2000msCov.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvoked';
        list_ix                 = {'CnD'};
        
        for ncue = 1:length(list_ix)
            
            fname_in                                = ['../data/ageing_data/' suj '.' list_ix{ncue} '.' ext_name '.mat'];
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            cfg                                     = [];
            cfg.baseline                            = [-0.6 -0.2];
            cfg.baselinetype                        = 'relchange';
            freq                                    = ft_freqbaseline(cfg,freq);
            
            ls_cue                                  = {'NLR'};
            ls_cue_cat                              = {'inuninformative'};
            ls_threewise                            = {'RLN_Cue'};
            original_cue_list                       = list_ix;
            
            flist                                   = [7 15];
            twin                                    = 0.4;
            tlist                                   = 0.6;
            
            for nchan = 1:length(freq.label)
                for ntime = 1:length(tlist)
                    
                    name_chan = freq.label{nchan};
                    
                    lmt1        = find(round(freq.time,3) == round(tlist(ntime),3));
                    lmt2        = find(round(freq.time,3) == round(tlist(ntime)+twin,3));
                    
                    lmf1        = find(round(freq.freq) == round(flist(1)));
                    lmf2        = find(round(freq.freq) == round(flist(end)));
                    
                    data        = squeeze(freq.powspctrm(nchan,lmf1:lmf2,lmt1:lmt2));
                    data        = squeeze(mean(data,2))';
                    
                    f_axes      = round(freq.freq(lmf1:lmf2));
                    
                    chn_prts    = strsplit(name_chan,'_');
                    
                    if length(chn_prts) > 1
                        chan_mod    = chn_prts{1};
                    else
                        chan_mod = name_chan(1:3);
                    end
                    
                    if strcmp(chan_mod,'aud') || strcmp(chan_mod,'mot')
                        iaf         = f_axes(find(data==min(data)));
                    else
                        iaf         = f_axes(find(data==max(data)));
                    end
                    
                    ls_time     = [num2str(tlist(ntime)*1000) 'ms'];
                    
                    if length(chn_prts) > 1
                        chan_hemi   = [chn_prts{2} '_Hemi'];
                    else
                        chan_hemi   = [name_chan(end) '_Hemi'];
                    end
                    
                    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%.2f\n',list_group{ngroup},[list_group{ngroup} num2str(sb)]...
                        ,chn_prts{1},name_chan,ls_time,ls_cue_cat{ncue},original_cue_list{ncue},ls_threewise{ncue},chan_mod,chan_hemi,iaf);
                    
                end
            end
        end
    end
end

fclose(fid);