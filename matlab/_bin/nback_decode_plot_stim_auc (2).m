clear;

load decode_stim_mtrx.mat;
load ../data/decode_data/stim/alldata.stim.decode.auc.mat;
load stim_times_axes.mat

scores                  = squeeze(mean(scores,1));

lm1                     = find(round(time_axes,3) == round(0.1,3));
lm2                     = find(round(time_axes,3) == round(0.4,3));

scores                  = mean(scores(:,lm1:lm2),2);

matrx_to_plot           = nan(10,10);

for nt = 1:length(test_done)
    
    x                   = test_done(nt,1);
    y                   = test_done(nt,2);
    
    matrx_to_plot(x,y)  = scores(nt);
    
end

for x = 1:size(matrx_to_plot,1)
    for y = 1:size(matrx_to_plot,2)
        
        if x == y
            matrx_to_plot(x,y)             = NaN;
        end
        
        %         for n = 1:size(matrx_to_plot,1)
        %             if n > x
        %                 matrx_to_plot(x,n)         = NaN;
        %             end
        %         end
        
    end
end

keep matrx_to_plot

freq                    = [];
freq.freq               = 1:10;
freq.time               = 1:10;
freq.label              = {'stim'};
freq.powspctrm(1,:,:)   = matrx_to_plot;

% imagesc(1:10,1:10,matrx_to_plot,z_lim);

cfg                     = [];
cfg.zlim                = [0.5 0.6];
ft_singleplotTFR(cfg,freq);
colormap(brewermap(256, '*Spectral'));
title('');

set(gca,'FontSize',16);

c                        = colorbar;
c.Ticks                  = cfg.zlim ;

xticks(1:10)
yticks(1:10)

xticklabels({'B' 'X' 'F' 'R' 'H' 'S' 'Y' 'J' 'L' 'M' 'Q' 'W'});
yticklabels({'B' 'X' 'F' 'R' 'H' 'S' 'Y' 'J' 'L' 'M' 'Q' 'W'});

set(gca,'FontSize',40,'FontName', 'Calibri');