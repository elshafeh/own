clear ; clc ;

fOUT        = '../txt/DIS.Gamma.CueEffect.txt';
fid         = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\n','SUB','CHAN','DELAY','TIME','FREQ','POW');

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext1        =   '.AudFrontal.VirtTimeCourse.all.wav.50t100Hz.m2000p1000.mat' ;
    lst_delay   =   'NLR';
        %     lst_delay   =   '123';
    lst_dis     =   {'DIS','fDIS'};
    
    for cnd_delay = 1:length(lst_delay)
        for cnd_dis = 1:2
            
            fname_in    = ['../data/tfr/' suj '.' lst_delay(cnd_delay) lst_dis{cnd_dis} ext1];
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'hidden_trialinfo')
                freq        = rmfield(freq,'hidden_trialinfo');
            end
            
            cfg                         = [];
            cfg.channel                 = 2;
            tf_dis{cnd_dis}             = ft_selectdata(cfg,freq); clear freq ;
            
        end
        
        cfg                     = [];
        cfg.parameter           = 'powspctrm'; cfg.operation  = 'x1-x2';
        freq                    = ft_math(cfg,tf_dis{1},tf_dis{2});
        
        twin                    = 0.05;
        tlist                   = 0.1:twin:0.4;
        ftap                    = 10;
        flist                   = 50:10:90;
        
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
                    frq2print   = [num2str(round(flist(f))) 'Hz'];
                    tim2print   = [num2str(round(tlist(t),2)*1000) 'ms'];
                    
                    data2permute(sb,cnd_delay,f,t) = data ;
                    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%.2f\n',suj,freq.label{chn}, delay2print, ...
                        tim2print,frq2print,data);
                    clear data ;
                    
                end
            end
        end
    end
end

fclose(fid); clearvars -except data2permute ;

data2permute = squeeze(mean(data2permute,4));
data2permute = squeeze(mean(data2permute,3)) / 10^20;

pow          = mean(data2permute,1);
sem          = std(data2permute,1) / sqrt(14) ;

errorbar(pow,sem,'k','LineWidth',1)
% set(gca,'Xtick',0:4,'XTickLabel', {'','DIS1','DIS2','DIS3',''});
set(gca,'Xtick',0:4,'XTickLabel', {'','NCue','LCue','RCue',''});
set(gca,'fontsize',18)
set(gca,'FontWeight','bold');
ylim([0 15])