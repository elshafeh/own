clear;close all;

figure;
hold on;
i = 0;

for nback = [2 3]
    
    file_list = dir(['K:/nback/response/sub*.sess*.' num2str(nback-1) 'back.dwn60.excl.correct.auc.mat']);
    mtrx_data               = [];
    
    for nf = 1:length(file_list)
        fname               = [file_list(nf).folder filesep file_list(nf).name];
        fprintf('loading %s\n',fname);
        load(fname);
        mtrx_data(nf,:)     = scores; clear scores fname;
    end
    
    list_color              = 'rgb';
    
    
    mean_data                           = nanmean(mtrx_data,1);
    bounds                              = nanstd(mtrx_data, [], 1);
    bounds_sem                          = bounds ./ sqrt(size(mtrx_data,1));
    
    i = i +1;
    %     subplot(2,2,i);
    boundedline(time_axis, mean_data, bounds_sem,['-' list_color(nback)],'alpha'); % alpha makes bounds transparent
    
    %     title([num2str(nback-1) ' back n=' num2str(nf)]);
    
    xlim([-0.5 2]);
    ylim([0.3 0.8]);
    
    vline(0,'--k');
    hline(0.5,'--k');
    
end

% legend({'0 Back','','1 Back','','2 Back'});
legend({'1 Back','','2 Back'});