clear ; close all;

suj_list                                            = dir('../data/sub*/tf/*cuelock.itc.comb.5binned.mat');

for ns = 1:length(suj_list)
    
    sujName                                         = suj_list(ns).name(1:6);
    
    fname                                           = [suj_list(ns).folder '/' suj_list(ns).name];
    fprintf('\nloading %s',fname);
    load(fname);
    
    list_legend                                     = {};
    
    for nb = 1:length(phase_lock)
        
        phase_lock{nb}.powspctrm                    = phase_lock{nb}.powspctrm;
        
        tmp                                         = squeeze(mean(phase_lock{nb}.powspctrm,1));
        
        ix1                                         = find(round(phase_lock{nb}.freq) == 3);
        ix2                                         = find(round(phase_lock{nb}.freq) == 5);
        
        tmp                                         = squeeze(mean(tmp(ix1:ix2,:),1));
        
        list_legend{nb}                             = ['rt' num2str(nb)];
        dataplot(ns,nb,:)                           = tmp; clear tmp;
        
    end
    
end

figure;
hold on;

list_color                                          = 'bkrgc';
indx                                                =  [1 2 3 4 5];


for nb = indx
    
    mtrx_data                                       = squeeze(dataplot(:,nb,:));
    
    mean_data                                       = nanmean(mtrx_data,1);
    bounds                                          = nanstd(mtrx_data, [], 1);
    bounds_sem                                      = bounds ./ sqrt(size(mtrx_data,1));
    
    time_axs                                        = phase_lock{1}.time;
    
    boundedline(time_axs, mean_data, bounds_sem,['-' list_color(nb)],'alpha'); % alpha makes bounds transparent
    xlim([-0.2 6]);
end

legend(list_legend(indx));

for nv = [0 1.5 3 4.5]
    vline(nv,'--k');
end