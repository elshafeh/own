clear ; clc; close all;

if isunix
    project_dir                             = '/project/3015079.01/';
else
    project_dir                             = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                             = suj_list{nsuj};
    list_window                             = {'p4300p5500' };
    
    for ntime = 1:length(list_window)
        
        source_avg                          = [];
        list_time                           = {'' list_window{ntime}};
        load('../data/stock/template_grid_0.5cm.mat');
        
        for nbin    = [1 2 3 4 5]
            
            ext_source                      = ['1t5Hz.bin' num2str(nbin) '.withincorrect.pccsource'];
            
            fname                           = [project_dir 'data/' subjectName '/source/' subjectName '.itc.' ...
                list_time{2} '.' ext_source '.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            act = plf; clear plf;
            
            source                      	= [];
            source.pos                   	= template_grid.pos;
            source.dim                  	= template_grid.dim;
            source.pow                    	= (act); %- bsl);
            
            tmp{nbin}                       = source; clear source;
            source_avg                      = [source_avg tmp{nbin}.pow];
            
        end
        
        for nbin = 1:5
            act                          	= tmp{nbin}.pow;
            bsl                          	= nanmean(source_avg,2);
            alldata{nsuj,nbin,ntime}        = tmp{nbin};
            alldata{nsuj,nbin,ntime}.pow   	= (act - bsl);% ./ bsl; clear act bsl
        end
        
        clear tmp
        
    end
end

clearvars -except alldata list_window allpoints ; close all;

list_view                                   = [-90 0 0; 90 0 0; 0 0 90];

for nview = [1 2]
    
    cfg                                     = [];
    cfg.method                              = 'surface';
    cfg.funparameter                        = 'pow';
    cfg.maskparameter                       = cfg.funparameter;
    cfg.funcolorlim                         = [-0.05 0.05];
    cfg.funcolormap                         = brewermap(256,'*RdBu');%'Reds');
    cfg.projmethod                          = 'nearest';
    cfg.camlight                            = 'no';
    cfg.surfinflated                        = 'surface_inflated_both_caret.mat';
    %     cfg.projthresh                          = 0.4;
    
    for ntime = 1:length(list_window)
        for nbin = [1 5]
            
            ft_sourceplot(cfg, ft_sourcegrandaverage([],alldata{:,nbin,ntime}));
            view (list_view(nview,:));
            light ('Position',list_view(nview,:));
            material dull
            title(['bin' num2str(nbin) ' ' list_window{ntime}]);
            saveas(gcf,['D:\Dropbox\project_me\pub\Papers\postdoc\bilbo_manuscript_v1\_figures\_prep\source\itc\sortedbins.' ...
                list_window{ntime} '.b' num2str(nbin) '.v' num2str(nview) '.png']);
            %             close all;
            
        end
    end
end