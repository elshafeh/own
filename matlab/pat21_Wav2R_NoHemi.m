clear ; clc ; dleiftrip_addpath ;

ext_mat = 'BigCov' ;

fOUT = ['../txt/TargetGamma.NoHemi.txt'];
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\n','SUB','COND','ROI','FREQ','TIME','POW');

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    lst_cnd     = {'R','L','N'};
    
    for cnd = 1:3
        
        ext1        =   [lst_cnd{cnd} 'nDT.AudFrontal.VirtTimeCourse.all.wav.50t100Hz.m2000p1000.mat'];
        fname_in    =   ['../data/tfr/' suj '.'  ext1];
        
        fprintf('\nLoading %50s \n',fname_in); load(fname_in);
        
        if isfield(freq,'hidden_trialinfo')
            freq    = rmfield(freq,'hidden_trialinfo');
        end
        
        %         nw_chn  = [3 3; 4 4;5 5; 6 6];
        %         nw_lst  = {'Hesh.L','Hesh.R','STG.L','STG.R'};

        nw_chn  = [1 1];
        nw_lst  = {'aud.R'};
        
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
        
        cfg                 = [];
        cfg.baseline        = [-1.4 -1.3];
        cfg.baselinetype    = 'relchange';
        freq                = ft_freqbaseline(cfg,freq);
        
        ftap  = 4;
        flist = 50:ftap:96;
        twin  = 0.05;
        tlist = 0.1:twin:0.25;
        
        for chn = 1:length(freq.label)
            for f = 1:length(flist)
                for t = 1:length(tlist)
                    
                    lmt1    = find(round(freq.time,3) == round(tlist(t),3));
                    lmt2    = find(round(freq.time,3) == round(tlist(t)+twin,3));
                    
                    lmf1    = find(round(freq.freq) == round(flist(f)));
                    lmf2    = find(round(freq.freq) == round(flist(f)+ftap));
                    
                    data    = squeeze(freq.powspctrm(chn,lmf1:lmf2,lmt1:lmt2));
                    data    = mean(mean(data));
                    
                    x       = strsplit(freq.label{chn},'.');
                    
                    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%.2f\n',suj,[lst_cnd{cnd} 'Cue'],freq.label{chn}, ...
                        [num2str(round(flist(f))) 'Hz'],[num2str(round(tlist(t)*1000)) 'ms'],data);
                    
                    plotBazuka(sb,cnd,chn,f,t) = data ;
                    
                end
            end
        end
        
        clear freq
        
    end
end

fclose(fid) ; clearvars -except bgdata plotBazuka;

plotBazuka = squeeze(plotBazuka);
plotBazuka = squeeze(mean(plotBazuka,4));
plotBazuka = squeeze(mean(plotBazuka,3));

pow = mean(plotBazuka,1);
sem = std(plotBazuka,1)/sqrt(14);

figure;
errorbar(pow,sem,'k','LineWidth',1)
set(gca,'Xtick',0:4,'XTickLabel', {'','RCue','LCue','NCue',''});
set(gca,'fontsize',18)
set(gca,'FontWeight','bold');
ylim([0 0.1]);