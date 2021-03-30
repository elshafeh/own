clear;clc;

suj_list                                = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    sujname                             = ['sub' num2str(suj_list(nsuj))];
    
    dir_files                           = 'P:/3035002.01/nback/';
    
    list_decode                         = {'target.nodemean' 'condition.nodemean'}; %{'condition.nodemean.bsl' 'condition.nodemean' 'condition.yesdemean'}; %{'target' 'first' 'condition'};
    
    for ndecode = 1:length(list_decode)
        
        % load decoding output
        fname                           = [dir_files 'auc/' sujname '.decoding.' list_decode{ndecode} '.leaveone.mat'];
        fprintf('loading %s\n',fname);
        load(fname,'y_array','yproba_array','time_axis','e_array');
        
        % transpose matrices
        y_array                     	= y_array';
        yproba_array                  	= yproba_array';
        e_array                       	= e_array';
        
        measure                     	= 'auc'; % auc yproba
        
        idx_trials                      = 1:size(yproba_array,1);
        
        AUC_bin_test                 	= [];
        disp('computing AUC');
        
        for ntime = 1:size(y_array,2)
            
            if strcmp(measure,'yproba')
                
                yproba_array_test     	= yproba_array(idx_trials,ntime);
                
                if min(unique(y_array(:,ntime))) == 1
                    yarray_test        	= y_array(idx_trials,ntime) - 1;
                else
                    yarray_test       	= y_array(idx_trials,ntime);
                end
                
                [~,~,~,AUC_bin_test(ntime)]	= perfcurve(yarray_test,yproba_array_test,1);
                
            elseif strcmp(measure,'auc')
                AUC_bin_test(ntime)     = mean(e_array(idx_trials,ntime));
            end
        end
        
        avg                             = [];
        avg.avg                         = AUC_bin_test;
        avg.time                        = time_axis;
        avg.label                       = {['decoding ' list_decode{ndecode}]};
        avg.dimord                      = 'chan_time';
        
        alldata{nsuj,ndecode}         	= avg; clear avg;
        
    end
end

%%

keep alldata list_*

for ndecode = 1:size(alldata,2)
    
    cfg                                     = [];
    cfg.label                               = alldata{1,ndecode}.label;
    cfg.plot_single                         = 'no';
    
    subplot(2,2,ndecode)
    h_plot_erf(cfg,alldata(:,ndecode));
    xlim([-0.1 1]);
    vline(0,'--k');

    title(alldata{1,ndecode}.label{1});

    
end