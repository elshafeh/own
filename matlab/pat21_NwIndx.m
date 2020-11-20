clear ; clc ; dleiftrip_addpath ;

ext_mat = 'BigCov' ;

fOUT = ['../txt/' ext_mat 'arianceNewIndex.txt'];
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','SUB','COND','FREQ','TIME','POW');

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    lst_cnd     = {'R','L','N'};
    
    for cnd = 1:3
        
        ext1        =   [lst_cnd{cnd} 'CnD.MaxAudVizMotor.' ext_mat '.VirtTimeCourse'];
        fname_in    =   ['../data/tfr/' suj '.'  ext1 '.all.wav.1t20Hz.m3000p3000..mat'];
        
        fprintf('\nLoading %50s \n',fname_in); load(fname_in);
        
        freq    = rmfield(freq,'hidden_trialinfo');
        
        nw_chn  = [3 5; 4 6];
        nw_lst  = {'aud.L','aud.R'};
        
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
        
        gavg{sb,cnd}        = freq;
        
        flist = 7:15;
        ftap  = 0;
        
        for f = 1:length(flist)
            
            lmt1    = find(round(freq.time,3) == round(-0.6,3)); lmt2    = find(round(freq.time,3) == round(-0.2,3));
            
            lmf1    = find(round(freq.freq) == round(flist(f))); lmf2    = find(round(freq.freq) == round(flist(f)+ftap));
            
            dataL    = squeeze(freq.powspctrm(1,lmf1:lmf2,lmt1:lmt2));  dataL    = mean(mean(dataL));
            dataR    = squeeze(freq.powspctrm(2,lmf1:lmf2,lmt1:lmt2)); dataR    = mean(mean(dataR));
            
            bazukaBSL(1,sb,cnd,f) = dataL;
            bazukaBSL(2,sb,cnd,f) = dataR;
            
            IndxBsl(f) = (dataR-dataL) / mean([dataL dataR]); clear dataL dataR
            
        end
        
        twin  = 0.1;
        tlist = 0.6:twin:0.9;
        
        for f = 1:length(flist)
            for t = 1:length(tlist)
                
                lmt1    = find(round(freq.time,3) == round(tlist(t),3));
                lmt2    = find(round(freq.time,3) == round(tlist(t)+twin,3));
                
                lmf1    = find(round(freq.freq) == round(flist(f)));
                lmf2    = find(round(freq.freq) == round(flist(f)+ftap));
                
                dataL    = squeeze(freq.powspctrm(1,lmf1:lmf2,lmt1:lmt2));
                dataL    = mean(mean(dataL));
                
                dataR    = squeeze(freq.powspctrm(2,lmf1:lmf2,lmt1:lmt2));
                dataR    = mean(mean(dataR));
                
                indx     = (dataR-dataL) / mean([dataL dataR]);
                
                bazukaActv(1,sb,cnd,f,t) = dataL;
                bazukaActv(2,sb,cnd,f,t) = dataR;
                
                RelIndx  = indx/IndxBsl(f);
                
                fprintf(fid,'%s\t%s\t%s\t%s\t%.2f\n',suj,[lst_cnd{cnd} 'Cue'], ...
                    [num2str(round(flist(f))) 'Hz'],[num2str(round(tlist(t)*1000)) 'ms'],RelIndx);
                
                clear dataL dataR
                
            end
        end
    end
end

fclose(fid); clearvars -except bazuka* gavg;

% bazukaBSL   = squeeze(mean(bazukaBSL,4));
% bazukaActv  = squeeze(mean(squeeze(mean(bazukaActv,5)),4));
% 
% for cnd = 1:3
%     subplot(1,3,cnd)
%     boxplot([squeeze(bazukaBSL(:,:,cnd))' squeeze(bazukaActv(:,:,cnd))']/10^24);
%     ylim([0 10]);
% end

clear toPlot

for cnd = 1:2
    freq{cnd}           = ft_freqgrandaverage([],gavg{:,cnd});
    cfg                 = [];
    cfg.baseline        = [-0.6 -0.2];
    cfg.baselinetype    = 'relchange';
    freq{cnd}           = ft_freqbaseline(cfg,freq{cnd} );
    cfg                 = [];
    cfg.frequency       = [8 11];
    cfg.avgoverfreq     = 'yes';
    %     cfg.latency         = [0.6 1];
    %     cfg.avgovertime     = 'yes';
    freq{cnd}           = ft_selectdata(cfg,freq{cnd} );
    toPlot(cnd,:,:)     = freq{cnd}.powspctrm;
end

for chn = 1:2
    subplot(1,2,chn);
    plot(freq{1}.time,squeeze(toPlot(:,chn,:)),'LineWidth',5);
    xlim([-0.2 2]);
    ylim([-0.3 0.3]);
    legend({'R','L','N'});
    title(freq{1}.label{chn});
end