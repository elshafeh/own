clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

% [~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_group{1}        = suj_group{1}(2:22);

fOUT                = '../documents/4R/NewAVMBroad_AgeContrast_IAF_AllTrials_p600p1000.txt';
fid                 = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','CHAN','TIME','CUE_CAT','CUE_CONC','CUE_ORIG','MOD','HEMI','IAF');

list_group          = {'old','young'};

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        ext_name2               = 'NewAVBroad.1t20Hz.m800p2000msCov.waveletPOW.1t20Hz.m3000p3000.KeepTrialsMinEvoked10MStep';
        
        list_ix                 = {'CnD'};
        
        for ncue = 1:length(list_ix)
            
            fname_in                = ['../data/' suj '/field/' suj '.' list_ix{ncue} '.' ext_name2 '.mat'];
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            freq                                    = ft_freqdescriptives([],freq);
            freq                                    = h_transform_freq(freq,{[1 3 5],[2 4 6],[7 9 11],[8 10 12]},{'occ_L','occ_R','aud_L','aud_R'});
            
            cfg                                     = [];
            cfg.baseline                            = [-0.6 -0.2];
            cfg.baselinetype                        = 'relchange';
            freq                                    = ft_freqbaseline(cfg,freq);
            
            ls_cue                                  = {'R','L','RL'};
            ls_cue_cat                              = {'informative','informative','uninformative'};
            ls_threewise                            = {'R_Cue','L_Cue','N_Cue'};
            original_cue_list                       = list_ix;
            
            flist                                   = [7 15];
            twin                                    = 0.4;
            tlist                                   = 0.6;
            
            for nchan = 1:length(freq.label)
                for ntime = 1:length(tlist)
                    
                    name_chan = freq.label{nchan};
                    
                    lmt1    = find(round(freq.time,3) == round(tlist(ntime),3));
                    lmt2    = find(round(freq.time,3) == round(tlist(ntime)+twin,3));
                    
                    lmf1    = find(round(freq.freq) == round(flist(1)));
                    lmf2    = find(round(freq.freq) == round(flist(end)));
                    
                    data    = squeeze(freq.powspctrm(nchan,lmf1:lmf2,lmt1:lmt2));
                    data    = squeeze(mean(data,2))';
                    
                    f_axes  = round(freq.freq(lmf1:lmf2));
                    
                    if strcmp(name_chan(1),'a')
                        chan_mod    = 'Auditory';
                        iaf         = f_axes(find(data==min(data)));
                    else
                        chan_mod = 'Occipital';
                        iaf         = f_axes(find(data==max(data)));
                    end
                    
                    ls_time     = [num2str(tlist(ntime)*1000) 'ms'];
                    
                    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%.2f\n',list_group{ngroup},[list_group{ngroup} num2str(sb)],ls_cue{ncue},name_chan,ls_time,ls_cue_cat{ncue},original_cue_list{ncue},ls_threewise{ncue},chan_mod,[name_chan(end) 'Hemi'],iaf);
                    
                end
            end
        end
    end
end

fclose(fid);