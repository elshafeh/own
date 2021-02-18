clear;clc;

if isunix
    project_dir                     = '/project/3015079.01/';
    start_dir                       = '/project/';
else
    project_dir                     = 'P:/3015079.01/';
    start_dir                       = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nwin = [1 2]
    
    mtrx_data                    	= [];
    
    for nsuj = 1:length(suj_list)
        
        subjectName                         = suj_list{nsuj};
        subject_folder                      = [project_dir 'data/' subjectName '/decode/'];
        
        win_label                           = {'1stcue' 'pre.task' ; '2ndcue' 'retro.task'};
        
        fname                               = [subject_folder subjectName '.' win_label{nwin,1}  '.lock.broadband.centered.decoding.'  win_label{nwin,2} '.leaveone.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        y_array                             = y_array';
        yproba_array                        = yproba_array';
        AUC_bin_test                        = [];
        
        for ntime = 1:size(y_array,2)
            yproba_array_test               = yproba_array(:,ntime);
            
            if min(unique(y_array(:,ntime))) == 1
                yarray_test              	= y_array(:,ntime) - 1;
            else
                yarray_test              	= y_array(:,ntime);
            end
            
            [~,~,~,AUC_bin_test(ntime)]     = perfcurve(yarray_test,yproba_array_test,1);
        end
        
        mtrx_data(nsuj,:)            = AUC_bin_test;
        
    end
    
    subplot(2,1,nwin)
    % Use the standard deviation over trials as error bounds:
    mean_data                       = nanmean(mtrx_data,1);
    bounds                          = nanstd(mtrx_data, [], 1);
    bounds_sem                      = bounds ./ sqrt(size(mtrx_data,1));
    boundedline(time_axis, mean_data, bounds_sem,'-k','alpha'); % alpha makes bounds transparent
    
    vline(0,'--k');
    hline(0.5,'--k');
    ylabel('AUC');
    xlabel('Time (s)');
    ylim([0.4 0.7]);
    xlim([-0.1 1.5]);
    
end