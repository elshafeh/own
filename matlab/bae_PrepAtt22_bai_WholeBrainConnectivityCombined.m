clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,suj_group{3},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_group{3}        = suj_group{3}(2:22);

[~,allsuj,~]        = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_group{1}        = allsuj(2:15,1);
suj_group{2}        = allsuj(2:15,2);

suj_list            = [suj_group{1};suj_group{2}]; suj_list = unique(suj_list);

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
    
    for name_extra      = {''}
        
        load(['../data/' suj '/field/' suj '.CnD.5t15Hz.m800p2000.PCCommonFilter' name_extra{:} num2str(vox_size) 'cm.mat']);
        
        cfg                                     = [];
        data_elan                               = ft_selectdata(cfg, big_elan);
        
        tlist                                   = [-0.6 0.6];
        flist                                   = [9 13 11];
        twin                                    = 0.4;
        tpad                                    = 0.025;
        fpad                                    = [2 2 4];
        
        for nfreq = 1:length(flist)
            for ntime = 1:length(tlist)
                
                list_ix_cue_side                = {''}; %,'N','L','R'};
                list_ix_cue_code                = {0:2}; %,0,1,2};
                list_ix_dis_code                = {0}; %,0,0,0};
                list_ix_tar_code                = {1:4}; %,1:4,1:4,1:4};
                
                for ncue = 1:length(list_ix_cue_side)
                    
                    cfg                         = [];
                    cfg.toilim                  = [tlist(ntime)-tpad tlist(ntime)+tpad+twin];
                    cfg.trials                  = h_chooseTrial(data_elan,list_ix_cue_code{ncue},list_ix_dis_code{ncue},list_ix_tar_code{ncue});
                    poi                         = ft_redefinetrial(cfg, data_elan);
                    
                    poi                         = h_removeEvoked(poi);
                    
                    cfg                         = [];
                    cfg.method                  = 'mtmfft';cfg.output                  = 'fourier';cfg.keeptrials              = 'yes';
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
                    cfg.grid                    = leadfield;cfg.grid.filter             = com_filter;cfg.headmodel               = vol;
                    cfg.keeptrials              = 'yes';cfg.pcc.lambda              = '10%';cfg.pcc.projectnoise        = 'yes';
                    source                      = ft_sourceanalysis(cfg, freq);
                    source.pos                  = grid.MNI_pos;
                    
                    source                      = rmfield(source,'cfg');source                      = rmfield(source,'method');source                      = rmfield(source,'trialinfo');source                      = rmfield(source,'freq');
                    
                    new_name_extra              = 'MinEvoked';
                    
                    %                     ext_name                    = [suj '.' list_ix_cue_side{ncue} cond_main '.' ext_time '.' ext_freq '.OriginalPCC' new_name_extra num2str(vox_size) 'cm'];
                    %                     fprintf('Saving %s\n',ext_name);
                    %                     save(['../data/' suj '/field/' ext_name '.mat'],'source','-v7.3');
                    
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
                    
                    list_method                 = {'plv'};
                    
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
                        
                        load ../data_fieldtrip/index/broadmanAuditoryOccipital_combined_averaged.mat ;
                        
                        %                         if strcmp(suj(1:2),'oc')
                        %                             load ../data_fieldtrip/index/14Oc_7t15Hz_5Around.mat;
                        %                         else
                        %                             load ../data_fieldtrip/index/14young_control_auditory_low_alpha_contrast.mat;
                        %                         end
                        
                        ext_index = 'broadAreas';
                        
                        for nroi = 1:length(list_H)
                            
                            source = source_conn(index_H(index_H(:,2)==nroi,1),:);
                            
                            source = mean(source)';
                            
                            fname   = ['../data/' suj '/field/' suj '.' list_ix_cue_side{ncue} cond_main '.' ext_time '.' ext_freq '.' new_name_extra '.' list_H{nroi} '.' cfg.method 'Conn.' ext_index '.mat'];
                            
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