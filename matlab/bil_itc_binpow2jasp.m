clear ; clc;

if isunix
    project_dir                 = '/project/3015079.01/';
    start_dir                   = '/project/';
else
    project_dir                 = 'P:/3015079.01/';
    start_dir                   = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                 = suj_list{nsuj};
    fname                       = [project_dir 'data/' subjectName '/tf/' subjectName '.firstcuelock.1overf.orig.alphabetaPeak.' ...
        'm1000m0ms.mat'];
    load(fname);
    allpeaks(nsuj,1)            = [apeak_orig];
    allpeaks(nsuj,2)            = [bpeak_orig];
    
end

allpeaks(isnan(allpeaks(:,2)),2) 	= nanmean(allpeaks(:,2));

keep allpeaks suj_list project_dir

sj_cap                          = length(dir([project_dir 'data/*/tf/*.itc.withcorrect.bin5.mtm.mat']));
suj_list                        = suj_list(1:sj_cap);

for nsuj = 1:length(suj_list)
   
    subjectName                 = suj_list{nsuj};
    
    for nbin = 1:5
    
        fname                   = [project_dir 'data/' subjectName '/tf/' subjectName '.itc.withcorrect.bin' num2str(nbin) '.mtm.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        fname                   = [project_dir 'data/' subjectName '/erf/' subjectName '.gratinglock.demean.erfComb.max20chan.p0p200ms.postOnset.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        list_chan               = [];
        
        for nchan = 1:length(max_chan)
            list_chan       	= [list_chan;find(strcmp(freq_comb.label,max_chan{nchan}))];
        end
        
        list_window             = [0.5 1.5; 2 3; 3.5 4.5];
        
        %         f_focus                 = allpeaks(nsuj,1);
        %         f_width              	= 1;
        
        f_focus                 = allpeaks(nsuj,2);
        f_width              	= 2;
        
        
        for nwin = 1:size(list_window,1)
            
            t1      = find(round(freq_comb.time,3) == round(list_window(nwin,1),3));
            t2      = find(round(freq_comb.time,3) == round(list_window(nwin,2),3));
            
            f1      = find(round(freq_comb.freq) == round(f_focus-f_width));
            f2      = find(round(freq_comb.freq) == round(f_focus+f_width));
            
            pow     = nanmean(nanmean(nanmean(freq_comb.powspctrm(list_chan,f1:f2,t1:t2))));
            
            alldata(nsuj,nbin,nwin)     = pow; clear pow t1 t2 f1 f2
            
                        
        end
    end
    
    fprintf('\n');
    
end

keep alldata ; clc ;

%% normalize

for nsuj = 1:size(alldata,1)
    for nwin = 1:size(alldata,3)
        data_avgbin(nsuj,nwin)          	= mean(squeeze(alldata(nsuj,:,nwin)));
    end
end

for nsuj = 1:size(alldata,1)
    for nbin = 1:size(alldata,2)
        for nwin = 1:size(alldata,3)
            alldata(nsuj,nbin,nwin)         = alldata(nsuj,nbin,nwin) ./ data_avgbin(nsuj,nwin);
        end
    end
end

keep alldata data_avgbin; 

%% plot

list_name               = {'cue1 - gab1' 'gab1 - cue2' 'cue2 - gab2'};

lm1                     = 0.95;
lm2                     = 1.05;
wdth                    = 0.1;

for nwin = 1:size(alldata,3)
    
    subplot(2,3,nwin)
    
    data                = squeeze(alldata(:,:,nwin));
    
    mean_data         	= mean(data,1);
    bounds           	= std(data, [], 1);
    bounds_sem        	= bounds ./ sqrt(size(data,1));
    
    x                   = 1:size(data,2);
    y                   = mean_data;
    errorbar(x,y,bounds_sem,'-ks','MarkerSize',10,'MarkerEdgeColor','black','MarkerFaceColor','red','LineWidth',2);
        
    xlim([0 size(data,2)+1])
    xticks([1 3 5]);
    xticklabels({'Fastest' 'Median' 'Slowest'});
    
    ylim([lm1 lm2]);
    yticks(lm1:wdth:lm2);
    
    if nwin == 1
        ylabel(['n = ' num2str(size(alldata,1))]);
    end
    
    title({list_name{nwin}})
    set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','Light');
    
    grid on;
    
end

lm1                     = 0.5;
lm2                     = 1.5;
wdth                    = 0.2;

for nwin = 1:size(alldata,3)
    
    subplot(2,3,nwin+3)
    
    data                = squeeze(alldata(:,:,nwin));
    
    mean_data         	= mean(data,1);
    bounds           	= std(data, [], 1);
    bounds_sem        	= bounds ./ sqrt(size(data,1));
    
    x                   = 1:size(data,2);
    y                   = mean_data;    
    violin(data,'plotlegend','no','facecolor',[1 0 0.2;1 0 0.4;1 0 0.6;1 0 0.8;1 0 1],'edgecolor','k');
    
    xlim([0 size(data,2)+1])
    xticks([1 3 5]);
    xticklabels({'Fastest' 'Median' 'Slowest'});
    
    ylim([lm1 lm2]);
    yticks(lm1:wdth:lm2);
    
    if nwin == 1
        ylabel(['n = ' num2str(size(alldata,1))]);
    else
        ylabel({'',''});
    end
    
    set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','Light');
    
    grid on;
    
end

keep alldata data_avgbin; 