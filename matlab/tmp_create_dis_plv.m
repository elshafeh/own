clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list        = suj_list(2:22);

for sb = 1:length(suj_list)
    
    suj                                             = suj_list{sb};
    
    for cond_list = {'DIS','fDIS'}
        
        fname_in                                    = ['/Volumes/hesham_megabup/pat22_fieldtrip_data/' suj '.' cond_list{:} '.p100p300.60t100Hz.OriginalPCCMinEvoked0.5cm.mat'];
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
        index_voxels_in                             = find(source.inside==1);
        
        new_source                                  = source;
        new_source.inside                           = source.inside(index_voxels_in);
        new_source.pos                              = source.pos(index_voxels_in);
        new_source.avg.csd                          = source.avg.csd(index_voxels_in);
        new_source.avg.noisecsd                     = source.avg.noisecsd(index_voxels_in);
        new_source.avg.mom                          = source.avg.mom(index_voxels_in);
        new_source.avg.csdlabel                     = source.avg.csdlabel(index_voxels_in);
        
        hw_many_voxels_are_there                    = length(source.inside);
        
        clear source ;
        
        list_method                                 = 'plv';
        fprintf('Computing Connectivity\n');
        
        cfg                                         = [];
        cfg.method                                  = list_method;
        source_conn                                 = ft_connectivityanalysis(cfg, new_source);
        source_conn                                 = source_conn.plvspctrm;
        
        load ../data/index/broadmanAuditoryOccipital_combined.mat;
        
        list_H                                      = 'audLR';
        index_H                                     = index_H(index_H(:,2) > 2,:);
        index_H(:,2)                                = 1;
        trans_index_H                               = h_transform_voxel_inside(index_H);

        ext_index                                   = 'NewBroadAreasZbeforeAvg';
        
        fprintf('Transforming Connectivity\n');
        
        source                                      = source_conn(trans_index_H(:,1),:);
        source                                      = 0.5 .* (log((1+source)./(1-source)));
        source                                      = mean(source)';
        
        tmp_source                                  = zeros(hw_many_voxels_are_there,1);
        tmp_source(index_voxels_in)                 = source;
        source                                      = tmp_source ; clear tmp_source ;
        
        fname                                       = ['../data/new_dis_conn_data/' suj '.' cond_list{:} '.p100p300.60t100Hz.' list_method 'Conn.' ext_index '.mat'];
        
        fprintf('Saving %30s\n',fname);
        
        save(fname,'source','-v7.3');
        
        clearvars -except suj suj_list cond_list sb;
        
    end
end