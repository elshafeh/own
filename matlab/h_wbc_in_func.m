function h_wbc_in_func(suj,cond_main,data_concat,big_elan,leadfield,vol,grid)

dir_data                                        = '/Volumes/hesham_megabup/pat22_fieldtrip_data/';

list_extra.name                                 = {'MinEvokedGamma'}; % ,'MinEvokedAlpha'};
list_extra.filt.toi                             = [-0.2 0.4;-0.2 0.7];
list_extra.filt.foi                             = [80 30; 10 4];
list_extra.wind.toi                             = [0.1 0.2;0.35 0.3];
list_extra.wind.foi                             = [80 20; 10 3];

for taper_type = {'dpss','hanning'}
    for n_ex      = 1:length(list_extra.name)
        
        cfg                     = [];
        cfg.toilim              = list_extra.filt.toi(n_ex,:);
        poiCommon               = ft_redefinetrial(cfg, data_concat);
        
        cfg                     = [];
        cfg.method              = 'mtmfft';
        cfg.output              = 'fourier';
        cfg.keeptrials          = 'yes';
        cfg.taper               = taper_type{:};
        cfg.foi                 = list_extra.filt.foi(n_ex,1);
        cfg.tapsmofrq           = list_extra.filt.foi(n_ex,2);
        freqCommon              = ft_freqanalysis(cfg,poiCommon);
        
        clear poiCommon
        
        cfg                     = [];
        cfg.frequency           = freqCommon.freq;
        cfg.method              = 'pcc';
        cfg.grid                = leadfield;
        cfg.headmodel           = vol;
        cfg.keeptrials          = 'yes';
        cfg.pcc.lambda          = '5%';
        cfg.pcc.projectnoise    = 'yes';
        cfg.pcc.keepfilter      = 'yes';
        cfg.pcc.fixedori        = 'yes';
        source                  = ft_sourceanalysis(cfg, freqCommon);
        com_filter              = source.avg.filter;
        
        clear source
        
        for ndis = 1:length(cond_main)
            
            cfg                                         = [];
            data_elan                                   = ft_selectdata(cfg, big_elan{ndis});
            
            tlist                                       = list_extra.wind.toi(n_ex,1);
            twin                                        = list_extra.wind.toi(n_ex,2);
            flist                                       = list_extra.wind.foi(n_ex,1);
            fpad                                        = list_extra.wind.foi(n_ex,2);
            tpad                                        = 0;
            
            for nfreq = 1:length(flist)
                for ntime = 1:length(tlist)
                    
                    list_ix_cue_side{1}                 = {'','N','L','R'};
                    list_ix_cue_code{1}                 = {0:2,0,1,2};
                    list_ix_dis_code{1}                 = {1:2,1:2,1:2,1:2};
                    list_ix_tar_code{1}                 = {1:4,1:4,1:4,1:4};
                    
                    %                     list_ix_cue_side{2}                 = {'V1','R1','L1','N1','1'};
                    %                     list_ix_cue_code{2}                 = {[1 2],2,1,0,0:2};
                    %                     list_ix_dis_code{2}                 = {1,1,1,1,1};
                    %                     list_ix_tar_code{2}                 = {1:4,1:4,1:4,1:4,1:4};
                    
                    for ncue = 1:length(list_ix_cue_side{n_ex})
                        
                        cfg                             = [];
                        cfg.toilim                      = [tlist(ntime)-tpad tlist(ntime)+tpad+twin(ntime)];
                        cfg.trials                      = h_chooseTrial(data_elan,list_ix_cue_code{n_ex}{ncue},list_ix_dis_code{n_ex}{ncue},list_ix_tar_code{n_ex}{ncue});
                        poi                             = ft_redefinetrial(cfg, data_elan);
                        
                        poi                             = h_removeEvoked(poi);
                        
                        cfg                             = [];
                        cfg.method                      = 'mtmfft';
                        cfg.output                      = 'fourier';
                        cfg.keeptrials                  = 'yes';
                        cfg.taper                       = taper_type{:};
                        cfg.foi                         = flist(nfreq);
                        cfg.tapsmofrq                   = fpad(nfreq);
                        freq                            = ft_freqanalysis(cfg,poi);
                        
                        if tlist(ntime) < 0
                            ext_ext= 'm';
                        else
                            ext_ext='p';
                        end
                        
                        ext_time                        = [ext_ext num2str(abs(tlist(ntime)*1000)) ext_ext num2str(abs((tlist(ntime)+twin(ntime))*1000))];
                        ext_freq                        = [num2str(flist(nfreq)-cfg.tapsmofrq) 't' num2str(flist(nfreq)+cfg.tapsmofrq) 'Hz'];
                        
                        cfg                             = [];
                        cfg.frequency                   = freq.freq;
                        cfg.method                      = 'pcc';
                        cfg.grid                        = leadfield;
                        cfg.grid.filter                 = com_filter;
                        cfg.headmodel                   = vol;
                        cfg.keeptrials                  = 'yes';
                        cfg.pcc.lambda                  = '5%';
                        cfg.pcc.projectnoise            = 'yes';
                        source                          = ft_sourceanalysis(cfg, freq);
                        source.pos                      = grid.MNI_pos;
                        
                        source                          = rmfield(source,'cfg');
                        source                          = rmfield(source,'method');
                        source                          = rmfield(source,'trialinfo');
                        source                          = rmfield(source,'freq');
                        
                        index_voxels_in                 = find(source.inside==1);
                        
                        new_source                      = source;
                        new_source.inside               = source.inside(index_voxels_in);
                        new_source.pos                  = source.pos(index_voxels_in);
                        new_source.avg.csd              = source.avg.csd(index_voxels_in);
                        new_source.avg.noisecsd         = source.avg.noisecsd(index_voxels_in);
                        new_source.avg.mom              = source.avg.mom(index_voxels_in);
                        new_source.avg.csdlabel         = source.avg.csdlabel(index_voxels_in);
                        
                        hw_many_voxels_are_there        = length(source.inside);
                        
                        clear source ;
                        
                        fprintf('Computing Connectivity\n');
                        
                        list_method                 = {'plv'};
                        
                        for nmeth = 1:length(list_method)
                            
                            cfg                                         = [];
                            cfg.method                                  = list_method{nmeth};
                            
                            if strcmp(cfg.method,'coh')
                                cfg.complex                             = 'absimag';
                            end
                            
                            source_conn                                 = ft_connectivityanalysis(cfg, new_source);
                            
                            if strcmp(cfg.method,'coh')
                                new_conn                                = source_conn.cohspctrm;
                            elseif strcmp(cfg.method,'plv')
                                new_conn                                = source_conn.plvspctrm;
                            elseif strcmp(cfg.method,'powcorr')
                                new_conn                                = source_conn.powcorrspctrm;
                            end
                            
                            source_conn                                 = new_conn ;
                            
                            clear new_conn;
                            
                            load ../data/index/broadmanAuditoryOccipital_combined.mat;
                            
                            index_H                                     = index_H(index_H(:,2) > 2,:);
                            index_H(:,2)                                = index_H(:,2)-2;
                            
                            new_index                                   = index_H;
                            new_index(:,2)                              = 3;
                            index_H                                     = [index_H;new_index];
                            
                            list_H                                      = {'audL','audR','audLR'};
                            
                            ext_index                                   = [taper_type{:} 'ZBeforeNewFiltNewBroadAreas'];
                            trans_index_H                               = h_transform_voxel_inside(index_H);
                            
                            for nroi = 1:2 % length(list_H)
                                
                                source                                  = source_conn(trans_index_H(trans_index_H(:,2)==nroi,1),:);
                                source                                  = 0.5 .* (log((1+source)./(1-source)));
                                source                                  = mean(source)';
                                
                                tmp_source                              = zeros(hw_many_voxels_are_there,1);
                                tmp_source(index_voxels_in)             = source;
                                
                                source                                  = tmp_source ; clear tmp_source ;
                                
                                fname                                   = [dir_data suj '.' list_ix_cue_side{n_ex}{ncue} cond_main{ndis} '.' ext_time '.' ext_freq ];
                                fname                                   = [fname '.' list_extra.name{n_ex} '.' list_H{nroi} '.' cfg.method 'Conn.' ext_index '.mat'];
                                
                                fprintf('Saving %30s\n',fname);
                                save(fname,'source','-v7.3');
                                
                                clear source fname;
                                
                            end
                            
                            clear source_conn i
                            
                        end
                    end
                end
            end
        end
    end
end

clear leadfield com_filter data_elan vol grid