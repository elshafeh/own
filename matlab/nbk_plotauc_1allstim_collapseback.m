clear;

suj_list                            = [1:33 35:36 38:44 46:51]; %who_what_per_subject('stim_stack','auc.collapse'); %
i                                   = 0;

for nsub = suj_list
    
    i                               = i + 1;
    
    for nlock = [1 2 3]
        
        file_list                   = dir(['../data/decode_data/stim_stack/sub' num2str(nsub) '.stim*.*back.' num2str(nlock-1) 'lock.auc.collapse.mat']);
        tmp                         = [];
        
        for nfile = 1:length(file_list)
            fname                	= [file_list(nfile).folder filesep file_list(nfile).name];
            fprintf('loading %s\n',fname);
            load(fname);
            tmp                 	= [tmp;scores]; clear scores;
        end
        
        all_data(i,nlock,:)         = mean(tmp,1);
        
    end
end

keep all_data time time_axis

figure;
hold on;

for nlock = 1:3
    
    mtrx_data                       = squeeze(all_data(:,nlock,:));
    bounds_mean                     = mean(mtrx_data,1);
    bounds                          = nanstd(mtrx_data, [], 1);
    bounds_sem                      = bounds ./ sqrt(size(mtrx_data,1));
    
    list_color                   	= 'brk';
    
    boundedline(time_axis,bounds_mean , bounds_sem,list_color(nlock),'alpha'); % alpha makes bounds transparent
    
    hline(0.5,'--k');
    
    vline(0,'--k');
    vline(2,'--k');
    vline(4,'--k');
    
    xlim([-0.1 6]);
    ylim([0.49 0.56]);
    
end

legend({'stim1-lock' 'sem' 'stim2-lock' 'sem' 'stim3-lock' 'sem'})

keep all_data time time_axis