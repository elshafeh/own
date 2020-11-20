clear ; clc; close all;

[file,path]                                             = uigetfile('/project/3015039.04/misc_data/','Select a subject list');
load([path file]);

i                                                       = 0;

for nm = 1:length(list_modality)
    
    list_suj                                            = goodsubjects{nm};
    dataplot                                            = [];
    
    i                                                   = i +1;
    subplot(1,2,i)
    hold on;
    
    for ns = 1:length(list_suj)
        
        suj                                             = list_suj{ns};
        modality                                        = list_modality{nm};
        
        fprintf('handling mod %2d out-of %2d || sub %2d out-of %d\n', ...
            nm,length(list_modality),ns,length(list_suj));
        
        fname                                           = ['../data/' suj '/tf/' suj '_sfn.phaselock_' modality '.mat'];
        load(fname);
        
        list_legend                                     = {};                                          
        
        for nb = 1:6
            
            tmp                                         = squeeze(phase_lock{nb}.powspctrm) .* squeeze(phase_lock{nb}.mask);
            tmp                                         = squeeze(mean(tmp,1));
            
            list_legend{nb}                             = ['rt' num2str(nb)];
            dataplot(ns,nb,:)                           = tmp; clear tmp;
            
        end
        
    end
    
    for nb = [1 6]
        
        vct                                             = mean(squeeze(dataplot(:,nb,:)));
        plot(phase_lock{1}.freq,vct,'LineWidth',3);
        clear vct
        
        ylim([0 0.15]);
        xlim([5 20]);
        
    end
    
    legend(list_legend([1 6]));
    title(list_modality{nm});
    
end
