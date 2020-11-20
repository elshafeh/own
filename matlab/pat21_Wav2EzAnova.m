clear ; clc ; dleiftrip_addpath ;

ext_mat = 'BigCov' ;

fOUT = ['../txt/' ext_mat 'ariance.HemiByModByTimeByFreq.txt'];
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\n','SUB','COND','MODALITY','HEMI','FREQ','TIME','POW');

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    lst_cnd     = {'R','L','N'};
    
    for cnd = 1:3
        
        ext1        =   [lst_cnd{cnd} 'CnD.MaxAudVizMotor.' ext_mat '.VirtTimeCourse'];
        fname_in    =   ['../data/tfr/' suj '.'  ext1 '.all.wav.1t20Hz.m3000p3000..mat'];
        
        fprintf('\nLoading %50s \n',fname_in); load(fname_in);
        
        freq    = rmfield(freq,'hidden_trialinfo');
        
        cfg                 = []; 
        cfg.baseline        = [-0.6 -0.2]; 
        cfg.baselinetype    = 'relchange'; 
        freq                = ft_freqbaseline(cfg,freq);
        
        nw_chn  = [1 1;2 2; 3 5; 4 6];
        nw_lst  = {'occ.L','occ.R','aud.L','aud.R'};
        
        for l = 1:size(nw_chn,1)
            cfg             = [];
            cfg.channel     = nw_chn(l,:);
            cfg.avgoverchan = 'yes';
            nwfrq{l}        = ft_selectdata(cfg,freq);
            nwfrq{l}.label  = nw_lst(l);
        end
        
        cfg             = [];
        cfg.parameter   = 'powspctrm';cfg.appenddim   = 'chan';
        freq            = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
        
        flist = 7:15;
        ftap  = 0;
        twin  = 0.1;
        tlist = 0.6:twin:0.9;
        
        for chn = 1:length(freq.label)
            for f = 1:length(flist)
                for t = 1:length(tlist)
                    
                    lmt1    = find(round(freq.time,3) == round(tlist(t),3));
                    lmt2    = find(round(freq.time,3) == round(tlist(t)+twin,3));
                    
                    lmf1    = find(round(freq.freq) == round(flist(f)));
                    lmf2    = find(round(freq.freq) == round(flist(f)+ftap));
                    
                    data    = squeeze(freq.powspctrm(chn,lmf1:lmf2,lmt1:lmt2));
                    data    = mean(mean(data));
                    
                    x       = strsplit(freq.label{chn},'.');
                    
                    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%.2f\n',suj,[lst_cnd{cnd} 'Cue'],x{1},x{2}, ...
                        [num2str(round(flist(f))) 'Hz'],[num2str(round(tlist(t)*1000)) 'ms'],data);
                    
                    plotBazuka(sb,cnd,chn,f,t) = data ;
                    
                end
            end
        end
        
        clear freq
        
    end
    
end

fclose(fid) ; clearvars -except bgdata plotBazuka;