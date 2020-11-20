clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list        = suj_list(2:22);

for sb = 1:length(suj_list)
    
    suj                = suj_list{sb};
    
    for cond_main = {'fDIS','DIS'}
        
        fname_in                    = ['/Volumes/hesham_megabup/pat22_fieldtrip_data/' suj '.' cond_main{:} '.p100p300.60t100Hz.OriginalPCCMinEvoked0.5cm.mat'];
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
        index_voxels_in             = find(source.inside==1);
        
        new_source                  = source;
        new_source.inside           = source.inside(index_voxels_in);
        new_source.pos              = source.pos(index_voxels_in);
        new_source.avg.csd          = source.avg.csd(index_voxels_in);
        new_source.avg.noisecsd     = source.avg.noisecsd(index_voxels_in);
        new_source.avg.mom          = source.avg.mom(index_voxels_in);
        new_source.avg.csdlabel     = source.avg.csdlabel(index_voxels_in);
        
        hw_many_voxels_are_there    = length(source.inside);
        
        clear source ;
        
        fprintf('Computing Connectivity\n');
        
        list_method                 = {'plv','coh'};
        
        for nmeth = 1:length(list_method)
            
            cfg                                         = [];
            cfg.method                                  = list_method{nmeth};
            
            if strcmp(cfg.method,'coh')
                cfg.complex                             = 'absimag';
            end
            
            source_conn                                 = ft_connectivityanalysis(cfg, new_source);
            
            new_conn                                    = zeros(hw_many_voxels_are_there,hw_many_voxels_are_there);
            
            if strcmp(cfg.method,'coh')
                new_conn(index_voxels_in,index_voxels_in)   = source_conn.cohspctrm;
            elseif strcmp(cfg.method,'plv')
                new_conn(index_voxels_in,index_voxels_in)   = source_conn.plvspctrm;
            elseif strcmp(cfg.method,'powcorr')
                new_conn(index_voxels_in,index_voxels_in)   = source_conn.powcorrspctrm;
            end
            
            source_conn                                 = new_conn ;
            
            clear new_conn;
            
            load ../data_fieldtrip/index/broadmanAuditoryOccipital_combined.mat;
            
            ext_index = 'AuditoryCircMean';
            
            for nroi = 1:length(list_H)
                
                source  = source_conn(index_H(index_H(:,2)==nroi,1),:);
                
                source  = circ_mean(source)';
                
                fname   = ['../data/circ_mean_dis_conn/' suj '.' '.' cond_main{:} '.p100p300.60t100Hz.' list_H{nroi} '.' cfg.method 'Conn.' ext_index '.mat'];
                
                fprintf('Saving %30s\n',fname);
                
                save(fname,'source','-v7.3');
                
                clear source fname;
                
            end
            
            clear source_conn i
            
        end
    end
end