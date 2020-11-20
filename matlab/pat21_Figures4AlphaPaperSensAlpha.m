% Sensor Level %

clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/gavg/CnD5t18.mat
load ../data/yctot/stat/ActvBaseline4Neigh7t15Hz200t2000ms.mat

freq            = frqGA ; clear frqGA ;

[min_p , p_val] = h_pValSort(stat) ; 
stat2plot       = h_plotStat(stat,0.00000000000001,0.05);

time_list       = [0.2 0.6];

i = 0 ;

figure;

for f = [9 13]
    for t = 1:length(time_list)
        
        ftap        = 2;
        twin        = 0.4 ;
        ix_f1       = find(round(stat2plot.freq) == round(f-ftap));
        ix_f2       = find(round(stat2plot.freq) == round(f+ftap));
        ix_t1       = find(round(stat2plot.time,2) == round(time_list(t),2));
        ix_t2       = find(round(stat2plot.time,2) == round(time_list(t)+twin,2));
        ix_chn      = [];
        
        substat     = abs(stat2plot.powspctrm(:,ix_f1:ix_f2,ix_t1:ix_t2));
        
        for hoho = 1:size(substat,1)
            hihi  = squeeze(substat(hoho,:,:));
            [x,y] = find(hihi == 0);
            if length(x) < 20
                ix_chn = [ix_chn hoho];
            end
        end
        
        substat     = squeeze(mean(substat,2));
        substat     = mean(substat,2);
        ix_chn      = find(substat > 0.5);
        i           = i +1 ;
        
        cfg                     = [];
        cfg.layout              = 'CTF275.lay' ;
        cfg.xlim                = [time_list(t) time_list(t)+twin];
        cfg.ylim                = [f-ftap f+ftap] ;
        cfg.zlim                = [-0.2 0.2] ;
        cfg.highlight           = 'on';
        cfg.highlightchannel    =  ix_chn;
        cfg.highlightsymbol     = '.';
        cfg.highlightcolor      = [0 0 0];
        cfg.highlightsize       = 15;
        cfg.comment             = 'no';
        cfg.marker              = 'off';
        cfg.colorbar            = 'no';
        
        subplot(2,3,i)
        ft_topoplotTFR(cfg,freq) ;
        
    end
end

figure;

lst{1}= {'MLC13', 'MLC14', 'MLC15', 'MLC16', 'MLC17', 'MLC22', 'MLC23', ...
    'MLC24', 'MLC25', 'MLC31', 'MLC32', 'MLC41', 'MLC42', 'MLF46', 'MLF55', ...
    'MLF56', 'MLF64', 'MLF65', 'MLF66', 'MLF67', 'MLP12', 'MLP23', 'MLP33', ...
    'MLP34', 'MLP35', 'MLP44', 'MLP45', 'MLP56', 'MLP57', 'MLT11', 'MLT12', ...
    'MLT13', 'MLT14', 'MLT15', 'MLT22', 'MLT23', 'MLT24', 'MLT32', 'MLT33', 'MLT34'};

lst{2} = {'MLO11', 'MLO12', 'MLO13', 'MLO14', 'MLO21', 'MLO22', 'MLO23', ...
    'MLO24', 'MLO31', 'MLO32', 'MLO33', 'MLO34', 'MLO41', ...
    'MLO42', 'MLO43', 'MLO44', 'MLO51', 'MLO52', 'MLO53', ...
    'MLP51', 'MLP52', 'MLP53', 'MRO11', 'MRO12', 'MRO13', ...
    'MRO21', 'MRO22', 'MRO23', 'MRO24', 'MRO31', 'MRO32', ...
    'MRO33', 'MRO41', 'MRO42', 'MRO43', 'MRO52', 'MRP51', ...
    'MRP52', 'MRP53'};

cfg_plot            = [];
cfg_plot.zlim       = [-0.2 0.2];
cfg_plot.colorbar   = 'no';
subplot(2,1,1);
ft_singleplotTFR(cfg,freq);title('');
h_Statcontour(stat,freq,h_indx_tf_labels(lst{1}),cfg_plot)
hline(9,'k-','');hline(13,'k-','');vline(0,'k--','');
xlim([-0.2 1.2]);ylim([7 15]);

cfg_plot            = [];
cfg_plot.zlim       = [-0.2 0.2];
cfg_plot.colorbar   = 'no';
subplot(2,1,2);
ft_singleplotTFR(cfg,freq);title('');
h_Statcontour(stat,freq,h_indx_tf_labels(lst{2}),cfg_plot)
hline(9,'k-','');hline(13,'k-','');vline(0,'k--','');
xlim([-0.2 1.2]);ylim([7 15]);