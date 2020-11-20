close all;clear;clc;

figure;
hold on;
mtrx_data                           = [];

for nstim = 1:10
    
    file_list                       = dir(['../data/decode_data/stim_ag_all/sub*.stim' num2str(nstim) '.against.all.auc.mat']);
    
    for nf = 1:length(file_list)
        fname                       = [file_list(nf).folder filesep file_list(nf).name];
        load(fname);
        mtrx_data(nf,nstim,:)       = scores; clear scores;
    end
   
end

mtrx_data                           = squeeze(mean(mtrx_data,2));

bounds_mean                         = mean(mtrx_data,1);
bounds                              = nanstd(mtrx_data, [], 1);
bounds_sem                          = bounds ./ sqrt(size(mtrx_data,1));


boundedline(time_axis,bounds_mean , bounds_sem,'-k','alpha'); % alpha makes bounds transparent
xlim([-0.1 1]);
ylim([0.5 0.6]);
vline(0,'--k');

yticks([0.5 0.6]);
ylabel('Decoding Accuracy')
set(gca,'FontSize',20,'FontName', 'Calibri');

figure;
hold on;

data_mean               = [];
data_std                = [];
data_sem                = [];

list_chan               = {'B' 'X' 'F' 'R' 'H' 'S' 'Y' 'J' 'L' 'M' 'Q' 'W'};

for nstim = 1:10
    
    file_list           = dir(['../data/decode_data/stim_ag_all/sub*.stim' num2str(nstim) '.against.all.auc.mat']);
    mtrx_data           = [];
    
    for nf = 1:length(file_list)
        fname           = [file_list(nf).folder filesep file_list(nf).name];
        load(fname);
        mtrx_data(nf,:) = scores; clear scores;
    end
   
    t1                  = find(round(time_axis,2) == round(0.1,2));
    t2                  = find(round(time_axis,2) == round(0.4,2));
    
    mtrx_data           = mean(mtrx_data(:,t1:t2),2);
    
    data_mean           = [data_mean mean(mtrx_data,1)];
    data_std            = [data_std nanstd(mtrx_data, [], 1)];
    data_sem            = [data_sem nanstd(mtrx_data, [], 1)./sqrt(size(mtrx_data,1))];
    
end

vct_to_sort             = [data_mean; 1:10]';
vct_to_sort             = sortrows(vct_to_sort,1);
vct_to_sort             = vct_to_sort(:,2);

data_mean               = data_mean(vct_to_sort);
data_sem                = data_sem(vct_to_sort);
list_chan               = list_chan(vct_to_sort);

errorbar(1:10, data_mean, data_sem, 'LineStyle','none','LineWidth',2);
scatter(1:10,data_mean,150,'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1.5)

xlim([0 11]);
ylim([0.5 0.6]);
yticks([0.5 0.6]);
ylabel('Decoding Accuracy')
xticklabels([{''},list_chan,{''}]);
set(gca,'FontSize',24,'FontName', 'Calibri');

figure;

for nstim = 1:10
    
    file_list           = dir(['../data/decode_data/stim_ag_all/sub*.stim' num2str(nstim) '.against.all.auc.mat']);
    mtrx_data           = [];
    
    for nf = 1:length(file_list)
        
        fname           = [file_list(nf).folder filesep file_list(nf).name];
        load(fname);
        mtrx_data(nf,:) = scores; clear scores;
    end
    
    bounds_mean                         = mean(mtrx_data,1);
    bounds                              = nanstd(mtrx_data, [], 1);
    bounds_sem                          = bounds ./ sqrt(size(mtrx_data,1));
        
    subplot(4,3,nstim)
    boundedline(time_axis,bounds_mean , bounds_sem,'-k','alpha'); % alpha makes bounds transparent
    xlim([-0.1 1]);
    ylim([0.49 0.6]);
    vline(0,'--k');
    hline(0.5,'--k');
    
    list_stim                           = {'B' 'X' 'F' 'R' 'H' 'S' 'Y' 'J' 'L' 'M' 'Q' 'W'};
    title(['STIM' num2str(nstim) ': ' list_stim{nstim}]);

end

clear;clc;
figure;
hold on;
for nstim = 1:10
    
    file_list           = dir(['../data/decode_data/stim_ag_all/sub*.stim' num2str(nstim) '.against.all.auc.mat']);
    mtrx_data           = [];
    
    for nf = 1:length(file_list)
        
        fname           = [file_list(nf).folder filesep file_list(nf).name];
        load(fname);
        mtrx_data(nf,:) = scores; clear scores;
    end
    
    bounds_mean                         = mean(mtrx_data,1);
    bounds                              = nanstd(mtrx_data, [], 1);
    bounds_sem                          = bounds ./ sqrt(size(mtrx_data,1));
    
    list_color                          = 'brkgcymbrkgcym';
    
    boundedline(time_axis,bounds_mean , bounds_sem,list_color(nstim),'alpha'); % alpha makes bounds transparent
    vline(0,'--k');
    hline(0.5,'--k');
    
    list_stim                           = {'B' '' 'X' '' 'F' '' 'R' '' 'H' '' 'S' ''  'Y' '' 'J' '' 'L' '' 'M' '' 'Q' '' 'W'};

end

legend(list_stim);