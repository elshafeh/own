function h_prep21_calculate_wbc(flist,tlist,twin,tpad,fpad,data_elan,vol,leadfield,com_filter,prt,list_H,index_H,ext_index ... 
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
            
            new_name_extra              = 'MinEvoked';
            
            FnameOUT                    = ['../data/paper_data/' suj '.pt' num2str(prt) '.' list_ix_cue_side{ncue} cond_main '.' ext_time '.' ext_freq '.OriginalPCC' new_name_extra '0.5cm.mat'];
            
            fprintf('Saving %s\n',FnameOUT);
            
            %             save(FnameOUT,'source','-v7.3');
            
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
            
            for nmeth = 1:length(list_method)
                
                cfg                                         = [];
                cfg.keeptrials                              = 'yes';
                cfg.keeprpt                                 = 'yes';
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
                
                for nroi = 4 % 1:length(list_H)
                    
                    source                      = source_conn(index_H(index_H(:,2)==nroi,1),:);
                    source                      = mean(source)';
                    
                    %                     tmp_source                  = zeros(hw_many_voxels_are_there,1);
                    %                     tmp_source(index_voxels_in) = source;
                    %                     source                      = tmp_source ; clear tmp_source ;
                    
                    fname   = ['/media/hesham.elshafei/PAT_MEG2/prep21_cnd_gamma_conn/' suj '.pt' num2str(prt) '.' list_ix_cue_side{ncue} cond_main '.' ext_time '.' ext_freq '.' new_name_extra '.' list_H{nroi} '.' cfg.method 'Conn.' ext_index '.mat'];
                    
                    fprintf('Saving %30s\n',fname);
                    
                    save(fname,'source','-v7.3');
                    
                    clear source fname;
                    
                end
                
                clear source_conn i
                
            end
        end
    end
end