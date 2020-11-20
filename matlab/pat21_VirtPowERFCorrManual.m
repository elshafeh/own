clear ;clc ; dleiftrip_addpath ;

load ../data/yctot/gavg/LRNnDT.pe.mat
load ../data/yctot/gavg/nDT2RChanList.mat

for sb = 1:14
    
    avg = ft_timelockgrandaverage([],allsuj{sb,:});
    cfg = []; cfg.baseline = [-0.1 0]; avg = ft_timelockbaseline(cfg,avg);
    
    for l = 1
        cfg             = [];
        
        cfg.channel     = {'MRC16', 'MRC17', 'MRC24', 'MRC25', 'MRC31', 'MRC32', 'MRF67', ...
            'MRO14', 'MRP23', 'MRP34', 'MRP35', 'MRP42', 'MRP43', 'MRP44', 'MRP45', ...
            'MRP54', 'MRP55', 'MRP56', 'MRP57', 'MRT14', 'MRT15', 'MRT16', 'MRT26'};
        cfg.latency     = [0.05 0.185];
        cfg.avgoverchan = 'yes';
        %         cfg.avgovertime = 'yes';
        slct            = ft_selectdata(cfg,avg);
        ix              = find(slct.avg == min(slct.avg));
        ERF2Corr(sb,l)  = slct.avg(ix);clear slct nw_slct ix;
    end
    
    clear avg gfp;
    
    ext         =   '.nDT.AudFrontal.VirtTimeCourse.all.wav.50t100Hz.m2000p1000.mat';
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
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
    ftap                                = 20;
    flist                               = 50;
    
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
    
    %     rtCorrMat(:,1)  = cellfun(@median,rt_all);
    %     rtCorrMat(:,2)  = cellfun(@mean,rt_all);
    
end

clearvars -except DatacorrMatrx ERF2Corr rtCorrMat

% gamma and erf 

% for erf = 1
%     [rho_rtGfp(erf),p_rtGfp(erf)]  = corr(ERF2Corr(:,erf), rtCorrMat(:,1),'type', 'Spearman');
% end

chn = 1;
erf = 1;

for f = 1:size(DatacorrMatrx,3)
    for t = 1:size(DatacorrMatrx,4)
        [rho(f,t),p(f,t)]  = corr(squeeze(DatacorrMatrx(:,chn,f,t)),ERF2Corr(:,erf), 'type', 'Spearman');
    end
end

% % mask = p < 0.1;
% % rho = rho .* mask ;

scatter(DatacorrMatrx,ERF2Corr,'filled','LineWidth',20);
h =lsline;
xlabel('Gamma Power');
ylabel('N1 Amplitude');
set(h, 'linewidth',2,'color','b')
set(gca,'fontsize',18)
set(gca,'FontWeight','bold')
ylim([-200 10]);
xlim([-0.05 0.25])