clear ; clc ; 

indx_list = {'DIS'};

for i = 1:2
    
    load('../data/yctot/index/Frontal.mat');
    load(['../data/yctot/stat/' indx_list{i} '.Alphastat4Arsenal.mat']);
    
    tmp = [];
    
    llist = [79 80 81 82];
    
    for r_list = 1:length(llist)
        [vox_list,vox_indx] = h_findStatMaxVoxelPerRegion(stat,0.05,llist(r_list),5);
        tmp                 = [tmp ; vox_indx repmat(llist(r_list),length(vox_indx),1)];
        clear vox_list vox_indx
    end
    
    %     if strcmp(indx_list{i},'nDT')
    %         tmp(:,2) = 1;
    %         indx_arsenal(:,2) = indx_arsenal(:,2)+1;
    %         list_arsenal = ['audR' list_arsenal];
    %     else
    %     end
    
    tmp(tmp(:,2) == 79 | tmp(:,2) == 81,2) = 1;
    tmp(tmp(:,2) == 80 | tmp(:,2) == 82,2) = 2;
    
    indx_arsenal(:,2)   = indx_arsenal(:,2)+2;
    list_arsenal        = ['audL' 'audR' list_arsenal];

    tmp= sortrows(tmp,2);
    
    indx_arsenal = [tmp;indx_arsenal];
    
    clearvars -except *arsenal* indx_list i
    
    save(['../data/yctot/stat/' indx_list{i} '.Index4Alpha.mat'],'indx_arsenal','list_arsenal');
    
end