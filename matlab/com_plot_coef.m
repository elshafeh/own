clear ; close all;

list_suj                                        = [1:4 8:17];
list_data                                       = {'eeg','meg'};
list_feat                                       = {'inf.unf','left.right'};

for ns = 1:length(list_suj)
    for ndata = 1%:2
        for nfeat = 1:length(list_feat)
            
            if ndata == 1
                fname_in                        = ['../data/wt_lcmv/yc' num2str(list_suj(ns)) '.CnD.' list_data{ndata} '.' list_feat{nfeat} '.lp30.wt_lcmv.mat'];
                fprintf('loading %s\n',fname_in);
                load(fname_in);
            else
                
                for npart = 1:3
                    fname_in                    = ['../data/wt_lcmv/yc' num2str(list_suj(ns)) '.pt' num2str(npart) '.CnD.' list_data{ndata} '.' list_feat{nfeat} '.lp30.wt_lcmv.mat'];
                    fprintf('loading %s\n',fname_in);
                    load(fname_in);
                    
                    tmp{npart}                  = data; clear data;
                    
                end
                
                data                            = ft_timelockgrandaverage([],tmp{:}); clear tmp;
                
            end
            
            
            load ../data/template/template_grid_5mm.mat;
            
            win_time                            = 0.2;
            list_time                           = 0:win_time:1;
            
            for ntime = 1:length(list_time)
                
                lm1                             = find(round(data.time,2) == round(-0.1,2));
                lm2                             = find(round(data.time,2) == round(0,2));
                
                bsl                             = mean(abs(data.avg(:,lm1:lm2)),2);
                
                lm1                             = find(round(data.time,2) == round(list_time(ntime),2));
                lm2                             = find(round(data.time,2) == round(list_time(ntime)+win_time,2));
                
                vct                             = data.avg(:,lm1:lm2);
                vct                             = abs(vct);
                vct                             = mean(vct,2);
                
                % baseline correct
                vct                             = (vct - bsl) ./vct;
                vct(vct<0)                      = NaN;
                
                find_in                         = find(template_grid.inside == 1);
                
                source                          = [];
                source.pos                      = template_grid.pos;
                source.dim                      = template_grid.dim;
                source.pow                      = nan(length(source.pos),1);
                
                source.pow(find_in)             = vct; clear vct;
                
                source.inside                   = template_grid.inside;
                
                alldata{ns,ndata,nfeat,ntime}   = source; clear source ;
                
                
            end
            
        end
    end
end

keep alldata list_*

for ndata = 1:size(alldata,2)
    for nfeat = 1:size(alldata,3)
        for ntime = 1:size(alldata,4)
            
            gavg{ndata,nfeat,ntime}            = ft_sourcegrandaverage([],alldata{:,ndata,nfeat,ntime});
            
        end
    end
end

keep alldata list_* gavg

list_side                                       = [1 2];

for ndata = 1:size(gavg,1)
    for nfeat = 1:size(gavg,2)
        for ntime = 1:size(gavg,3)
            for i = 1:length(list_side)
                dataplot                        = gavg{ndata,nfeat,ntime};
                
                flg                             = list_side(i);
                
                lst_side                        = {'left','right','both'};
                lst_view                        = [-95 1;95 1;0 10];
                
                cfg                             = [];
                cfg.method                      = 'surface';
                cfg.funparameter                = 'pow';
                
                cfg.maskparameter               = cfg.funparameter;
                
                cfg.opacitylim                  = [0 1];
                cfg.funcolorlim                 = cfg.opacitylim;
                
                cfg.camlight                    = 'no';
                
                cfg.funcolormap                 = brewermap(256,'*Spectral');
                
                cfg.opacitymap                  = 'rampup';
                cfg.projmethod                  = 'nearest';
                
                %                 cfg.projthresh                  = 0.8;
                
                cfg.surffile                    = ['surface_white_' lst_side{flg} '.mat'];
                cfg.surfinflated                = ['surface_inflated_' lst_side{flg} '_caret.mat'];
                ft_sourceplot(cfg, dataplot);
                
                view(lst_view(flg,:));
                
                title([list_data{ndata} '.' list_feat{nfeat}]);
                
            end
        end
    end
end