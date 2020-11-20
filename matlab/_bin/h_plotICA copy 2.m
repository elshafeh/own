function h_plotICA(comp,n)

comp_list                       = [
    1 20;
    21 40
    41 60
    61 80
    81 100
    101 120
    121 140];


figure;
cfg                             = [];
cfg.component                   = comp_list(n,1):comp_list(n,2);
cfg.comment                     = 'no';
cfg.marker                      = 'off';
cfg.layout                      = 'CTF275_helmet.mat';
cfg.colormap                    = brewermap(256, '*RdYlBu');
ft_topoplotIC(cfg,comp);clc;