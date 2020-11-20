clear ; clc;

if isunix
    start_dir             = '/project/';
else
    start_dir             = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName             = suj_list{nsuj};
    list_cond               = {'theta' 'alpha' 'beta' 'gamma'};
    
    for ncond = 1:length(list_cond)
        
        ext_feature         = 'rt'; % 'match' 'correct';
        fname           	= ['I:/bil/coef/' subjectName '.1stcue.lock.' list_cond{ncond} '.centered.decodingresp.' ext_feature '.coef.lcmv.mat'];
        fprintf('loading %50s\n',fname);
        load(fname);
        
        data.avg            = abs(data.avg);
        
        %         t1               	= find(round(data.time,2) == round(5.5,2));
        %         t2               	= find(round(data.time,2) == round(6.1,2));
        
        %         t1               	= find(round(data.time,2) == round(4.7,2));
        %         t2               	= find(round(data.time,2) == round(5.2,2));
        
        t1               	= find(round(data.time,2) == round(4.35,2));
        t2               	= find(round(data.time,2) == round(6.5,2));
        
        bsl              	= nanmean(data.avg,2);
        act              	= nanmean(data.avg(:,t1:t2),2);
        
        alldata(nsuj,ncond,:)            = (act -bsl) ./ bsl;
        
        
    end
end

keep alldata ext_feature list_*

load ../data/stock/template_grid_0.5cm.mat ; close all;

for nview = [1 2 3]
    for ncond = 1:length(list_cond)-1
        
        source              = [];
        source.pow          = nan(length(template_grid.pos),1);
        
        % normalize by gamma
        vct_1               = squeeze(nanmean(alldata(:,ncond,:),1));
        vct_2               = squeeze(nanmean(alldata(:,4,:),1));
        
        vct_data            =  (vct_1 - vct_2);
        
        source.pow(template_grid.inside ==1)          = vct_data; clear vct_*
        
        source.pos          = template_grid.pos;
        source.dim          = template_grid.dim;
        source.inside       = template_grid.inside;
        
        cfg                 = [];
        cfg.method          = 'surface';
        cfg.funparameter   	= 'pow';
        cfg.maskparameter  	= cfg.funparameter;
        cfg.funcolorlim    	= [0 0.1]; % 'zeromax'; % 
        cfg.funcolormap   	= brewermap(256,'Reds');
        cfg.projmethod     	= 'nearest';
        cfg.camlight      	= 'no';
        cfg.surfinflated   	= 'surface_inflated_both_caret.mat';
        %         cfg.projthresh  	= 0.4;
        list_view       	= [-90 0 0; 90 0 0; 0 0 90];
        
        ft_sourceplot(cfg,source);
        view (list_view(nview,:));
        light ('Position',list_view(nview,:));
        material dull
        title([list_cond{ncond} ' ' ext_feature]);
        
        fout = 'D:/Dropbox/project_me/pub/Presentations/bil_update_april/_figures/decoding/coef/';
        fout = [fout 'response.decoding.' ext_feature '.' list_cond{ncond} '.' num2str(nview) '.png'];
        saveas(gcf,fout);
        %         close all;
        
    end
end

 close all;