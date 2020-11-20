clear ; clc ; dleiftrip_addpath ;

ftap = 2;
fOUT = ['../txt/BigCovariance.NewIAFAdapted' num2str(ftap) 'taper.txt'];
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\n','SUB','COND','MODALITY','HEMI','TIME','POW');

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    lst_cnd     = {'R','L','N'};
    
    for cnd = 1:3
        
        ext1        =   [lst_cnd{cnd} 'CnD.MaxAudVizMotor.BigCov.VirtTimeCourse'];
        fname_in    =   ['../data/tfr/' suj '.'  ext1 '.all.wav.NewEvoked.1t20Hz.m3000p3000.mat'];
        
        fprintf('\nLoading %50s \n',fname_in); load(fname_in);
        
        nw_chn  = [1 1;2 2; 3 5; 4 6];
        nw_lst  = {'occ.L','occ.R','aud.L','aud.R'};
        
        cfg                 = [];
        cfg.baseline        = [-0.6 -0.2];
        cfg.baselinetype    = 'relchange';
        freq                = ft_freqbaseline(cfg,freq);
        
        tend                = 1.2;
        
        [freq, iaf] = iafdapt(freq,nw_chn,nw_lst,[0.6 tend],[7 15]); clc ;
        
        iaf2plot(sb,cnd,:) = iaf';
        
        twin        = 0.1;
        tlist       = 0.6:twin:(tend-twin);
        
        for chn = 1:length(freq.label)
            for t = 1:length(tlist)
                
                lmt1    = find(round(freq.time,3) == round(tlist(t),3));
                lmt2    = find(round(freq.time,3) == round(tlist(t)+twin,3));
                
                lmf1    = find(round(freq.freq) == round(iaf(chn)-ftap));
                lmf2    = find(round(freq.freq) == round(iaf(chn)+ftap));
                
                data    = squeeze(freq.powspctrm(chn,lmf1:lmf2,lmt1:lmt2));
                data    = mean(mean(data));
                
                x       = strsplit(freq.label{chn},'.');
                
                fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%.2f\n',suj,[lst_cnd{cnd} 'Cue'],x{1},x{2}, ...
                    [num2str(round(tlist(t)*1000)) 'ms'],data);
                
            end
        end
        
        clear freq
        
    end
end

fclose(fid); clearvars  -except iaf2plot

plot(squeeze(mean(iaf2plot,1))');ylim([7 15]);
set(gca,'Xtick',0:6,'XTickLabel', {'','occ.L','occ.R','aud.L','aud.R',''});legend({'R','L','N'});
xlim([-1 7]);