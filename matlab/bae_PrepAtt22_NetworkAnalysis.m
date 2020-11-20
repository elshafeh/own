clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

load ../data_fieldtrip/template/template_grid_0.5cm.mat

for sb = 1:21
    
    suj         = ['yc' num2str(sb)] ;
    
    list_freq   = {'11t15Hz'};
    list_time   = {'m700m200','p600p1100'};
    list_cue    = {'RCnD','LCnD','NCnD'};
    
    name_exta   = '100SlctMinEvoked0.5cm';
    
    for ncue = 1:length(list_cue)
        for nfreq = 1:length(list_freq)
            for ntime = 1:length(list_time)
                
                fname_in = ['../data/' suj '/field/' suj '.' list_cue{ncue} '.' list_time{ntime} '.' list_freq{nfreq} '.OriginalPCC' name_exta '.mat'];
                fprintf('Loading %s\n',fname_in);
                load(fname_in)
                
                fprintf('Computing Connectivity\n');
                
                list_method                 = {'plv','powcorr','coh'};
                
                index_voxels_in             = find(source.inside==1);
                
                old_name_voxels             = [1:length(source.inside)]';
                
                new_source                  = source;
                new_source.inside           = source.inside(index_voxels_in);
                new_source.pos              = source.pos(index_voxels_in);
                new_source.avg.csd          = source.avg.csd(index_voxels_in);
                new_source.avg.noisecsd     = source.avg.noisecsd(index_voxels_in);
                new_source.avg.mom          = source.avg.mom(index_voxels_in);
                new_source.avg.csdlabel     = source.avg.csdlabel(index_voxels_in);
                
                new_name_voxels             = old_name_voxels(index_voxels_in);
                
                hw_many_voxels_are_there    = length(source.inside);
                
                for nmeth = 1:length(list_method)
                    
                    cfg                                         = [];
                    cfg.method                                  = list_method{nmeth};
                    
                    if strcmp(cfg.method,'coh')
                        cfg.complex                             = 'absimag';
                    end
                    
                    source_conn                                 = ft_connectivityanalysis(cfg, new_source);
                    source_conn.dimord                          = 'pos_pos';
                    
                    cfg                                         = [];
                    cfg.method                                  = 'degrees';
                    
                    cfg.parameter                               = [list_method{nmeth} 'spctrm'];
                    
                    cfg.threshold                               = .1;
                    source_net                                  = ft_networkanalysis(cfg,source_conn);
                    
                    new_source_net                              = source_net ;
                    
                    for nvox = 1:length(new_source_net.degrees)
                        
                        ai                              = new_source_net.degrees(nvox);
                        
                        if ai == 0
                            bi = 0;
                        else
                            bi                              = new_name_voxels(ai);
                        end
                        
                        new_source_net.degrees(nvox)    = bi;
                        
                    end
                    
                    network_full                   = zeros(length(source.pos),1);
                    network_full(index_voxels_in)  = new_source_net.degrees;
                    
                    clear new_source_net source_net
                    
                    fname_out = ['../data/' suj '/field/' suj '.' list_cue{ncue} '.' list_time{ntime} '.' list_freq{nfreq} '.' list_method{nmeth} 'Network.' name_exta '.mat'];
                    
                    fprintf('Saving %s\n',fname_out);
                    
                    save(fname_out,'network_full','-v7.3')
                    
                    clear network_full clc ;
                    
                end
            end
        end
    end
end