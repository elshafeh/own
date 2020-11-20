clear ; clc ; 

cluster_label       = readtable('~/GoogleDrive/NeuroProj/Fieldtripping/documents/4R/spm/clusters_labels.csv','Delimiter',';');
cluster_label       = cluster_label(:,2:10);

label_names         = table2array(cluster_label);
% cluster_label       = table2array(cluster_label);

for nrow = 1:size(cluster_label,1)
    for ncol = 1:size(cluster_label,2)
        
        cell_name                           = cluster_label{nrow,ncol};
        cell_name(strfind(cell_name,' '))   = '';
        cell_name(strfind(cell_name,'+'))   = '';
        cell_name(strfind(cell_name,'/'))   = '';
        cell_name(strfind(cell_name,'('))   = '';
        cell_name(strfind(cell_name,')'))   = '';

        cluster_label{nrow,ncol}            = cell_name;
        
    end
end

cue_early           = readtable('~/GoogleDrive/NeuroProj/Fieldtripping/documents/4R/spm/cue_600-900_4R.csv');

for n = 1:height(cue_early)
    cue_early(n,6) = {'earlyCNV'};
end

cue_late           = readtable('~/GoogleDrive/NeuroProj/Fieldtripping/documents/4R/spm/cue_900-1200_4R.csv');

for n = 1:height(cue_late)
    cue_late(n,6) = {'lateCNV'};
end

% useless !!