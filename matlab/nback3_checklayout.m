clear;

nsuj=1;

fname_in                    = ['~/Dropbox/project_me/data/nback/tf/behav2tf/sub1.1back.target.fast.mtm.mat'];
fprintf('loading %s\n',fname_in);
load(fname_in);

freq_comb.powspctrm(:)      = 0;

cfg                         = [];
cfg.layout                  = 'neuromag306cmb.lay';% 'neuromag306cmb_helmet.mat'; %'neuromag306mag.lay'; % 
cfg.marker                  = 'on';
cfg.ylim                    = [7 15];
cfg.comment                 = 'no';
cfg.colormap                = brewermap(256,'*RdBu');
cfg.colorbar                = 'no';

right_channel             	= {'MEG2232+2233','MEG2022+2023','MEG2242+2243', ... 
    'MEG2442+2443','MEG2312+2313','MEG2032+2033','MEG2432+2433','MEG2322+2323', ... 
    'MEG2342+2343','MEG2132+2133','MEG2522+2523','MEG2512+2513', ... 
    'MEG2332+2333','MEG2122+2123','MEG2532+2533','MEG2542+2543'};

left_channel                = {'MEG1842+1843','MEG1832+1833',  'MEG1912+1913','MEG1632+1633', ...
        'MEG1922+1923','MEG1942+1943','MEG1642+1643','MEG1932+1933','MEG1732+1733','MEG1722+1723', ...
        'MEG1742+1743','MEG1712+1713','MEG2012+2013','MEG2042+2043','MEG2142+2143','MEG2112+2113'};
    
cfg.highlightchannel        = right_channel;
cfg.highlight               = 'on';
cfg.highlightcolor          = [0 0 0];
cfg.highlightsize           = 10;
cfg.highlightsymbol         = 'x';

ft_topoplotTFR(cfg, freq_comb);