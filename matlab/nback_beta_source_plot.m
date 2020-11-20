clear ; global ft_default
ft_default.spmversion   = 'spm12';

suj_list                                                            = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    subjectname                                                     = ['sub' num2str(suj_list(nsuj))];
    list_time                                                       = {'m1000m0','p150p1150'};
    
    load('../data/stock/template_grid_0.5cm.mat');
    
    for nsession = 1:2
        for nback = [1 2 3]
            
            chk                                                     = dir(['J:/temp/nback/data/source/beta/' subjectname '.session' num2str(nsession) '.' num2str(nback-1) 'back.*.dics.mat']);
            
            if ~isempty(chk)
                
                for ntime = 1:length(list_time)
                    
                    fname                                           = dir(['J:/temp/nback/data/source/beta/' subjectname '.session' num2str(nsession) '.' num2str(nback-1) 'back.*.' list_time{ntime} '.dics.mat']);
                    fprintf('loading %s\n',fname.name);
                    load([fname.folder filesep fname.name]);
                    
                    source.pos                                      = template_grid.pos;
                    source.dim                                      = template_grid.dim;
                    
                    if ntime == 1 % keep first as baseline
                        bsl                                         = source.pow;
                    else
                        source.pow                                  = (source.pow - bsl) ./ bsl;
                        alldata{nsuj,nsession,nback,ntime-1}        = source;
                    end
                    
                    clear source
                    
                end
            end
        end
    end
    
    list_time                                       = list_time(2:end);
    
end

clearvars -except alldata list_time;

for nsuj = 1:size(alldata,1)
    for nback = 1:size(alldata,3)
        for ntime = 1:size(alldata,4)
            
            pow_1                                   = alldata{nsuj,1,nback,ntime};
            pow_2                                   = alldata{nsuj,2,nback,ntime};
            
            if isempty(pow_1)
                newdata{nsuj,nback,ntime}           = alldata{nsuj,2,nback,ntime};
            elseif isempty(pow_2)
                newdata{nsuj,nback,ntime}           = alldata{nsuj,1,nback,ntime};
            else
                newdata{nsuj,nback,ntime}           = ft_sourcegrandaverage([],alldata{nsuj,:,nback,ntime});
            end
            
            if isempty(newdata{nsuj,nback,ntime})
                error('empty struct found!');
            end
            
            clear pow_1 pow_2
            
        end
    end
end

alldata                                     = newdata; clear newdata;

clearvars -except alldata list_time;

for nback = 1:size(alldata,2)
    for ntime = 1:size(alldata,3)
        gavg{nback,ntime}                   = ft_sourcegrandaverage([],alldata{:,nback,ntime});
    end
end

new_gavg{1}         = gavg{1};
new_gavg{2}         = gavg{1};
new_gavg{3}         = gavg{1};

new_gavg{1}.pow     = gavg{1,1}.pow - gavg{2,1}.pow;
new_gavg{2}.pow     = gavg{1,1}.pow - gavg{3,1}.pow;
new_gavg{3}.pow     = gavg{2,1}.pow - gavg{3,1}.pow;

list_test = {'0v1','0v2','1v2'};

keep alldata gavg list_time new_gavg list_test;
close all;

for ncond = 1:3
    
    cfg = [];
    cfg.method                              = 'surface';
    cfg.funparameter                        = 'pow';
    cfg.maskparameter                       = cfg.funparameter;
    cfg.funcolorlim                         = [-0.05 0.05];
    cfg.funcolormap                         = brewermap(256,'*RdBu');
    cfg.projmethod                          = 'nearest';
    cfg.camlight                            = 'no';
    cfg.surfinflated                        = 'surface_inflated_both_caret.mat';
    %     cfg.projthresh                          = 0.8;
    
    ft_sourceplot(cfg, new_gavg{ncond});
    view ([-90 0 0]);
    light ('Position',[-90 0 0]);
    material dull
    
    title(list_test{ncond});
    saveas(gcf,['D:/Dropbox/project_me/pub/Papers/postdoc/nback_manuscript/_figures/dics/beta2.source.' list_test{ncond} '.left.png']);
    %     saveas(gcf,['D:/Dropbox/project_me/pub/Papers/postdoc/nback_manuscript/_figures/dics/alpha.source.' num2str(nback-1) 'back.left.png']);
    %     close all;
    %     title([ num2str(nback-1) 'back']);
    
    ft_sourceplot(cfg, new_gavg{ncond});
    view ([90 0 0]);
    light ('Position',[90 0 0]);
    material dull
    title(list_test{ncond});
    
    saveas(gcf,['D:/Dropbox/project_me/pub/Papers/postdoc/nback_manuscript/_figures/dics/beta2.source.' list_test{ncond} '.right.png']);
    %     close all;
    
end