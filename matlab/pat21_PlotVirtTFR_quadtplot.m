clear; clc ; dleiftrip_addpath ;

extFreq = 'alpha';
fOUT    = ['../txt/LRN.CueByDelay.DIS.' extFreq '.txt'];
fid     = fopen(fOUT,'W+');

fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\n','SUB','CHAN','CUE','DIS','FREQ','TIME','POW');

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    cnd_list    = {'DIS','fDIS'};
    lst_cue     = 'LRN';
    lst_dis     = '123';
    
    
    for cnd_cue = 1:3
        for cnd_dis = 1:3
            for cnd = 1:2
                
                ext_file = '.AudViz.VirtTimeCourse.KeepTrial.wav.1t90Hz.m2000p2000.mat';
                fname    = ['../data/tfr/' suj '.' lst_cue(cnd_cue) cnd_list{cnd} lst_dis(cnd_dis) ext_file];
                fprintf('Loading %s\n',fname);
                load(fname);
                
                if isfield(freq,'hidden_trialinfo')
                    freq        = rmfield(freq,'hidden_trialinfo');
                end
                
                cfg             = [];
                cfg.avgoverrpt  = 'yes';
                freq            = ft_selectdata(cfg,freq);
                
                nw_chn      = [1 1; 2 2; 3 5;4 6];nw_lst      = {'occL','occR','audL','audR'};
                
                for l = 1:4
                    cfg             = [];cfg.channel     = nw_chn(l,:);cfg.avgoverchan = 'yes';
                    nwfrq{l}        = ft_selectdata(cfg,freq);
                    nwfrq{l}.label  = nw_lst(l);
                end
                
                cfg                 = [];cfg.parameter           = 'powspctrm';cfg.appenddim           = 'chan';
                tmp{cnd}            = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
            end
            
            cfg                 = [];
            cfg.parameter       = 'powspctrm'; cfg.operation  = 'x1-x2';
            freq                = ft_math(cfg,tmp{1},tmp{2}); clear tmp ;
            
            twin                = 0.1;
            tlist               = 0.3:twin:0.5;
            ftap                = 0;
            flist               = 7:15;
            
            for chn = 1:length(freq.label)
                for f = 1:length(flist)
                    for t = 1:length(tlist)
                        
                        lmt1                                    = find(round(freq.time,3) == round(tlist(t),3));
                        lmt2                                    = find(round(freq.time,3) == round(tlist(t)+twin,3));
                        
                        lmf1                                    = find(round(freq.freq) == round(flist(f)));
                        lmf2                                    = find(round(freq.freq) == round(flist(f)+ftap));
                        data                                    = squeeze(mean(mean(freq.powspctrm(chn,lmf1:lmf2,lmt1:lmt2))));
                        
                        frq2print = [num2str(round(flist(f))) 'Hz'];
                        tim2print = [num2str(round(tlist(t),3)*1000) 'ms'];
                        chn2print = freq.label{chn};
                        
                        fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%.2f\n',suj,chn2print,[lst_cue(cnd_cue) 'Cue'], ...
                            ['D' lst_dis(cnd_dis)],frq2print,tim2print,data);
                        
                        data2plot(sb,chn,cnd_cue,cnd_dis,f,t) = data ;
                        
                    end
                end
            end
            
            clear freq;
        end
    end
end

fclose(fid);

clearvars -except data2plot ;
avgData2plot = squeeze(mean(squeeze(mean(squeeze(mean(data2plot,6)),5)),1));

for chn = 1:4
    subplot(2,2,chn)
    hold on
    plot(squeeze(avgData2plot(chn,1,:)),'b');
    plot(squeeze(avgData2plot(chn,2,:)),'r');
    plot(squeeze(avgData2plot(chn,3,:)),'g');
    %     ylim([-1.5*10^21 5*10^21])
    set(gca,'Xtick',0:1:5);
    xlim([0 4])
    set(gca,'Xtick',0:5,'XTickLabel', {'','DIS1','DIS2','DIS3',''})
    legend({'L','R','N'}, 'Location', 'Northeast')
end