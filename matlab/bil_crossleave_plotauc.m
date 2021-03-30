clear;clc;

if isunix
    project_dir              	= '/project/3015079.01/';
    start_dir                 	= '/project/';
else
    project_dir               	= 'P:/3015079.01/';
    start_dir                	= 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

alldata                         = [];

for nsuj = 1:length(suj_list)
    
    try
        
        subjectName              	= suj_list{nsuj};
        subject_folder           	= [project_dir 'data/' subjectName '/decode/'];
        
        list_band                   = {'theta' 'alpha' 'beta'};
        list_bin                    = [1 5];
        
        list_label                   = {'1stcue' 'pre.task' ; '2ndcue' 'retro.task'};
        
        for ncue = 1:length(list_label)
            for nband = 1:length(list_band)
                for nbin = 1:length(list_bin)
                    
                    scores_avg          = [];
                    
                    for nshuffle = 1:4
                        
                        fname           = [subject_folder subjectName '.' list_label{ncue,1} '.lock.decoding.' list_label{ncue,2}];
                        fname           = [fname '.' list_band{nband} '.bin' num2str(list_bin(nbin)) '.shuffle' num2str(nshuffle) '.crossone.mat'];
                        fprintf('loading %s\n',fname);
                        load(fname);
                        
                        scores_avg(nshuffle,:) = scores; clear scores;
                        
                    end
                    
                    alldata(nsuj,ncue,nband,nbin,:)    = mean(scores_avg,1);
                    
                end
            end
        end
        
    catch
        
        disp('skipping subject');
    end
end

keep alldata list_* time_axis

%%

nrow        = 2;
ncol        = 3;
i           = 0;

for ncue = 1:length(list_label)
    for nband = 1:length(list_band)
        
        i = i + 1;
        subplot(nrow,ncol,i);
        hold on;
        
        color_matrix                        = [0 0 1; 1 0 0];
        
        for nbin = 1:length(list_bin)
            
            mtrx                            = squeeze(alldata(:,ncue,nband,nbin,:));
            
            if size(mtrx,1) > size(mtrx,2)
                mtrx = mtrx';
            end
            
            mean_data                       = nanmean(mtrx,1);
            bounds                          = nanstd(mtrx, [], 1);
            bounds_sem                      = bounds ./ sqrt(size(mtrx,1));
            boundedline(time_axis, mean_data, bounds_sem,'cmap',color_matrix(nbin,:),'alpha'); % alpha makes bounds transparent
            vline(0,'--k');
            hline(0.5,'--k');
            ylabel(list_label{ncue,1} );
            xlabel('Time (s)');
            xlim([-0.2 1.5]);
            ylim([0.4 0.8]);
            
            title(list_band{nband});
            set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','normal');
            
        end
    end
end