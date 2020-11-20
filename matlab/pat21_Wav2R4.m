clear ; clc ; dleiftrip_addpath ;

fOUT = '../txt/SmallCovariance.FreqIsRoiDependent.2taper.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\n','SUB','COND','CHAN','POW');

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    lst_cnd     = {'R','L','N'};
    
    for cnd = 1:3
        
        ext1        =   [lst_cnd{cnd} 'CnD.MaxAudVizMotor.SmallCov.VirtTimeCourse'];
        fname_in    =   ['../data/tfr/' suj '.'  ext1 '.all.wav.1t20Hz.m3000p3000..mat'];
        
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        freq                = rmfield(freq,'hidden_trialinfo');
        
        cfg                 = [];
        cfg.baseline        = [-0.6 -0.2];
        cfg.baselinetype    = 'relchange';
        freq                = ft_freqbaseline(cfg,freq);
        
        nw_chn      = [1 1;2 2;3 5; 4 6];
        nw_lst      = {'occ.L','occ.R','aud.L','aud.R'};
        nw_frq      = [11 15; 11 15; 7 11; 7 11];
        
        for l = 1:size(nw_chn,1)
            
            cfg             = [];
            cfg.latency     = [0.6 1];
            cfg.avgovertime = 'yes';
            cfg.frequency   = [nw_frq(l,1) nw_frq(l,2)];
            cfg.avgoverfreq = 'yes';
            cfg.channel     = nw_chn(l,:);
            cfg.avgoverchan = 'yes';
            nwfrq{l}        = ft_selectdata(cfg,freq);
            
            fprintf(fid,'%s\t%s\t%s\t%.2f\n',suj,[lst_cnd{cnd} 'Cue'],nw_lst{l}, ...
                nwfrq{l}.powspctrm);
            
        end
        
    end
    
end

fclose(fid) ; clear ; 