clear ; clc ;

global ft_default
ft_default.spmversion = 'spm12';

[~,allsuj,~]    = xlsread('../../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{2}    = allsuj(2:15,1);
suj_group{1}    = allsuj(2:15,2);

lst_group       = {'Young','Old'};

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        ext_name                = 'AV.1t20Hz.M.1t40Hz.m800p2000msCov.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvoked';
        list_ix                 = 'CnD';
        
        fname_in                = ['../../data/ageing_data/' suj '.' list_ix '.' ext_name '.mat'];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        cfg                     = [];
        cfg.baseline            = [-0.6 -0.2];
        cfg.baselinetype        = 'relchange';
        freq                    = ft_freqbaseline(cfg,freq);
        
        list_iaf                = ageingrev_infunc_iaf(freq);
        
        allsuj_data{sb,ngroup}  = ageingrev_infunc_adjustiaf(freq,list_iaf,0);
        
        clear freq list_iaf;
        
    end
end

for ngroup = 1:size(allsuj_data,2)
    grand_average{ngroup,1}     = ft_timelockgrandaverage([],allsuj_data{:,ngroup});
end

clearvars -except allsuj_data grand_average lst_group

i                           = 0;
list_color                  = 'br';

for nchan = [1 3 5]
    
    i = i + 1;
    subplot(1,3,i)
    
    hold on
    
    for ngr = 1:2
        
        data        = squeeze(grand_average{ngr,1}.avg(nchan,:));
        plot(grand_average{ngr,1}.time,data,list_color(ngr),'LineWidth',2);
        
        data        = squeeze(grand_average{ngr,1}.avg(nchan+1,:));
        plot(grand_average{ngr,1}.time,data,['--' list_color(ngr)],'LineWidth',2);
        
    end
    
    xlim([-0.2 1.2]);
    ylim([-0.55 0.55]);
    
    vline(0,'--k');
    %     vline(1.2,'--k');
    hline(0,'--k');
    
    title(grand_average{1,1}.label{nchan}(1:3))
    
end

% i                           = 0;
% 
% for nchan = 1:length(grand_average{1,1}.label)
%     
%     i = i + 1;
%     subplot(3,2,i)
%     
%     data(1,:) = squeeze(grand_average{1,1}.avg(nchan,:));
%     data(2,:) = squeeze(grand_average{2,1}.avg(nchan,:));
%     
%     plot(grand_average{1,1}.time,data,'LineWidth',5);
%     
%     xlim([-0.2 2]);
%     ylim([-0.55 0.55]);
%     
%     vline(0,'--k');
%     vline(1.2,'--k');
%     hline(0,'--k');
%     
%     if i == 6
%     legend(lst_group)
%     end
%     
%     title(grand_average{1,1}.label{nchan});
%     grid;
%     
%     clear data;
%     
% end