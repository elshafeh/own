clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

for sb = 1:21
    
    suj             = ['yc' num2str(sb)];
    list_cond       = {'LNCnD','RNCnD','LCnD','RCnD','CnD'};
    list_time       = {'m600m200','p600p1000'};
    list_freq       = {'7t11Hz','11t15Hz'};
    
    ext_name        = 'OriginalPCC.0.5cm';
    
    for ncue = 1:length(list_cond)
        for ntime = 1:length(list_time)
            for nfreq = 1:length(list_freq)
                
                
                fname   = ['../data/' suj '/field/' suj '.' list_cond{ncue} '.' list_time{ntime} '.' list_freq{nfreq} '.' ext_name '.mat'];
                fprintf('Loading %30s\n',fname);
                load(fname);
                
                index_voxels_in             = find(source.inside==1);
                
                new_source                  = source;
                new_source.inside           = source.inside(index_voxels_in);
                new_source.pos              = source.pos(index_voxels_in);
                new_source.avg.csd          = source.avg.csd(index_voxels_in);
                new_source.avg.noisecsd     = source.avg.noisecsd(index_voxels_in);
                new_source.avg.mom          = source.avg.mom(index_voxels_in);
                new_source.avg.csdlabel     = source.avg.csdlabel(index_voxels_in);

                fprintf('Computing Connectivity\n');
                
                cfg                         = [];
                cfg.method                  = 'plv';
                source_conn                 = ft_connectivityanalysis(cfg, new_source);
                
                new_conn                                    = zeros(length(source.inside),length(source.inside));
                new_conn(index_voxels_in,index_voxels_in)   = source_conn.plvspctrm;
                
                source_conn                 = new_conn ; clear new_conn source index_voxels_in;
                
                load ../data_fieldtrip/index/0.5cm_LowAlphaLateWindowSourceContrast_auditory.mat
                
                ext_index = 'allYcLowAlphaIndex';
                
                for nroi = 1:length(list_H)
                    
                    source = source_conn(index_H(index_H(:,2)==nroi,1),:);
                    source = mean(source)';
                    
                    fname   = ['../data/' suj '/field/' suj '.' list_cond{ncue} '.' list_time{ntime} '.' list_freq{nfreq} '.' ext_name '.' list_H{nroi} '.' cfg.method 'Conn.' ext_index '.mat'];
                    fprintf('Saving %30s\n',fname);
                    save(fname,'source','-v7.3');
                    
                    clear source fname;
                    
                end
                
                clear source_conn i 
                
            end
        end
    end
    
    clearvars -except sb
    
end