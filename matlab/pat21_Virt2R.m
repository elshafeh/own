clear ; clc ; dleiftrip_addpath ;

txtOUT = '../txt/123.DIS.virt.400t700ms.7t10Hz.txt';
fid    = fopen(txtOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','SUB','CHAN','COND','FREQ','POW');

for sb = 1:14
    
    suj_list = [1:4 8:17];
    suj = ['yc' num2str(suj_list(sb))];
    
    cnd_list = {'S1','S2','S3'};
    
    for cnd = 1:length(cnd_list)
        
        fname_in = ['../data/tfr/' suj '.' 'DI' cnd_list{cnd} '.all.wav.1t90Hz.m1500p1500.mat'];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        cfg                 = [];
        cfg.baseline        = [-0.4 -0.2];
        cfg.baselinetype    = 'relchange';
        freq                = ft_freqbaseline(cfg,freq);
        
        tmp{1} = freq ; clear freq ;
        
        fname_in = ['../data/tfr/' suj '.'  'fDI' cnd_list{cnd} '.all.wav.1t90Hz.m1500p1500.mat'];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        cfg                 = [];
        cfg.baseline        = [-0.4 -0.2];
        cfg.baselinetype    = 'relchange';
        freq                = ft_freqbaseline(cfg,freq);
        
        tmp{2} = freq ; clear freq ;
        
        cfg                 = [];
        cfg.parameter       = 'powspctrm';
        cfg.operation       =  'x1-x2' ; % '(x1-x2)./x2'; %
        allsuj{sb,cnd}      = ft_math(cfg,tmp{1},tmp{2}); clear tmp ;
        
        cfg                             = [];
        cfg.latency                     = [0.4 0.7];
        cfg.frequency                   = [7 15];
        cfg.avgovertime                 = 'yes';
        allsuj{sb,cnd}                  = ft_selectdata(cfg,allsuj{sb,cnd});
        allsuj{sb,cnd}.powspctrm        = squeeze(allsuj{sb,cnd}.powspctrm);
        allsuj{sb,cnd}.freq             = round(allsuj{sb,cnd}.freq);
        
        for f = 1:length(allsuj{sb,cnd}.freq)
            ext_freq = [num2str(allsuj{sb,cnd}.freq(f)) 'Hz'];
            for n = 1:length(allsuj{sb,cnd}.label)
                fprintf(fid,'%s\t%s\t%s\t%s\t%.3f\n',suj,allsuj{sb,cnd}.label{n},cnd_list{cnd},ext_freq,allsuj{sb,cnd}.powspctrm(n,f));
            end
        end
        
    end
end

fclose(fid);