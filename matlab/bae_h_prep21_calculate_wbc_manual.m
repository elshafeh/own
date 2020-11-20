function h_prep21_calculate_wbc_manual(flist,tlist,twin,tpad,fpad,data_elan,vol,leadfield,com_filter,prt,list_H,index_H,ext_index ... 
    ,list_ix_cue_side,list_ix_cue_code,list_ix_dis_code,list_ix_tar_code,grid,list_method,suj,cond_main)

for nfreq = 1:length(flist)
    for ntime = 1:length(tlist)
        for ncue = 1:length(list_ix_cue_side)
            
            cfg                         = [];
            cfg.toilim                  = [tlist(ntime)-tpad tlist(ntime)+tpad+twin];
            cfg.trials                  = h_chooseTrial(data_elan,list_ix_cue_code{ncue},list_ix_dis_code{ncue},list_ix_tar_code{ncue});
            poi                         = ft_redefinetrial(cfg, data_elan);
            
            poi                         = h_removeEvoked(poi);
            
            cfg                         = [];
            cfg.method                  = 'mtmfft';cfg.output                  = 'fourier';cfg.keeptrials              = 'yes';
            cfg.taper                   = 'hanning';
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
            cfg.grid                    = leadfield;cfg.grid.filter = com_filter;cfg.headmodel               = vol;
            cfg.keeptrials              = 'yes';cfg.pcc.lambda = '10%';cfg.pcc.projectnoise        = 'yes';
            source                      = ft_sourceanalysis(cfg, freq);
            source.pos                  = grid.MNI_pos;
            
            source                      = rmfield(source,'cfg');source = rmfield(source,'method');source = rmfield(source,'trialinfo');source = rmfield(source,'freq');
            
            outside_voxels              = find(source.inside~=1);
            index_voxels_in             = find(source.inside==1);
            hw_many_voxels_are_there    = length(source.inside);
            ntrials                     = size(source.cumtapcnt,1);
            Phase                       = zeros(hw_many_voxels_are_there,ntrials);
            
            ft_progress('init','text',    'Computing Phase...');
            
            for nvox = 1:hw_many_voxels_are_there
                
                ft_progress(nvox/hw_many_voxels_are_there, 'Processing voxel %d from %d\n', nvox, hw_many_voxels_are_there);
                
                tmp                     = angle(source.avg.mom{nvox});
                if ~isempty(tmp)
                    Phase(nvox,:)           = angle(source.avg.mom{nvox});            % Computes the angles, in radians
                end
            end
            
            clear source ;
            
            for nroi = 4 %1:length(list_H)
                
                vox_slct                = index_H(index_H(:,2)==nroi,1);
                
                [plv]                   = h_pn_eeg_plv(Phase,vox_slct);
                plv                     = plv';
                plv(outside_voxels,:)   = 0;
                
                plvZ                    = 0.5 .* (log((1+plv)./(1-plv)));
                source                  = mean(plvZ,2);
                
                new_name_extra          = 'MinEvoked';
                fname                   = ['/media/hesham.elshafei/PAT_MEG2/prep21_alpha_conn/' suj '.pt' num2str(prt) '.' list_ix_cue_side{ncue} cond_main '.' ext_time '.' ext_freq '.' new_name_extra '.' list_H{nroi} '.manualPlvConnZ.' ext_index '.mat'];
                
                fprintf('Saving %30s\n',fname);
                
                save(fname,'source','-v7.3');
                
                clear source fname plv;
                
            end
            
        end
    end
end