clear ; clc; close all;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName             = suj_list{nsuj};
    list_cond               = {'theta' 'alpha' 'beta'};
    
    for ncond = 1:length(list_cond)
        
        list_feature        = {'orientation' 'frequency'};
        
        tmp                 = [];
        ext_feature         = list_feature{2};
        
        fname           	= ['I:/bil/coef/' subjectName '.1stgab.lock.' list_cond{ncond} '.centered.decodinggabor.' ext_feature '.correct.coef.lcmv.mat'];
        fprintf('loading %50s\n',fname);
        load(fname);
        tmp(1,:,:)          = abs(data.avg);
        
        fname           	= ['I:/bil/coef/' subjectName '.2ndgab.lock.' list_cond{ncond} '.centered.decodinggabor.' ext_feature '.correct.coef.lcmv.mat'];
        fprintf('loading %50s\n',fname);
        load(fname);
        tmp(2,:,:)          = abs(data.avg);
        
        data.avg            = squeeze(mean(tmp,1));         
        
        if strcmp(ext_feature,'orientation')
            tm_1          	= 0.05; 
            tm_2          	= 0.4; 
        elseif strcmp(ext_feature,'frequency')
            tm_1          	= 0.05;
            tm_2          	= 0.75;
        end
        
        t1                  = find(round(data.time,2) == round(tm_1,2)); 
        t2                  = find(round(data.time,2) == round(tm_2,2)); 
        
        b1                  = find(round(data.time,2) == round(-0.1,2));
        b2                  = find(round(data.time,2) == round(0,2));

        bsl              	= nanmean(data.avg(:,b1:b2),2);
        act              	= nanmean(data.avg(:,t1:t2),2);
        
        alldata(nsuj,ncond,:)            = (act-bsl) ./ bsl;
        
        
    end
end

keep alldata ext_feature list_*; close all;

load ../data/stock/template_grid_0.5cm.mat ; close all;

list_z                      = [1 0.2 0.2];

for nview = [1 2]
    for ncond = 1:length(list_cond)
        
        source              = [];
        source.pow          = nan(length(template_grid.pos),1);
        
        % normalize by gamma
        vct_1               = squeeze(nanmean(alldata(:,ncond,:),1));
                
        source.pow(template_grid.inside ==1)          = vct_1; clear vct_* 
        
        source.pos          = template_grid.pos;
        source.dim          = template_grid.dim;
        source.inside       = template_grid.inside;
        
        cfg                 = [];
        cfg.method          = 'surface';
        cfg.funparameter   	= 'pow';
        cfg.maskparameter  	= cfg.funparameter;
        cfg.funcolorlim    	= [0 list_z(ncond)]; 
        cfg.funcolormap   	= brewermap(256,'Reds');
        cfg.projmethod     	= 'nearest';
        cfg.camlight      	= 'no';
        cfg.surfinflated   	= 'surface_inflated_both_caret.mat';
        list_view       	= [-90 0 0; 90 0 0; 0 0 90];
        
        ft_sourceplot(cfg,source);
        view (list_view(nview,:));
        light ('Position',list_view(nview,:));
        material dull
        title([list_cond{ncond} ' ' ext_feature]);
        
        fout = 'D:/Dropbox/project_me/pub/Presentations/bil_update_april/_figures/decoding/coef/grating/';
        fout = [fout 'grating.decoding.' ext_feature '.' list_cond{ncond} '.' num2str(nview) '.png'];
        saveas(gcf,fout);
        
    end
end