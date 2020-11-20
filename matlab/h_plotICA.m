function h_plotICA(comp,n)

comp_list                       = [
    1 20;
    21 40
    41 60
    61 80
    81 100
    101 120
    121 140
    141 160
    161 180
    181 200
    201 220
    221 240
    241 260
    261 length(comp.label)];


figure;
cfg                             = [];
cfg.component                   = comp_list(n,1):comp_list(n,2);
cfg.comment                     = 'no';
cfg.marker                      = 'off';
cfg.layout                      = 'CTF275_helmet.mat';
cfg.colormap                    = brewermap(256, '*RdYlBu');
ft_topoplotIC(cfg,comp);clc;