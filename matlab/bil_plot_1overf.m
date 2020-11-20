clear;

clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

nrow    = 5;
ncol    = 2;
i       = 0;

for ntime = 1:5
    
    list_time                   = {'m1000m0ms','m500m1500ms','m2000m3000ms','m3500m4500ms','m1000m4500ms'};
    
    
    for nsuj = 1:length(suj_list)
        
        subjectName             = suj_list{nsuj};
        fname                   = ['/project/3015079.01/data/' subjectName '/tf/' subjectName '.firstcuelock.1overf.orig.alphabetaPeak.' ... 
            list_time{ntime} '.mat'];
        load(fname);
        
        alldata{nsuj,1}         = data;
        alldata{nsuj,1}.avg     = data.avg(1,:);
        alldata{nsuj,1}.label   = {'fft'};
        
        
        alldata{nsuj,2}         = data;
        alldata{nsuj,2}.avg     = data.avg(2,:);
        alldata{nsuj,2}.label   = {'fft'};
        
        allpeaks(nsuj,:)        = [apeak_orig apeak_osci bpeak_orig bpeak_ocsi];
        
    end
    
    i = i +1;
    subplot(nrow,ncol,i)
    hold on;
    cfg                 =  [];
    cfg.plot_single     = 'no';
    cfg.color           = 'k';
    h_plot_erf(cfg,alldata(:,1));
    cfg.color           = 'm';
    h_plot_erf(cfg,alldata(:,2));
    xlim([1 35])
    title(list_time{ntime});
    
    vct                         = ones(size(allpeaks));
    vct                         = vct .* [1:4];
    
    i = i +1;
    subplot(nrow,ncol,i)
    hold on;
    for nm = 1:size(allpeaks,2)
        x = vct(:,nm) + (0.01 .* [1:size(allpeaks,1)]');
        y   = allpeaks(:,nm);
        scatter(x,y);
    end
    xlim([0 5]);
    xticks([1 2 3 4]);
    
    %     boxplot(allpeaks);
    
    find_nan_1                      = length(find(isnan(allpeaks(:,3))));
    find_nan_2                      = length(find(isnan(allpeaks(:,4))));
    
    title(['nan orig= ' num2str(find_nan_1) ' nan 1/f=' num2str(find_nan_2)]);
    
end