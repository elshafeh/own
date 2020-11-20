clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); clc ;

fOUT = '../doc/prep21_IAF_AllTrials_p600p1000.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','CHAN','TIME','CUE_CAT','CUE_CONC','CUE_ORIG','MOD','HEMI','IAF');

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj                 = ['yc' num2str(suj_list(sb))];
    fname_in            = ['../data/paper_data/' suj '.CnD.MaxAudVizMotor.BigCov.VirtTimeCourse.KeepTrial.wav.1t20Hz.m3000p3000..mat'];
    
    load(fname_in);
    
    freq                = rmfield(freq,'hidden_trialinfo');
    freq                = h_transform_freq(freq,{1,2,[3 5],[4 6]},{'occL','occR','audL','audR'});
    
    list_ix_cue         = {0,1,2};
    list_ix_tar         = {1:4,1:4,1:4};
    list_ix_dis         = {0,0,0};
    
    ls_cue              = {'N','L','R'};   
    ls_cue_cat          = {'uninformative','informative','informative'};
    ls_threewise        = {'NCue','LCue','RCue'};
    original_cue_list   = {'N','L','R'};
    
    for ncue = 1:length(list_ix_cue)
        
        cfg                         = [];
        cfg.trials                  = h_chooseTrial(freq,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue});
        new_freq                    = ft_selectdata(cfg,freq);
        new_freq                    = ft_freqdescriptives([],new_freq);
        
        cfg                         = [];
        cfg.baseline                = [-0.6 -0.2];
        cfg.baselinetype            = 'relchange';
        new_freq                    = ft_freqbaseline(cfg, new_freq);
        
        flist                       = [7 15];
        twin                        = 0.5;
        tlist                       = 0.6;
        
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
                
                fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%.2f\n','young',['sub' num2str(sb)],ls_cue{ncue},name_chan,ls_time,ls_cue_cat{ncue},original_cue_list{ncue},ls_threewise{ncue},chan_mod,[name_chan(end) 'Hemi'],iaf);
                
            end
        end
    end
end

fclose(fid);