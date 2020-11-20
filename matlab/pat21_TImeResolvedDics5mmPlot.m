clear ; clc ; close all;

for sb = 1:14

    cue = 'NCnD' ;
    f   = 1;
    
    load ../data/yc1/source/yc1.pt1.CnD.all.mtmfft.8t10Hz.m600m200.bsl.5mm.source.mat
    load ../data/yc1/headfield/yc1.VolGrid.5mm.mat ; clc ;
    
    template_source = source ; clear source
    
    template_source = rmfield(template_source,'avg');
    template_source = rmfield(template_source,'cumtapcnt');
    template_source = rmfield(template_source,'freq');
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    load(['../data/' suj '/source/' suj '.' cue '.tfResolved.9&13Hz.m700p1200ms.mat']);
    
    lm1 = find(round(tResolvedAvg.time,2) == -0.6);
    lm2 = find(round(tResolvedAvg.time,2) == -0.2);
    
    bsl = squeeze(mean(tResolvedAvg.pow(:,f,lm1:lm2),3));
    
    for t = 1:length(tResolvedAvg.time)
        
        tResolvedAvg.pow(:,f,t) = (tResolvedAvg.pow(:,f,t) - bsl) ./ bsl ;
        
        source_avg{sb,t}.pow        = squeeze(tResolvedAvg.pow(:,f,t));
        source_avg{sb,t}.pos        = grid.MNI_pos;
        source_avg{sb,t}.dim        = template_source.dim;
        source_avg{sb,t}.insdie     = template_source.inside;
        
    end
    
    clearvars -except source_avg sb cue
    
end

tim_list = -0.7:0.1:1.2;

for t = 10:20
    
    sGavg{t}            = ft_sourcegrandaverage([],source_avg{:,t});
    sGavg{t}.cfg        = [];
    sGavg_int{t}        = h_interpolate(sGavg{t});
    sGavg_int{t}.cfg    = [];
    
    cfg                     = [];
    cfg.method              = 'slice';
    cfg.funparameter        = 'pow';
    cfg.nslices             = 1;
    cfg.slicerange          = [70 84];
    cfg.funcolorlim         = [-0.1 0.1];
    ft_sourceplot(cfg,sGavg_int{t});clc;
    title([num2str(round(tim_list(t),2)*1000) 'ms']);
    
    %     if t < 10
    %         saveFigure(gcf,['../plots/tresolved/highfreq/gavg.0' num2str(t) '.' num2str(round(tim_list(t),2)*1000) 'ms.png']);
    %     else
    %         saveFigure(gcf,['../plots/tresolved/highfreq/gavg.' num2str(t) '.' num2str(round(tim_list(t),2)*1000) 'ms.png']);
    %     end
    %
    %     close all
    
end