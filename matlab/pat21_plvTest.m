clear;clc;
allsuj = [];

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    clist           = {'bsl','actv'};
    
    for t = 1:length(clist)
        load(['../data/tfr/' suj '.CnD.plvPrimer.' clist{t} '.mat']);
        data_carr{t}    = coh; clear coh ;
    end
    
    template                = data_carr{1};
    %     pow                     = (data_carr{2}.plvspctrm - data_carr{1}.plvspctrm) ./ data_carr{1}.plvspctrm ;
    pow                     = (data_carr{2}.plvspctrm - data_carr{1}.plvspctrm);
    allsuj                  = cat(4,allsuj,pow) ;
    
    clear data_carr pow;
    
end

clearvars -except allsuj template

cohstattoplot = template;

ntest    = length(template.label) * length(template.label) * length(template.freq);
i        = 0 ;

for chan1 = 1:length(template.label)
    for chan2 = 1:length(template.label)
        for f = 1:length(template.freq)
            
            i = i + 1 ;
            fprintf('Test %3d out %3d\n',i,ntest);
            
            dataX = squeeze(allsuj(chan1,chan2,f,:));
            dataY = zeros(14,1);
            
            %             cohstattoplot.cohspctrm(chan1,chan2,f)      = permutation_test([dataX dataY],1000);
            
            [h,p]                                       = ttest(dataX,dataY,'tail','left');
            
            if isnan(p)
                p =0 ;
            end
            
            cohstattoplot.plvspctrm(chan1,chan2,f)      = p;
            
            clear dataX dataY h p;
            
        end
    end
end

f2plot                  = cohstattoplot;
plim                    = 0.1;
mask                    = f2plot.plvspctrm < plim ;
f2plot.plvspctrm        = f2plot.plvspctrm .* mask ;

cfg                     = [];
cfg.parameter           = 'plvspctrm';
cfg.zlim                = [0 plim];
ft_connectivityplot(cfg, f2plot);