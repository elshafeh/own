clear ; clc ; dleiftrip_addpath ;

ext_mat = 'BigCov' ;

fOUT = ['../txt/' ext_mat 'ariance.HemiByModByTimeByFreq.Correlation.txt'];
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\n','SUB','COND','MODALITY','HEMI','FREQ','TIME','CORR');

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext1        =   ['CnD.MaxAudVizMotor.' ext_mat '.VirtTimeCourse'];
    fname_in    =   ['../data/tfr/' suj '.'  ext1 '.KeepTrial.wav.1t20Hz.m3000p3000..mat'];
    fprintf('\nLoading %50s \n',fname_in); load(fname_in);
    freq    = rmfield(freq,'hidden_trialinfo');
    cfg                 = []; cfg.baseline        = [-0.6 -0.2]; cfg.baselinetype    = 'relchange'; freq                = ft_freqbaseline(cfg,freq);
    
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
    
    flist       = 7:15;
    ftap        = 0;
    twin        = 0.1;
    tlist       = 0.6:twin:1;
    
    lst_cnd     = {'R','L','N'};
    
    load ../data/yctot/rt/rt_cond_classified.mat
    
    for chn = 1:length(freq.label)
        for f = 1:length(flist)
            for t = 1:length(tlist)
                
                lmt1    = find(round(freq.time,3) == round(tlist(t),3));
                lmt2    = find(round(freq.time,3) == round(tlist(t)+twin,3));
                
                lmf1    = find(round(freq.freq) == round(flist(f)));
                lmf2    = find(round(freq.freq) == round(flist(f)+ftap));
                
                data    = squeeze(freq.powspctrm(:,chn,lmf1:lmf2,lmt1:lmt2));
                data    = mean(data,2);
                
                for cnd = 1:3
                    
                    sb_data     = data(rt_indx{sb,cnd});
                    [rho,p]     = corr(sb_data,rt_classified{sb,cnd} , 'type', 'Spearman');
                    rhoF        = .5.*log((1+rho)./(1-rho));
                    
                    x       = strsplit(freq.label{chn},'.');
                    
                    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%.2f\n',suj,[lst_cnd{cnd} 'Cue'],x{1},x{2}, ...
                        [num2str(round(flist(f))) 'Hz'],[num2str(round(tlist(t)*1000)) 'ms'],rhoF);
                    
                    plotBazuka(sb,cnd,chn,f,t) = rhoF ;
                    
                end
            end
        end
    end
    
end

fclose(fid) ; clearvars -except bgdata plotBazuka;

lst_chan = {'Occipital.Left','Occipital.Right','Auditory.Left','Auditory.Right'};
lst_freq = 7:15;
i = 0 ;
for chn = [1 3 2 4]
    
    i = i +1;
    
    subplot(2,2,i)
    hold on
    
    for cnd = 1:3
        dta   = squeeze(plotBazuka(:,cnd,chn,:,:));
        dta   = squeeze(mean(dta,1));
        dta   = squeeze(mean(dta,2));
        plot(dta,'--s','LineWidth',4,'MarkerSize',6);
    end
    
    set(gca,'Xtick',0:1:10)
    xlim([0 10])
    ylim([-0.1 0.1])
    set(gca,'Xtick',0:10,'XTickLabel', {'','7Hz','8Hz','9Hz','10Hz','11Hz','12Hz','13Hz','14Hz','15Hz',''})  
    legend({'RCue','LCue','NCue'}, 'Location', 'Northeast')
    hline(0,'--k');
    title(lst_chan{chn});
    set(findall(gcf,'-property','FontSize'),'FontSize',14)
end

lst_chan = {'Occipital.Left','Occipital.Right','Auditory.Left','Auditory.Right'};
lst_freq = 7:15;
i = 0 ;

nw_list = [1 3; 2 4];
nwnw    = {'Left hemisphere','Right Hemisphere'};
figure;
for k = 1:2
    subplot(1,2,k)
    hold on;
    for cnd = 1:3
        dta   = squeeze(plotBazuka(:,cnd,nw_list(k,:),:,:));
        dta   = squeeze(mean(dta,1));
        dta   = squeeze(mean(dta,3));
        dta   = squeeze(mean(dta,1));
        plot(dta,'--s','LineWidth',4,'MarkerSize',6);
    end
    set(gca,'Xtick',0:1:10)
    xlim([0 10])
    ylim([-0.1 0.1])
    set(gca,'Xtick',0:10,'XTickLabel', {'','7Hz','8Hz','9Hz','10Hz','11Hz','12Hz','13Hz','14Hz','15Hz',''})  
    
    legend({'RCue','LCue','NCue'}, 'Location', 'Northeast')
    hline(0,'--k');
    title(nwnw{k});
    set(findall(gcf,'-property','FontSize'),'FontSize',14)
    
end

