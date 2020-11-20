clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    ext         =   '.nDT.AudFrontal.VirtTimeCourse.all.wav.50t100Hz.m2000p1000.mat';
    
    fname_in    = ['../data/tfr/' suj ext];
    fprintf('\nLoading %50s \n',fname_in);
    load(fname_in)
    
    if isfield(freq,'hidden_trialinfo')
        freq = rmfield(freq,'hidden_trialinfo');
    end

    cfg                                 = [];
    cfg.baseline                        = [-1.4 -1.3];
    cfg.baselinetype                    = 'relchange';
    freq                                = ft_freqbaseline(cfg,freq);
    
    t_win                               = 0.1;
    tlist                               = 0.2;
    flist                               = 84;
    ftap                                = 100-flist;
    
    for chn = 1
        for t = 1:length(tlist)
            for f = 1:length(flist)
                
                lmt1 = find(round(freq.time,2) == round(tlist(t),2));
                lmt2 = find(round(freq.time,2) == round(tlist(t)+t_win,2));
                
                lmf1 = find(round(freq.freq) == round(flist(f)));
                lmf2 = find(round(freq.freq) == round(flist(f)+ftap));
                
                data                = squeeze(mean(freq.powspctrm(chn,lmf1:lmf2,lmt1:lmt2),3));
                data                = mean(data);
                
                DatacorrMatrx(sb,chn,f,t) = data ; clear data ;
                
            end
        end
    end

    load ../data/yctot/rt/rt_CnD_adapt.mat	
    
    rtCorrMat(:,1)  = cellfun(@median,rt_all);
    rtCorrMat(:,2)  = cellfun(@mean,rt_all);
    
end

clearvars -except DatacorrMatrx rtCorrMat

chn = 1;
rt  = 2;

for f = 1:size(DatacorrMatrx,3)
    for t = 1:size(DatacorrMatrx,4)
        [rho(f,t),p(f,t)]  = corr(squeeze(DatacorrMatrx(:,chn,f,t)),rtCorrMat(:,rt), 'type', 'Spearman');
    end
end

X   = squeeze(DatacorrMatrx(:,1,1));
Y   = rtCorrMat(:,rt);
scatter(X,Y,'filled','LineWidth',20);
h =lsline;
ylabel('Reaction Time');
xlabel('Gamma Power');
set(h, 'linewidth',2,'color','b')
set(gca,'fontsize',18)
set(gca,'FontWeight','bold')
xlim([-0.1 0.2]);

% x   =   squeeze(DatacorrMatrx(:,1,1));
% y   =   rtCorrMat(:,2);
% scatter(y,x)
% hold on
% plot(x,yCalc1)