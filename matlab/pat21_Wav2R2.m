clear ; clc ; dleiftrip_addpath ;

fOUT = '../txt/SmallCovariance.NoHemi.2taper.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','SUB','COND','MODALITY','FREQ','POW');

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    lst_cnd     = {'R','L','N'};
    
    for cnd = 1:3
        
        ext1        =   [lst_cnd{cnd} 'CnD.MaxAudVizMotor.SmallCov.VirtTimeCourse'];
        fname_in    =   ['../data/tfr/' suj '.'  ext1 '.all.wav.1t20Hz.m3000p3000..mat'];
        
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        freq    = rmfield(freq,'hidden_trialinfo');
        
        cfg                 = [];
        cfg.baseline        = [-0.6 -0.2];
        cfg.baselinetype    = 'relchange';
        freq                = ft_freqbaseline(cfg,freq);
        
        nw_chn  = [1 1;2 2; 3 5; 4 6;];  
        nw_lst  = {'occL','occR','audL','audR'};
        
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
        
        %         flist = 7:15;
        %         ftap  = 0;
        %
        %         for f = 1:length(flist)
        %             cfg             = [];
        %             cfg.frequency   = [flist(f)-ftap flist(f)+ftap];
        %             cfg.avgoverfreq  = 'yes';
        %             nwfrq{f}        = ft_selectdata(cfg,freq);
        %         end
        %
        %         cfg             = [];
        %         cfg.parameter   = 'powspctrm';cfg.appenddim   = 'freq';
        %         freq            = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
        
        cfg             = [];
        cfg.latency     = [0.6 1];
        cfg.frequency   = [9 13];
        cfg.avgoverfreq = 'yes';
        cfg.avgovertime = 'yes';
        freq            = ft_selectdata(cfg,freq);
        
        for chn = 1:length(freq.label)
            for f = 1:length(freq.freq)
                
                bgdata(sb,cnd,chn,f) = squeeze(freq.powspctrm(chn,f,:));
                
                fprintf(fid,'%s\t%s\t%s\t%s\t%.2f\n',suj,[lst_cnd{cnd} 'Cue'],freq.label{chn}, ...
                    [num2str(round(freq.freq(f))) 'Hz'],bgdata(sb,cnd,chn,f));
                
            end
        end
        
        clear freq
        
    end
    
end

fclose(fid) ; clearvars -except bgdata ;