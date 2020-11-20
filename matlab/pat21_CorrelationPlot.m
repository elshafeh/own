% plot sensors with significant correlation on a topoplot 

clear ; clc ;

load ../data/yctot/old/CnDtotandGavg.mat

freqCnDGavg = ft_freqgrandaverage([],allsuj_GA_bsl{:});

clear allsuj*

load('../data/yctot/CorrStatp200p700');

xi = 0;

for t = 0.2:0.1:0.6
    
    xi = xi + 1;
    
    tm1 = t;
    tm2 = t+0.1;
    
    frq_lim = [10 14];
    
    cfg         = [];
    cfg.latency = [tm1 tm2];
    cfg.frequency = frq_lim;
    tmp         = ft_selectdata(cfg,to_plot_stat);
    
    sig_chan = find_empty_channels(tmp);
    
    cfg                     = [];
    cfg.layout              = 'CTF275.lay';
    cfg.xlim                = [tm1 tm2];
    cfg.ylim                = frq_lim;
    cfg.zlim                = [-0.15 0.15];
    cfg.highlight           = 'yes';
    cfg.highlightchannel    = sig_chan;
    cfg.highlightsymbol     = '.';
    cfg.highlightcolor      = [1 0 0];
    cfg.highlightsize       = 10;
    subplot(1,5,xi);
    ft_topoplotTFR(cfg,freqCnDGavg);
    
    clear tmp sig_chan
    
end

% for t = 0.8:0.1:1.1
%     
%     xi = xi + 1;
%     
%     tm1 = t;
%     tm2 = t+0.1;
%     
%     cfg         = [];
%     cfg.latency = [tm1 tm2];
%     tmp         = ft_selectdata(cfg,to_plot_stat);
%     
%     sig_chan = find_empty_channels(tmp);
%     
%     cfg                     = [];
%     cfg.layout              = 'CTF275.lay';
%     cfg.xlim                = [tm1 tm2];
%     cfg.ylim                = [8 10];
%     cfg.zlim                = [-0.15 0.15];
%     cfg.highlight           = 'yes';
%     cfg.highlightchannel    = sig_chan;
%     cfg.highlightsymbol     = '.';
%     cfg.highlightcolor      = [1 0 0];
%     cfg.highlightsize       = 10;
%     subplot(1,4,xi);
%     ft_topoplotTFR(cfg,freqCnDGavg);
%     
%     clear tmp sig_chan
%     
% end

% cfg         = [];
% cfg.layout  = 'CTF275.lay';
% cfg.xlim    = 0.8:0.05:1.2;
% cfg.zlim = [-0.5 0.5];
% cfg.ylim = [8 10];
% figure;ft_topoplotTFR(cfg,to_plot_stat);
% cfg.zlim = [-0.1 0.1];
% figure;ft_topoplotTFR(cfg,freqCnDGavg);
% cfg.ylim = [12 14];
% cfg.zlim = [-0.5 0.5];
% figure;ft_topoplotTFR(cfg,to_plot_stat);
% cfg.zlim = [-0.1 0.1];
% figure;ft_topoplotTFR(cfg,freqCnDGavg);

% frq.label = to_plot_stat.label;
% frq.dimord = to_plot_stat.dimord;
% 
% 
% clear to_plot_stat;
% 
% stat.mask = stat.prob < 0.1;
% 
% pow1 = stat.rho .* stat.mask;
% 
% clear stat
% 
% load('../data/yctot/CorrStatp800p1200');
% 
% clear to_plot_stat;
% 
% pow2 = stat.rho .* stat.mask;
% 
% clear stat
% 
% tpow = zeros(275,9,20);
% 
% tpow(1:275,1:9,1:11) = pow1;
% tpow(1:275,1:9,12:20) = pow2;
% 
% frq.powspctrm = tpow;
% frq.time      = 0.2:0.05:1.15;
% frq.freq      = 7:15;
% 
% cfg         = [];
% cfg.layout  = 'CTF275.lay';
% cfg.zlim    = [-1 1];
% ft_multiplotTFR(cfg,frq);
% 
% cfg = [];
% cfg.layout = 'CTF275.lay';
% cfg.xlim = 0.2:0.1:1.1;
% cfg.zlim = [-1 1];
% cfg.ylim = [7 15];
% ft_topoplotTFR(cfg,frq);
% % figure;
% % cfg.ylim = [12 14];
% % ft_topoplotTFR(cfg,frq);
