clear ;

suj_list                        = [1:4 8:17];

for ns = 1:length(suj_list)
    for nd = 1:2
        for nf = 1:2
            
            list_data               = {'eeg','meg'};
            list_feat               = {'inf.unf','left.right'};
            
            if strcmp(list_data{nd},'eeg')
                
                fname               = ['/Volumes/heshamshung/alpha_compare/decode/topo/yc' num2str(suj_list(ns)) '.CnD.' list_data{nd} '.' list_feat{nf} '.auc.topo.mat'];
                fprintf('loading %s\n',fname);
                load(fname);
                
                fname               = ['/Volumes/heshamshung/alpha_compare/preproc_data/yc' num2str(suj_list(ns)) '.CnD.' list_data{nd} '.sngl.dwn100.mat'];
                fprintf('loading %s\n',fname);
                load(fname);
                
                lm1                 = find(round(data.time{1},2) == round(-0.1,2));
                lm2                 = find(round(data.time{1},2) == round(2,2));
                
                avg                 = [];
                avg.label           = data.label;
                avg.dimord          = 'chan_time';
                avg.time            = data.time{1}(lm1+1:lm2);
                avg.avg             = scores;
                
                alldata{ns,nd,nf}   = avg; clear avg;
                
            else
                
                for np = 1:3
                    
                    fname           = ['/Volumes/heshamshung/alpha_compare/decode/topo/yc' num2str(suj_list(ns)) '.pt' num2str(np) '.CnD.' list_data{nd} '.' list_feat{nf} '.auc.topo.mat'];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    
                    fname           = ['/Volumes/heshamshung/alpha_compare/preproc_data/yc' num2str(suj_list(ns)) '.pt' num2str(np) '.CnD.' list_data{nd} '.sngl.dwn100.mat'];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    
                    lm1             = find(round(data.time{1},2) == round(-0.1,2));
                    lm2             = find(round(data.time{1},2) == round(2,2));
                    
                    avg             = [];
                    avg.label       = data.label;
                    avg.dimord      = 'chan_time';
                    avg.time        = data.time{1}(lm1+1:lm2);
                    avg.avg         = scores;
                    
                    src_car{np}     = avg; clear avg;
                    
                end
                
                alldata{ns,nd,nf}   = ft_timelockgrandaverage([],src_car{:}); clear src_car;
                
            end
            
            fprintf('\n');
            
        end 
    end
end

keep alldata list_data list_feat

for nd = 1:2
    for nf = 1:2
        gavg{nd,nf}                 = ft_timelockgrandaverage([],alldata{:,nd,nf});
    end
end

i                                   = 0 ;

for nf = 1:2
    for nd = 1:2
        time_win                    = 0.2;
        list_time                   = 0:time_win:2-time_win;
        
        for ntime = 1:length(list_time)
            
            list_layout             = {'elan_lay.mat','CTF275_helmet.lay'};
            
            cfg                     =[];
            cfg.layout              = list_layout{nd};
            cfg.colormap            = brewermap(256, '*Spectral');
            cfg.comment             = 'no';
            
            cfg.zlim                = [0.5 0.53];
            
            cfg.marker              = 'off';
            cfg.xlim                = [list_time(ntime) list_time(ntime)+time_win];
            
            i                       = i + 1;
            nrow                    = 4;
            ncol                    = length(list_time);
            
            subplot(nrow,ncol,i);
            
            ft_topoplotER(cfg,gavg{nd,nf});clc;
            
        end
    end
end

% figure;
% cfg.colorbar                        = 'yes';
% ft_topoplotER(cfg,gavg{nd,nf});
% set(gca,'FontSize',20,'FontName', 'Calibri');