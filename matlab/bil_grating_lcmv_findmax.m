clear ; clc; close all;

if isunix
    project_dir                     = '/project/3015079.01/';
else
    project_dir                     = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = [10 20 33]
    
    subjectName                 	= suj_list{nsuj};
    
    list_time                    	= {'m100m0ms','p200p300ms'}; % p80p180ms
    
    load('../data/stock/template_grid_1cm.mat');
    
    ext_source                      = 'lcmvsource.1cmWithNas';
    dir_in                          = 'I:\bil\source\';
    ext_lock                        = '.gratinglock.';
    
    fname                           = [dir_in subjectName ext_lock list_time{1} '.' ext_source '.mat'];
    fprintf('loading %s\n',fname);
    load(fname); bsl = source; clear source;
    
    fname                           = [dir_in subjectName ext_lock list_time{2} '.' ext_source '.mat'];
    fprintf('loading %s\n',fname);
    load(fname); act = source; clear source;
    
    source                      	= [];
    source.pos                   	= template_grid.pos;
    source.dim                  	= template_grid.dim;
    source.pow                    	= nan(length(source.pos),1);
    
<<<<<<< HEAD
    vct_data                        = abs((act - bsl) ./ bsl); % rel change 
=======
    find_left                       = find(source.pos(:,1) < 0);
    find_rite                       = find(source.pos(:,1) > 0);
    
>>>>>>> 2cdc2bac5af9f56aae694f74a626225fa09bf808
    max_vox                         = [];
    
    % find max left
    vct_data                        = abs((act - bsl) ./ bsl);
    
    for nvox = 1
        fnd_vox                     = find(vct_data==nanmax(vct_data));
        vct_data(fnd_vox)           = NaN;
        source.pow(fnd_vox)         = 1;
        max_vox                     = [max_vox;fnd_vox];clear fnd_vox;
    end
    
    [roi_pos,roi_name]              = xlsread('M:/github/me/doc/wallis_roi.xlsx');
    roi_pos                         = round(roi_pos ./ 10);
    
    for n = 1:length(roi_pos)
        
        vct                         = source.pos;
        fnd_vox                  	= find(vct(:,1) == roi_pos(n,1) & vct(:,2) == roi_pos(n,2) & vct(:,3) ==roi_pos(n,3));
        source.pow(fnd_vox)         = 1;
        max_vox                     = [max_vox;fnd_vox];clear fnd_vox;
        
    end
    
    
    index_name                      = [{'max occ'};roi_name];
    index_vox                       = max_vox;
    
    fname_out                       = ['I:/bil/source/' subjectName '.wallis.index.mat'];
    fprintf('saving %s\n\n',fname_out);
    save(fname_out,'index_name','index_vox');
    
    keep nsuj suj_list
    
    %     % find max left
    %     vct_data                        = abs((act - bsl) ./ bsl);
    %     vct_data(find_rite)             = NaN;
    
    % find max right
    %     vct_data                        = abs((act - bsl) ./ bsl);
    %     vct_data(find_left)             = NaN;
    %
    %     for nvox = 1
    %         fnd_vox                     = find(vct_data==nanmax(vct_data));
    %         if source.pos(fnd_vox,1) ~= 0
    %             source.pow(fnd_vox)         = 1;
    %             max_vox                     = [max_vox;fnd_vox];clear fnd_vox;
    %         end
    %     end
    
    %     fname_out                       = ['I:/bil/source/' subjectName '.gratinglock.max2vox.mat'];
    %     fprintf('saving %s\n',fname_out);
    %     save(fname_out,'max_vox');
    %
    %     source.pos(max_vox,:)
    %
    %     cfg                             = [];
    %     cfg.method                      = 'surface';
    %     cfg.funparameter             	= 'pow';
    %     cfg.maskparameter              	= cfg.funparameter;
    %     cfg.funcolorlim                	= [0 1];
    %     cfg.funcolormap                	= brewermap(256,'Reds');
    %     cfg.projmethod                	= 'nearest';
    %     cfg.camlight                   	= 'no';
    %     cfg.surfinflated              	= 'surface_inflated_both_caret.mat';
    %     list_view                   	= [0 0 90];
    %     ft_sourceplot(cfg, source);
    %     view ([-1 20]);
    %     material dull
    %     title(subjectName);
    
end