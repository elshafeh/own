clear ; clc;

if isunix
    project_dir                     = '/project/3015079.01/';
    start_dir                       = '/project/';
else
    project_dir                     = 'P:/3015079.01/';
    start_dir                       = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    fname                           = [project_dir 'data/' subjectName '/tf/' subjectName '.firstcuelock.1overf.orig.alphabetaPeak.' ...
        'm1000m0ms.mat'];
    load(fname);
    allpeaks(nsuj,1)                = [apeak_orig];
    allpeaks(nsuj,2)                = [bpeak_orig];
    
end

allpeaks(isnan(allpeaks(:,2)),2) 	= nanmean(allpeaks(:,2));

keep allpeaks suj_list project_dir

sj_cap                              = length(dir([project_dir 'data/*/tf/*.itc.withcorrect.bin5.mtm.mat']));

for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    list_cue                        = {'pre' 'retro'};
    
    for ncue = 1:2
        for nbin = 1:5
            
            fname                   = [project_dir 'data/' subjectName '/tf/' subjectName '.' list_cue{ncue} 'cue.itc.withcorrect.bin' num2str(nbin) '.mtm.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            
            fname                   = [project_dir 'data/' subjectName '/erf/' subjectName '.gratinglock.demean.erfComb.max20chan.p0p200ms.postOnset.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            
            list_chan               = [];
            
            for nchan = 1:length(max_chan)
                list_chan       	= [list_chan;find(strcmp(freq_comb.label,max_chan{nchan}))];
            end
            
            list_win_name         	= {'cue1' 'gab1' 'cue2' 'gab2'};
            list_window             = [-1 0; 0.5 1.5; 2 3; 3.5 4.5];
            list_window             = list_window - 0.1;
            
            list_band               = 'alpha';
            
            switch list_band
                case 'alpha'
                    f_focus     	= allpeaks(nsuj,1);
                    f_width        	= 1;
                case 'beta'
                    f_focus        	= allpeaks(nsuj,2);
                    f_width        	= 2;
                case 'gamma'
                    f_focus        	= 80;
                    f_width        	= 20;
            end
            
            for nwin = 1:size(list_window,1)
                
                t1      = find(round(freq_comb.time,3) == round(list_window(nwin,1),3));
                t2      = find(round(freq_comb.time,3) == round(list_window(nwin,2),3));
                
                f1      = find(round(freq_comb.freq) == round(f_focus-f_width));
                f2      = find(round(freq_comb.freq) == round(f_focus+f_width));
                
                pow     = nanmean(nanmean(nanmean(freq_comb.powspctrm(list_chan,f1:f2,t1:t2))));
                
                alldata(nsuj,nbin,nwin,ncue)     = pow; clear pow t1 t2 f1 f2
                
                
            end
        end
        
        fprintf('\n');
        
    end
end

keep alldata list_*; clc ;

%% normalize

for nsuj = 1:size(alldata,1)
    for nwin = 1:size(alldata,3)
        for ncue = 1:size(alldata,4)
            data_avgbin(nsuj,nwin,ncue)             = mean(squeeze(alldata(nsuj,:,nwin,ncue)));
        end
    end
end

for nsuj = 1:size(alldata,1)
    for nbin = 1:size(alldata,2)
        for nwin = 1:size(alldata,3)
            for ncue = 1:size(alldata,4)
                alldata(nsuj,nbin,nwin,ncue)         = (alldata(nsuj,nbin,nwin,ncue)) ./ data_avgbin(nsuj,nwin,ncue);
            end
        end
    end
end

keep alldata data_avgbin list_*;

%% send to R

r_array     = {}; 
i           = 0;

for nsuj = 1:size(alldata,1)
    
    var_name            = {'sub'};
    
    list_bin            = {'b1' 'b2' 'b3' 'b4' 'b5'};
        
    for nbin = 1:size(alldata,2)
        for nwin = [1 3]
            for ncue = 1:size(alldata,4)
                
                i                   = i +1;
                r_array{i,1}        = ['sb' num2str(nsuj)];
                r_array{i,2}        = list_bin{nbin};
                r_array{i,3}        = list_win_name{nwin};
                r_array{i,4}        = list_cue{ncue};
                r_array{i,5}        = round(alldata(nsuj,nbin,nwin,ncue),3);
                
            end
        end
    end
end

keep alldata data_avgbin list_* r_array var_name;clc;

r_table   	= cell2table(r_array,'VariableNames',{'sub' 'bin' 'window' 'cue' 'pow'});
writetable(r_table,['../doc/bil.' list_band '.pow.itc.bin.4R.txt']);
fprintf('done!\n');

keep alldata data_avgbin list_*;

%% send to jasp

jasp_array  = {}; 

for nsuj = 1:size(alldata,1)
    
    var_name    = {'sub'};
    
    i           = 1;
    list_bin    = {'b1' 'b2' 'b3' 'b4' 'b5'};
    
    jasp_array{nsuj,i} = ['sb' num2str(nsuj)];
    
    for nbin = 1:size(alldata,2)
        for nwin = [1 3]%1:size(alldata,3)
            for ncue = 1:size(alldata,4)
                
                i                   = i +1;
                jasp_array{nsuj,i}  = round(alldata(nsuj,nbin,nwin,ncue),3);
                var_name{end+1}     = [list_bin{nbin} '_' list_win_name{nwin} '_' list_cue{ncue}];
                
            end
        end
    end
end

keep alldata data_avgbin list_* jasp_array var_name;clc;

jasp_tabe                   = cell2table(jasp_array,'VariableNames',var_name);
writetable(jasp_tabe,['../doc/bil.' list_band '.pow.itc.bin.4jasp.txt']);
fprintf('done!\n');

keep alldata data_avgbin list_*;
%% plot


lm1                         = 0.9;
lm2                         = 1.1;
wdth                        = 0.1;

for nwin = 1:size(alldata,3)
    
    subplot(2,3,nwin)
    hold on;
    
    list_color              = {'blue' 'magenta'};
    list_line               = {'-bs' '-ms'};
    
    for ncue = 1:size(alldata,4)
        
        data                = squeeze(alldata(:,:,nwin,ncue));
        
        mean_data         	= mean(data,1);
        bounds           	= std(data, [], 1);
        bounds_sem        	= bounds ./ sqrt(size(data,1));
        
        x                   = 1:size(data,2);
        y                   = mean_data;
        errorbar(x,y,bounds_sem,list_line{ncue},'MarkerSize',10,'MarkerEdgeColor',list_color{ncue},'MarkerFaceColor',list_color{ncue},'LineWidth',2);
        
        xlim([0 size(data,2)+1])
        xticks([1 3 5]);
        xticklabels({'Fastest' 'Median' 'Slowest'});
        
        ylim([lm1 lm2]);
        yticks(lm1:wdth:lm2);
        
        if nwin == 1
            ylabel([list_band ' n = ' num2str(size(alldata,1))]);
        end
        
        title({list_win_name{nwin}})
        set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','Light');
        
        grid on;
        
    end
    
    %     legend(list_cue)
    
end

% lm1                     = 0.5;
% lm2                     = 1.5;
% wdth                    = 0.2;
%
% for nwin = 1:size(alldata,3)
%
%     subplot(2,3,nwin+3)
%
%     data                = squeeze(alldata(:,:,nwin));
%
%     mean_data         	= mean(data,1);
%     bounds           	= std(data, [], 1);
%     bounds_sem        	= bounds ./ sqrt(size(data,1));
%
%     x                   = 1:size(data,2);
%     y                   = mean_data;
%     violin(data,'plotlegend','no','facecolor',[1 0 0.2;1 0 0.4;1 0 0.6;1 0 0.8;1 0 1],'edgecolor','k');
%
%     xlim([0 size(data,2)+1])
%     xticks([1 3 5]);
%     xticklabels({'Fastest' 'Median' 'Slowest'});
%
%     ylim([lm1 lm2]);
%     yticks(lm1:wdth:lm2);
%
%     if nwin == 1
%         ylabel(['n = ' num2str(size(alldata,1))]);
%     else
%         ylabel({'',''});
%     end
%
%     set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','Light');
%
%     grid on;
%
% end

keep alldata data_avgbin list_*;