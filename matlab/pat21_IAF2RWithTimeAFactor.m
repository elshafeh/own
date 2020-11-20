clear ; clc ; dleiftrip_addpath ;

ext_mat = 'BigCov' ;

fOUT    = ['../txt/' ext_mat 'ariance.HemiByModByTimeByFreq.IAFWithMotorWithTimeFacotr.txt'];
fid     = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','SUB','MODALITY','HEMI','TIME','VAL');

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext1        =   'CnD.MaxAudVizMotor.SmallCov.VirtTimeCourse';
    fname_in    =   ['../data/tfr/' suj '.'  ext1 '.all.wav.1t20Hz.m3000p3000..mat'];
    
    fprintf('\nLoading %50s \n',fname_in); load(fname_in); freq        = rmfield(freq,'hidden_trialinfo');
    
    cfg                 = [];
    cfg.baseline        = [-0.6 -0.2]; cfg.baselinetype    = 'relchange'; freq                = ft_freqbaseline(cfg,freq);
    
    nw_chn              = [1 1;2 2;3 5; 4 6; 7 7; 8 8];
    nw_lst              = {'occ.L','occ.R','aud.L','aud.R','Mot.L','Mot.R'};
    
    for l = 1:size(nw_chn,1)
        cfg             = [];
        cfg.channel     = nw_chn(l,:);
        cfg.avgoverchan = 'yes';
        nwfrq{l}        = ft_selectdata(cfg,freq);
        nwfrq{l}.label  = nw_lst(l);
    end
    
    cfg             = []; cfg.parameter   = 'powspctrm';cfg.appenddim   = 'chan'; freq            = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
    
    cfg             = [];
    cfg.frequency   = [7 15];
    freq            = ft_selectdata(cfg,freq);
    
    tlist = [0.2 0.6 1.4];
    tcndlist = {'early','late','post'};
    
    for t = 1:length(tlist)
        
        cfg             = [];
        cfg.latency     = [tlist(t) tlist(t)+0.4];
        cfg.avgovertime = 'yes';
        nw_freq         = ft_selectdata(cfg,freq);
        
        for chn = 1:length(nw_freq.label)
            
            
            data = squeeze(nw_freq.powspctrm(chn,:));
            if chn < 3;val = find(data == max(data));else val = find(data == min(data));end
            
            iaf     = round(nw_freq.freq(val));
            
            x       = strsplit(freq.label{chn},'.');
            fprintf(fid,'%s\t%s\t%s\t%s\t%.2f\n',suj,x{1},x{2},tcndlist{t},iaf);
            
        end
    end
end

fclose(fid);