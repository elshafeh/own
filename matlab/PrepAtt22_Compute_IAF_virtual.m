clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

fOUT = '../documents/4R/new_paper_yc_iaf_p600p1000_1Cue_two_occ.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','CHAN','TIME','CUE_CAT','CUE_CONC','CUE_ORIG','MOD','HEMI','IAF');

load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat
suj_group           = suj_group(1:2);
list_group          = {'old','young'};

% [~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_group{1}        = suj_group{1}(2:22);
% list_group       = {'Allyoung'};

for ngroup = 1:length(list_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        cond_main               = 'CnD';
        
        if strcmp(suj(1:2),'oc')
            ext_name               ='.14AudOc.1t20Hz.m800p2000msCov';
        else
            ext_name               ='.14AudYc.1t20Hz.m800p2000msCov';
        end
        
        fname_in                = ['../data/' suj '/field/' suj '.' cond_main '.' ext_name2 '.mat'];
        
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'check_trialinfo')
            freq = rmfield(freq,'check_trialinfo');
        end
        
        list_ix_cue        = {0,1,2};
        list_ix_tar        = {1:4,1:4,1:4};
        list_ix_dis        = {0,0,0};
        
        ls_cue              = {'N','L','R'};
        ls_cue_cat          = {'uninformative','informative','informative'};
        ls_threewise        = {'NCue','LCue','RCue'};
        original_cue_list   = {'NCue','LCue','RCue'};
                
        for ncue = 1:length(list_ix_cue)
            
            cfg                         = [];
            cfg.trials                  = h_chooseTrial(freq,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue});
            new_freq                    = ft_selectdata(cfg,freq);
            new_freq                    = ft_freqdescriptives([],new_freq);
            
            cfg                         = [];
            cfg.baseline                = [-0.6 -0.2];
            cfg.baselinetype            = 'relchange';
            new_freq                    = ft_freqbaseline(cfg, new_freq);
            
            flist       = [7 15];
            twin        = 0.4;
            tlist       = 0.6;
            
            for nchan = 1:length(new_freq.label)
                for ntime = 1:length(tlist)
                    
                    name_chan = new_freq.label{nchan};
                    
                    lmt1    = find(round(new_freq.time,3) == round(tlist(ntime),3));
                    lmt2    = find(round(new_freq.time,3) == round(tlist(ntime)+twin,3));
                    
                    lmf1    = find(round(new_freq.freq) == round(flist(1)));
                    lmf2    = find(round(new_freq.freq) == round(flist(end)));
                    
                    data    = squeeze(new_freq.powspctrm(nchan,lmf1:lmf2,lmt1:lmt2));
                    data    = squeeze(mean(data,2))';
                    
                    f_axes  = round(new_freq.freq(lmf1:lmf2));
                    
                    if strcmp(name_chan(1),'a')
                        chan_mod    = 'Auditory';
                        iaf         = f_axes(find(data==min(data)));
                    else
                        chan_mod = 'Occipital';
                        iaf         = f_axes(find(data==max(data)));
                    end
                    
                    chn_prts = strsplit(name_chan,'_');
                    ls_time  = [num2str(tlist(ntime)*1000) 'ms'];
                    
                    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%.2f\n',list_group{ngroup},[list_group{ngroup} num2str(sb)],ls_cue{ncue},name_chan,ls_time,ls_cue_cat{ncue},original_cue_list{ncue},ls_threewise{ncue},chan_mod,[name_chan(end) 'Hemi'],iaf);
                    
                end
            end
        end
    end
end

fclose(fid);