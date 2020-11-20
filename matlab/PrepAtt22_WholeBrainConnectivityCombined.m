clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list        = suj_list(2:22);

for sb = 1:length(suj_list)
    
    suj                                         = suj_list{sb};
    vox_size                                    = 0.5;
    cond_main                                   = 'CnD';
    
    load(['../data/' suj '/field/' suj '.adjusted.leadfield.' num2str(vox_size) 'cm.mat']);
    load(['../data/' suj '/field/' suj '.VolGrid.' num2str(vox_size) 'cm.mat']);
    
    fname_in                                    = ['../data/' suj '/field/' suj '.' cond_main '.mat'];
    
    fprintf('Loading %s\n',fname_in);
    load(fname_in)
    
    big_elan                                    = data_elan ; clear data_elan ;
    
    for name_extra      = {'100SlctMinEvoked'}
        
        load(['../data/' suj '/field/' suj '.CnD.5t15Hz.m800p2000.PCCommonFilter' name_extra{:} num2str(vox_size) 'cm.mat']);
        
        cfg                                     = [];
        data_elan                               = ft_selectdata(cfg, big_elan);
        
        tlist                                   = [-0.7 0.6];
        flist                                   = 13;
        twin                                    = 0.5;
        tpad                                    = 0.025;
        fpad                                    = 2;
        
        for nfreq = 1:length(flist)
            for ntime = 1:length(tlist)
                
                list_ix_cue_side                = {'N','L','R','NL','NR'};
                list_ix_cue_code                = {0,1,2,0,0};
                list_ix_dis_code                = {0,0,0,0,0};
                list_ix_tar_code                = {1:4,1:4,1:4,[1 3],[2 4]};
                
                for ncue = 1:length(list_ix_cue_side)
                    
                    cfg                         = [];
                    cfg.toilim                  = [tlist(ntime)-tpad tlist(ntime)+tpad+twin];
                    cfg.trials                  = h_chooseTrial(data_elan,list_ix_cue_code{ncue},list_ix_dis_code{ncue},list_ix_tar_code{ncue});
                    poi                         = ft_redefinetrial(cfg, data_elan);
                    
                    poi                         = h_removeEvoked(poi);
                    
                    cfg                         = [];
                    cfg.method                  = 'mtmfft';
                    cfg.output                  = 'fourier';
                    cfg.keeptrials              = 'yes';
                    cfg.foi                     = flist(nfreq);
                    cfg.tapsmofrq               = fpad(nfreq);
                    freq                        = ft_freqanalysis(cfg,poi);
                    
                    if tlist(ntime) < 0
                        ext_ext= 'm';
                    else
                        ext_ext='p';
                    end
                    
                    ext_time                    = [ext_ext num2str(abs(tlist(ntime)*1000)) ext_ext num2str(abs((tlist(ntime)+twin)*1000))];
                    ext_freq                    = [num2str(flist(nfreq)-cfg.tapsmofrq) 't' num2str(flist(nfreq)+cfg.tapsmofrq) 'Hz'];
                    
                    cfg                         = [];
                    cfg.frequency               = freq.freq;
                    cfg.method                  = 'pcc';
                    cfg.grid                    = leadfield;
                    cfg.grid.filter             = com_filter;
                    cfg.headmodel               = vol;
                    cfg.keeptrials              = 'yes';
                    cfg.pcc.lambda              = '10%';
                    cfg.pcc.projectnoise        = 'yes';
                    source                      = ft_sourceanalysis(cfg, freq);
                    source.pos                  = grid.MNI_pos;
                    
                    source                      = rmfield(source,'cfg');
                    source                      = rmfield(source,'method');
                    source                      = rmfield(source,'trialinfo');
                    source                      = rmfield(source,'freq');
                    
                    ext_name                    = [suj '.' list_ix_cue_side{ncue} cond_main '.' ext_time '.' ext_freq '.OriginalPCC' name_extra{:} num2str(vox_size) 'cm'];
                    
                    fprintf('Saving %s\n',ext_name);
                    
                    save(['../data/' suj '/field/' ext_name '.mat'],'source','-v7.3');
                    
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
                    
                    list_method                 = {'plv','powcorr','coh'};
                    
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
                        
                        ext_index = 'NewBroadAreas';
                        
                        for nroi = 1:length(list_H)
                            
                            source = source_conn(index_H(index_H(:,2)==nroi,1),:);
                            source = mean(source)';
                            
                            fname   = ['../data/' suj '/field/' suj '.' list_ix_cue_side{ncue} cond_main '.' ext_time '.' ext_freq '.' name_extra{:} '.' list_H{nroi} '.' cfg.method 'Conn.' ext_index '.mat'];
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
    
    clear leadfield com_filter data_elan vol grid
    
end