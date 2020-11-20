load ../data/yctot/stat/vlrn.sens.600.7t15.ga&stat.mat

cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = 'subtract';
diff = ft_math(cfg,frq{4},frq{3});

ix = 0 ;
figure;
for t = 0.6:0.1:1.1
    ix = ix + 1;
    
    subplot(2,3,ix)
    cfg                 = [];
    cfg.layout          = 'CTF275.lay';
    cfg.xlim            = [t t+0.1];
    
    cfg.comment         = 'no';
    cfg.ylim            = [9 13];
    cfg.zlim            = [-0.1 0.1];
    ft_topoplotTFR(cfg,diff);
    
end

for f = 7:15
    
    subplot(3,3,f-6)
    
    cfg                 = [];
    cfg.layout          = 'CTF275.lay';
    cfg.ylim            = [f f];
    cfg.zlim            = [-0.1 0.1];
    cfg.comment         = 'no';
    ft_topoplotTFR(cfg,diff)
    title([num2str(f) 'Hz']);
    
end