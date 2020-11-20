clear ; clc ; dleiftrip_addpath ;

ext_mat = 'SmallCov' ;

fOUT = ['../txt/' ext_mat 'ariance.IndxByModalityByFreqByTimeBaseline.txt'];
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','SUB','COND','FREQ','TIME','POW');

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
        
        nw_chn  = [3 5; 4 6];
        nw_lst  = {'aud.L','aud.R'};
        
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
        
        for f = 1:length(flist)
            for t = 1:length(tlist)
                
                lmt1    = find(round(freq.time,3) == round(tlist(t),3));
                lmt2    = find(round(freq.time,3) == round(tlist(t)+twin,3));
                
                lmf1    = find(round(freq.freq) == round(flist(f)));
                lmf2    = find(round(freq.freq) == round(flist(f)+ftap));
                
                dataL    = squeeze(freq.powspctrm(1,lmf1:lmf2,lmt1:lmt2));
                dataL    = mean(mean(dataL));
                
                dataR    = squeeze(freq.powspctrm(2,lmf1:lmf2,lmt1:lmt2));
                dataR    = mean(mean(dataR));
                
                indx     = (dataR-dataL) / mean([dataL dataR]);
                
                fprintf(fid,'%s\t%s\t%s\t%s\t%.2f\n',suj,[lst_cnd{cnd} 'Cue'], ...
                    [num2str(round(flist(f))) 'Hz'],[num2str(round(tlist(t)*1000)) 'ms'],indx);
                
                bazuka(1,sb,cnd,f,t) = dataL;
                bazuka(2,sb,cnd,f,t) = dataR;

                
            end
        end
    end
    
    clear freq
    
end

fclose(fid);

bazuka = squeeze(mean(bazuka,5));
bazuka = squeeze(mean(bazuka,4));

bg = [];

for cnd = 1:3
    subplot(1,3,cnd)
    boxplot(squeeze(bazuka(:,:,cnd))');
end