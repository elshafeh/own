clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list        = suj_list(2:22);

% suj_group{2}    = {'uc5' 'yc17' 'yc18' 'uc6' 'uc7' 'uc8' 'yc19' 'uc9' ...
%   'uc10' 'yc6' 'yc5' 'yc9' 'yc20' 'yc21' 'yc12' 'uc1' 'uc4' 'yc16' 'yc4'};
% suj_group{3}    = {'mg1' 'mg2' 'mg3' 'mg4' 'mg5' 'mg6' 'mg7' 'mg8' 'mg9' ...
%   'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg16' 'mg17' 'mg18' 'mg19'};
% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% suj_group{4}    = allsuj(2:15,1);
% suj_group{5}    = allsuj(2:15,2);
% suj_list        = [suj_group{1};suj_group{2}';suj_group{3}';suj_group{4};suj_group{5}];
% suj_list        = unique(suj_list);

for sb = 1:length(suj_list)
    
    suj     = suj_list{sb};
    
    list_cond       = {'NCnD'};
    list_time       = {'m600m200','p600p1000'};
    list_freq       = {'7t11Hz'};
    
    list_ext_name   = {'OriginalPCC100SlctMinEvoked*0.5cm'};
    
    for nxtn = 1:length(list_ext_name)
        for ncue = 1:length(list_cond)
            for ntime = 1:length(list_time)
                for nfreq = 1:length(list_freq)
                    
                    fname   = dir(['../data/' suj '/field/' suj '.' list_cond{ncue} '.' list_time{ntime} '.' list_freq{nfreq} '.' list_ext_name{nxtn} '.mat']);
                    fname   = ['../data/' suj '/field/' fname.name];
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
                    
                    hw_many_voxels_are_there    = length(source.inside);
                    
                    clear source ;
                    
                    fprintf('Computing Connectivity\n');
                    
                    list_method                 = {'plv'}; %{'powcorr','coh','plv'};
                    
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
                        
                        load ../data_fieldtrip/index/broadman_based_audio_index.mat;
                        
                        ext_index = 'broadAreas';
                        
                        for nroi = 1:length(list_H)
                            
                            source = source_conn(index_H(index_H(:,2)==nroi,1),:);
                            source = mean(source)';
                            
                            overRide = 'OriginalPCC100SlctMinEvoked0.5cm';  % !!!!!!!!!!!!!!!!!!!!!!
                            
                            fname   = ['../data/' suj '/field/' suj '.' list_cond{ncue} '.' list_time{ntime} '.' list_freq{nfreq} '.' overRide '.' list_H{nroi} '.' cfg.method 'Conn.' ext_index '.mat'];
                            fprintf('Saving %30s\n',fname);
                            save(fname,'source','-v7.3');
                            
                            clear source fname;
                            
                        end
                        
                        clear source_conn i
                        
                    end
                    
                    clear new_source
                    
                end
            end
        end
    end
end