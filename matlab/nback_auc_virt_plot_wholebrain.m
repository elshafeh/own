clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load suj_list_peak.mat

list_freq                                   = {'alpha1Hz.virt.demean','beta3Hz.virt.demean'};

for n_freq = 1:length(list_freq)
    
    list_condition                          = {'0Ball','1Ball','2Ball' }; 
    
    for n_con = 1:length(list_condition)
        
        tmp                                 = [];
        
        for n_suj = 1:length(suj_list)
            
            fname                           = ['../data/decode_data/virt/sub' num2str(suj_list(n_suj)) '.' list_condition{n_con} '.' list_freq{n_freq}];
            fname                           = [fname '.auc.bychan.mat'];
            
            fprintf('loading %s\n',fname);
            load(fname);
            
            ix1                             = find(round(time_axis,2) == 0.2);
            ix2                             = find(round(time_axis,2) == 0.7);
            
            pow                             = mean(scores(:,ix1:ix2),2);
            
            tmp(:,n_suj)                    = pow; clear ix1 ix2 pow scores;
            
            
        end
        
        tmp                                 = mean(tmp,2);
        source                              = h_towholebrain(tmp,'../data/template/brainnetome_roi1cm.mat','../data/template/template_grid_1cm.mat');
        alldata{n_freq,n_con}               = source; clear source tmp;
        
    end
end

keep alldata

new_list_condition                          = {'0 vs all','1 vs all','2 vs all'};
new_list_freq                               = {'α ± 1Hz','β ± 3Hz'};


for n_freq = 1:size(alldata,1)
    for n_con = 1:size(alldata,2)
        for iside = [1 2]
            
            tmp                             = alldata{n_freq,n_con}.pow;
            tmp(tmp <= 0.5)                 = NaN;
            alldata{n_freq,n_con}.pow       = tmp;
            
            
            lst_side                        = {'left','right','both'};
            lst_view                        = [-95 1;97 5;0 50];
            
            cfg                             =   [];
            cfg.method                      =   'surface';
            cfg.funparameter                =   'pow';
            cfg.funcolorlim                 =   [0.5 0.6];
            cfg.opacitylim                  =    cfg.funcolorlim;
            cfg.opacitymap                  =   'rampup';
            cfg.colorbar                    =   'off';
            cfg.camlight                    =   'no';
            cfg.projmethod                  =   'nearest';
            cfg.surffile                    =   'surface_white_both.mat';
            cfg.surfinflated                =   'surface_inflated_both_caret.mat';
            
            ft_sourceplot(cfg, alldata{n_freq,n_con});
            colormap(brewermap(256, '*Spectral'));
            
            title([new_list_freq{n_freq} ' ' new_list_condition{n_con}]);
            view(lst_view(iside,:));
            
        end
    end
end