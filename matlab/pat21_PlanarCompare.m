clear ; clc ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    
    suj = ['yc' num2str(suj_list(sb))];
    
    ext = {'.CnD.all.wav.5t18Hz.m4p4.mat','.CnD.allPlanar.wav.5t18Hz.m3p3.mat'};
    
    for typ = 1:2
        
        fname = ['../data/' suj '/tfr/' suj ext{typ}];
        fprintf('Loading %30s\n',fname);
        load(fname);
        
        cfg                 = [];
        cfg.baseline        = [-0.4 -0.2];
        cfg.baselinetype    = 'relchange';
        allsuj_GA{sb,typ}     = ft_freqbaseline(cfg,freq);
        
        clear freq
        
    end
    
    clearvars -except allsuj_GA sb
    
end

for cnd = 1:2
    frqGA{cnd} = ft_freqgrandaverage([],allsuj_GA{:,cnd});    
end

frq_lim = [12 14];

tim_list = 0.2:0.4:2;

for a = 1:length(tim_list)
    
    cfg         = [];
    cfg.layout  = 'CTF275.lay';
    cfg.xlim    = [tim_list(a) tim_list(a)+0.2];
    cfg.ylim    = frq_lim;
    cfg.zlim    = [-0.2 0.2];
    cfg.comment = 'xlim';
    subplot(2,length(tim_list),a);
    ft_topoplotTFR(cfg,frqGA{1});
    subplot(2,length(tim_list),a+length(tim_list));
    ft_topoplotTFR(cfg,frqGA{2});
    
end
