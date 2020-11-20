clear ; clc ;

extfreqtime = 'late';
fOUT        = ['../txt/DIS.CueByDelay.Gamma.' extfreqtime '.PreCueCorrection.txt'];
fid         = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\n','SUB','CUE','DELAY','POW');

for a = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(a))];
    
    ext1        =   'AudViz.VirtTimeCourse.KeepTrial.wav' ;
    ext2        =   '1t90Hz.m2000p2000.mat';
    lst_delay   =   '123';
    lst_cue     =   'RLN';
    lst_dis     =   {'DIS','fDIS'};
    
    for cnd_cue = 1:length(lst_cue)
        for cnd_delay = 1:length(lst_delay)
            for cnd_dis = 1:2
                
                fname_in    = ['../data/tfr/' suj '.' lst_cue(cnd_cue) lst_dis{cnd_dis} lst_delay(cnd_delay) '.' ext1 '.' ext2];
                fprintf('\nLoading %50s \n',fname_in);
                load(fname_in)
                
                if isfield(freq,'hidden_trialinfo')
                    freq        = rmfield(freq,'hidden_trialinfo');
                end
                
                cfg             = [];
                cfg.avgoverrpt  = 'yes';
                freq            = ft_selectdata(cfg,freq);
                
                nw_chn      = [4 6];nw_lst      = {'audR'};
                
                for l = 1:length(nw_lst)
                    cfg             = [];cfg.channel     = nw_chn(l,:);cfg.avgoverchan = 'yes';
                    nwfrq{l}        = ft_selectdata(cfg,freq);
                    nwfrq{l}.label  = nw_lst(l);
                end
                
                cfg                     = [];cfg.parameter           = 'powspctrm';cfg.appenddim           = 'chan';
                tf_dis{cnd_dis}         = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
                
                cfg                     = [];
                cfg.baseline            = [-0.9 -0.8];
                cfg.baselinetype        = 'relchange';
                tf_dis{cnd_dis}         = ft_freqbaseline(cfg,tf_dis{cnd_dis});
                
            end
            
            
            cfg                     = [];
            cfg.parameter           = 'powspctrm'; cfg.operation  = 'x1-x2';
            freq                    = ft_math(cfg,tf_dis{1},tf_dis{2});
            
            if strcmp(extfreqtime,'early')
                twin                    = 0.15;
                tlist                   = 0.1;
                ftap                    = 15;
                flist                   = 55;
            else
                twin                    = 0.1;
                tlist                   = 0.35;
                ftap                    = 30;
                flist                   = 60;
            end
            
            fprintf('Writing In Text File\n');
            
            for chn = 1:length(freq.label)
                for f = 1:length(flist)
                    for t = 1:length(tlist)
                        
                        lmt1 = find(round(freq.time,3) == round(tlist(t),3));
                        lmt2 = find(round(freq.time,3) == round(tlist(t)+twin,3));
                        
                        lmf1 = find(round(freq.freq) == round(flist(f)));
                        lmf2 = find(round(freq.freq) == round(flist(f)+ftap));
                        
                        data = squeeze(mean(mean(freq.powspctrm(chn,lmf1:lmf2,lmt1:lmt2))));
                        
                        delay2print = ['D' lst_delay(cnd_delay)];
                        cue2print   = [lst_cue(cnd_cue) 'Cue'];
                        
                        fprintf(fid,'%s\t%s\t%s\t%.2f\n',suj,cue2print, delay2print, ... ,
                            data);
                        
                    end
                end
            end
        end
    end
end

fclose(fid);