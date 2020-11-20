clear;

suj_list                            = [1:51]; %[1:33 35:36 38:44 46:51]; %who_what_per_subject('stim_stack','auc.collapse'); %

for nback = 0:2
    for nlock = 0:2
        
        tmp                         = [];
        file_list                   = dir(['../data/decode_data/stim_stack/sub*.stim*.' num2str(nback) 'back.' num2str(nlock) 'lock.auc.collapse.mat']);
        
        for nfile = 1:length(file_list)
            
            suj_number              = strsplit(file_list(nfile).name,'.');
            suj_number              = str2double(suj_number{1}(4:end));
            chk                     = find(suj_list == suj_number);
            
            if ~isempty(chk)
                fname               = [file_list(nfile).folder filesep file_list(nfile).name];
                fprintf('loading %s\n',fname);
                load(fname);
                tmp                 = [tmp;scores]; clear scores;
                
            end
            
        end
        
        stim_carr                   = squeeze(nanmean(tmp,1));
        
        avg                         = [];
        avg.label                   = {num2str(size(tmp,1))};%{'stim'}; clear tmp;
        avg.time                    = time_axis;
        avg.dimord                  = 'chan_time';
        avg.avg                     = stim_carr; % clear stim_carr; %mean(stim_carr,1);
        
        %         cfg                         = [];
        %         cfg.resamplefs              = 25;
        %         cfg.detrend                 = 'no';cfg.demean = 'no';
        %         avg                         = ft_resampledata(cfg, avg);
        
        alldata{nback+1,nlock+1}    = avg; clear avg
        
    end
end
% end

keep alldata

i                                   = 0;

for nlock = 1:size(alldata,2)
    
    i                               = i + 1;
    subplot(3,1,i)
    hold on;
    
    list_color                      = 'brk';
    
    for nback = 1:size(alldata,1)
        
        plot(alldata{nback,nlock}.time,alldata{nback,nlock}.avg,list_color(nback),'LineWidth',3)
        
        xlim([-0.1 6]);
        ylim([0.5 0.56]);
        title([num2str(nlock) ' LOCK']);
        
        vline(0,'--k');vline(2,'--k');
        vline(4,'--k');hline(0.5,'--k');
        
        xlabel('Time (s)')
        ylabel('AUC')
        
        yticks([0.49 0.56])
        
        set(gca,'FontSize',20,'FontName', 'Calibri');
        
    end
    
    legend({'0B','1B','2B'});
    
end

% i                                   = 0;
%
% for nback = 1:size(alldata,1)
%     for nlock = 1:size(alldata,2)
%
%         i                           = i + 1;
%
%         subplot(3,3,i)
%         cfg                         = [];
%         cfg.ylim                    = [0.49 0.6];
%
%         ft_singleplotER(cfg,alldata{nback,nlock});
%
%         title([num2str(nback-1) ' BACK ' num2str(nlock) ' LOCK ' alldata{nback,nlock}.label{1}]);
%
%         vline(0,'--k');
%         vline(2,'--k');
%         vline(4,'--k');
%         hline(0.5,'--k');
%
%         xlabel('Time (s)')
%         ylabel('AUC')
%
%         set(gca,'FontSize',20,'FontName', 'Calibri');
%
%     end
% end