clear ; clc ;

extFreq = 'gamma';
fOUT    = ['../txt/RLN.NewBsl.nDT.' extFreq '.txt'];
fid     = fopen(fOUT,'W+');

fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\n','SUB','COND','CHAN','FREQ','TIME','POW');

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext1        =   'nDT.AudViz.VirtTimeCourse' ;
    ext2        =   'all.wav.1t90Hz.m2000p2000.mat';
    lst         =   'RLN';
    
    for cnd_cue = 1:length(lst)
        
        fname_in    = ['../data/tfr/' suj '.'  lst(cnd_cue) ext1 '.' ext2];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        if isfield(freq,'hidden_trialinfo')
            freq        = rmfield(freq,'hidden_trialinfo');
        end
        
        %         nw_chn      = [3 5; 4 6];nw_lst      = {'audL','audR'};
        nw_chn      = [4 6];nw_lst      = {'audR'};

        for l = 1:size(nw_chn,1)
            cfg             = [];cfg.channel     = nw_chn(l,:);cfg.avgoverchan = 'yes';
            nwfrq{l}        = ft_selectdata(cfg,freq);
            nwfrq{l}.label  = nw_lst(l);
        end
        
        cfg                     = [];cfg.parameter           = 'powspctrm';cfg.appenddim           = 'chan';
        freq                    = ft_appendfreq(cfg,nwfrq{:}); clear nwfrq
        
        if strcmp(extFreq,'alpha')
            bsl_period = [-0.4 -0.2];
            twin       = 0.1;
            ftap       = 0;
            flist      = 7:15;
        else
            bsl_period = [-1.4 -1.3];
            twin       = 0.02;
            ftap       = 2;
            flist      = 50:ftap:80;
        end
        
        cfg                     = [];
        cfg.baseline            = bsl_period;
        cfg.baselinetype        = 'relchange';
        freq                    = ft_freqbaseline(cfg,freq);
        
        tlist                   = 0.1:twin:0.28;
        
        fprintf('Writing In Text File\n');
        
        for chn = 1:length(freq.label)
            for f = 1:length(flist)
                for t = 1:length(tlist)
                    
                    lmt1 = find(round(freq.time,3) == round(tlist(t),3));
                    lmt2 = find(round(freq.time,3) == round(tlist(t)+twin,3));
                    
                    lmf1 = find(round(freq.freq) == round(flist(f)));
                    lmf2 = find(round(freq.freq) == round(flist(f)+ftap));
                    
                    data = squeeze(nanmean(nanmean(freq.powspctrm(chn,lmf1:lmf2,lmt1:lmt2))));
                    
                    frq2print = [num2str(round(flist(f))) 'Hz'];
                    tim2print = [num2str(round(tlist(t),3)*1000) 'ms'];
                    cnd2print = [lst(cnd_cue) 'Cue'];
                    chn2print = freq.label{chn};
                    
                    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%.2f\n',suj,cnd2print, chn2print, ... ,
                        frq2print,tim2print,data);
                    
                    data2plot(sb,cnd_cue,chn,f,t) = data ;
                    
                end
            end
        end
        
        fprintf('Done!\n');
        
    end
end

fclose(fid);

clearvars -except data2plot tlist flist

nw2plot = squeeze(mean(data2plot,5));
nw2plot = squeeze(mean(nw2plot,3));

figure;
hold on;
for cnd = 1:2
    for sb = 1:14
        xi = scatter(cnd,nw2plot(sb,cnd));
        set(xi,'linewidth',4);
    end
end
bh = boxplot(nw2plot(:,1:2),'labels',{'RCue','LCue'}); ylim([-0.3 0.3]);
set(gca,'fontsize',18)
set(gca,'FontWeight','bold')
set(bh,'linewidth',2);