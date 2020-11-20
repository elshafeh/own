clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_list        = suj_list(2:22);
% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% suj_list        = [suj_list; allsuj(2:15,1); allsuj(2:15,2)];
% suj_list        = unique(suj_list);



for sb = 1:length(suj_list)
    
    suj                                         = suj_list{sb};
    vox_size                                    = 0.5;
    cond_main                                   = {'DIS','fDIS'};
    
    load(['../data/' suj '/field/' suj '.adjusted.leadfield.' num2str(vox_size) 'cm.mat']);
    load(['../data/' suj '/field/' suj '.VolGrid.' num2str(vox_size) 'cm.mat']);
    
    for ndis = 1:length(cond_main)
        
        fname_in                                    = ['../data/' suj '/field/' suj '.' cond_main{ndis} '.mat'];
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        big_elan{ndis}                              = data_elan ; clear data_elan ;
        
    end
    
    data_concat         = ft_appenddata([],big_elan{:});
    
    for taper_type = {'dpss','hanning'}
        
        for name_extra      = {'MinEvoked'}
            
            cfg                     = [];
            cfg.toilim              = [-0.2 0.4];
            poiCommon               = ft_redefinetrial(cfg, data_concat);
            
            ext_time                = ['m' num2str(abs(cfg.toilim(1))*1000) 'p' num2str((cfg.toilim(2))*1000)];
            
            cfg                     = [];
            cfg.method              = 'mtmfft'; cfg.output              = 'fourier'; cfg.keeptrials          = 'yes';
            cfg.taper               = taper_type{:};
            cfg.foi                 = 80;
            cfg.tapsmofrq           = 30;
            freqCommon              = ft_freqanalysis(cfg,poiCommon);
            
            clear poiCommon
            
            ext_freq                = [num2str(cfg.foi-cfg.tapsmofrq) 't' num2str(cfg.foi+cfg.tapsmofrq) 'Hz'];
            
            cfg                     = [];
            cfg.frequency           = freqCommon.freq;
            cfg.method              = 'pcc';
            cfg.grid                = leadfield;
            cfg.headmodel           = vol;
            cfg.keeptrials          = 'yes'; cfg.pcc.lambda          = '10%'; cfg.pcc.projectnoise    = 'yes'; cfg.pcc.keepfilter      = 'yes'; cfg.pcc.fixedori        = 'yes';
            source                  = ft_sourceanalysis(cfg, freqCommon);
            com_filter              = source.avg.filter;
            
            clear source
            
            %         FnameFilterOut = ['../data/' suj '/field/' suj '.DISfDIS.60t100Hz.m200p600.PCCommonFilterMinEvoked0.5cm.mat'];
            %         load(FnameFilterOut);
            %         FnameFilterOut = [suj '.' cond_main{:} '.' ext_freq '.' ext_time '.PCCommonFilter' name_extra{:} num2str(vox_size) 'cm'];
            %         fprintf('\n\nSaving %50s \n\n',FnameFilterOut);
            %         save(['../data/' suj '/field/' FnameFilterOut '.mat'],'com_filter','-v7.3');
            
            for ndis = 1:length(cond_main)
                
                cfg                                     = [];
                data_elan                               = ft_selectdata(cfg, big_elan{ndis});
                
                tlist                                   = 0.1;
                twin                                    = 0.2;
                flist                                   = 80;
                fpad                                    = 20;
                tpad                                    = 0;
                
                for nfreq = 1:length(flist)
                    for ntime = 1:length(tlist)
                        
                        list_ix_cue_side                = {'','V','N'};
                        list_ix_cue_code                = {0:2,[1 2],0};
                        list_ix_dis_code                = {1:2,1:2,1:2};
                        list_ix_tar_code                = {1:4,1:4,1:4};
                        
                        for ncue = 1:length(list_ix_cue_side)
                            
                            cfg                         = [];
                            cfg.toilim                  = [tlist(ntime)-tpad tlist(ntime)+tpad+twin(ntime)];
                            cfg.trials                  = h_chooseTrial(data_elan,list_ix_cue_code{ncue},list_ix_dis_code{ncue},list_ix_tar_code{ncue});
                            poi                         = ft_redefinetrial(cfg, data_elan);
                            
                            poi                         = h_removeEvoked(poi);
                            
                            cfg                         = [];
                            cfg.method                  = 'mtmfft';
                            cfg.output                  = 'fourier';
                            cfg.keeptrials              = 'yes';
                            cfg.taper                   = taper_type{:};
                            cfg.foi                     = flist(nfreq);
                            cfg.tapsmofrq               = fpad(nfreq);
                            freq                        = ft_freqanalysis(cfg,poi);
                            
                            if tlist(ntime) < 0
                                ext_ext= 'm';
                            else
                                ext_ext='p';
                            end
                            
                            ext_time                    = [ext_ext num2str(abs(tlist(ntime)*1000)) ext_ext num2str(abs((tlist(ntime)+twin(ntime))*1000))];
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
                            
                            source                      = rmfield(source,'cfg'); source                      = rmfield(source,'method'); source                      = rmfield(source,'trialinfo'); source                      = rmfield(source,'freq');
                            
                            ext_name                    = [suj '.' list_ix_cue_side{ncue} cond_main{ndis} '.' ext_time '.' ext_freq '.OriginalPCC' name_extra{:} num2str(vox_size) 'cm'];
                            
                            fprintf('Saving %s\n',ext_name);
                            
                            %                         save(['../data/' suj '/field/' ext_name '.mat'],'source','-v7.3');
                            %                         fprintf('Loading %s\n',ext_name);
                            %                         load(['../data/' suj '/field/' ext_name '.mat']);
                            
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
                                
                                load ../data_fieldtrip/index/broadmanAuditoryOccipital_combined.mat;
                                
                                ext_index           = [taper_type{:} 'ZBeforeNewFiltNewBroadAreas'];
                                
                                index_H             = index_H(index_H(:,2) > 2,:);
                                index_H(:,2)        = index_H(:,2)-2;
                                
                                new_index           = index_H;
                                new_index(:,2)      = 3;
                                
                                index_H             = [index_H;new_index];
                                list_H              = {'audL','audR','audLR'};
                                
                                for nroi = 3:length(list_H)
                                    
                                    source = source_conn(index_H(index_H(:,2)==nroi,1),:);
                                    
                                    source = 0.5 .* (log((1+source)./(1-source)));
                                    
                                    source = mean(source)';
                                    
                                    fname   = ['../data/' suj '/field/' suj '.' list_ix_cue_side{ncue} cond_main{ndis} '.' ext_time '.' ext_freq '.' name_extra{:} '.' list_H{nroi} '.' cfg.method 'Conn.' ext_index '.mat'];
                                    
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
    
end