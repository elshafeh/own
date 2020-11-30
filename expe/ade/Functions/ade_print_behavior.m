function ade_print_behavior(Info)

% block,noise,side,measure
[perc_to_plot]  = ade_behav_plot_prep(Info);

list_noise      = {'n-0','n-1'};
list_side       = {'left','right'};
list_measure    = {'corr','conf'};

clc;

for nblock = 1:size(perc_to_plot,1)
    for nmeasure = 1:size(perc_to_plot,4)
        
        fprintf('%5s\t\n',list_measure{nmeasure});
        
        for nnoise = 1:2
            
            fprintf('%5s\t',list_noise{nnoise});
            
            for nside = 1:size(perc_to_plot,3)
                
                mtrx = squeeze(perc_to_plot(nblock,nnoise,nside,nmeasure));
                
                fprintf('%5s\t%.2f\t',list_side{nside},mtrx);
                
            end
            
            fprintf('\n');
            
        end
    end
end