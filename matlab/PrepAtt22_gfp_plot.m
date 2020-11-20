clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = 'CnD';
        cond_sub            = {'V','N'};
        
        for ncue = 1:length(cond_sub)
            
            fname_in            = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main '.bpOrder2Filt0.2t20Hz.pe.mat'];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in);
            
            cfg                                 = [];
            cfg.method                          = 'amplitude';
            data_pe_gfp                         = ft_globalmeanfield(cfg,data_pe); % calculer gfp
            
            cfg                                 = [];
            cfg.baseline                        = [-0.1 0];
            data_pe_gfp_lb                      = ft_timelockbaseline(cfg,data_pe_gfp);
            
            allsuj_data{ngroup}{sb,ncue,1}      = data_pe_gfp_lb;
            
            cfg                                 = [];
            cfg.baseline                        = [-0.1 0];
            data_pe_lb                          = ft_timelockbaseline(cfg,data_pe);
            
            cfg                                 = [];
            cfg.method                          = 'amplitude';
            data_pe_lb_gfp                      = ft_globalmeanfield(cfg,data_pe_lb);
            
            allsuj_data{ngroup}{sb,ncue,2}      = data_pe_lb_gfp;
            
            
            cfg                                 = [];
            cfg.baseline                        = [-0.1 0];
            data_pe_lb_gfp_lb                   = ft_timelockbaseline(cfg,data_pe_lb_gfp);
            
            allsuj_data{ngroup}{sb,ncue,3}      = data_pe_lb_gfp_lb;

            
            clear data_pe
            
        end
        
    end
    
    for ncue = 1:size(allsuj_data{ngroup},2)
        for ntype = 1:size(allsuj_data{ngroup},3)
            gavg_data{ngroup,ncue,ntype} = ft_timelockgrandaverage([],allsuj_data{ngroup}{:,ncue,ntype});
        end
    end
    
end

clearvars -except *_data cond_sub

figure;
hold on;

i = 0 ;

list_type = {'data pe gfp lb','data pe lb gfp','data pe lb gfp lb'};

for ngroup = 1:size(gavg_data,1)
    for ntype = 1:size(gavg_data,3)
        
        i = i+1;
        
        subplot(size(gavg_data,1),size(gavg_data,3),i)
        
        hold on
        
        for ncue = 1:size(gavg_data,2)
            
            plot(gavg_data{ngroup,ncue,ntype}.time,gavg_data{ngroup,ncue,ntype}.avg,'LineWidth',2);
            
            ylim([-10 60])
            
            xlim([-0.2 1.2])
            
        end
        
        
        legend(cond_sub)
        title(list_type{ntype})
        
    end
    
end

% i = 0 ;
% for ngroup = 1:2
%     for sb = 1:length(allsuj_data{ngroup})
%         i = i + 1;
%         subplot(4,7,i)
%         plot(allsuj_data{ngroup}{sb}.time,allsuj_data{ngroup}{sb}.avg)
%         ylim([0 150])
%         xlim([-0.2 1])
%     end
% end

% for ngroup = 1:2
%     cfg                 =[];
%     cfg.parameter       = 'avg';
%     cfg.operation       ='x1-x2';
%     gavg_data{ngroup,3} = ft_math(cfg,gavg_data{ngroup,1},gavg_data{ngroup,2});
% end
%
% figure;
