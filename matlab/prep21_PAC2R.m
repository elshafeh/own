clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_group{1} = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj             = suj_list{sb};
        
        lst_chn         = {'maxHL_1','maxHL_2','maxHL_3','maxHL_4','maxHL_5','maxSTL_1','maxSTL_2','maxSTL_3','maxSTL_4','maxSTL_5', ...
            'maxHR_1','maxHR_2','maxHR_3','maxHR_4','maxHR_5','maxSTR_1','maxSTR_2','maxSTR_3','maxSTR_4','maxSTR_5'};
        
        lst_cnd         = {'RCnD','LCnD','NCnD'};
        lst_mth         = {'PLV','canolty','ozkurt'};
        
        lst_tme         = {'m600m200','p600p1000'};
        ext_data_1      = 'prep21.maxAVMsepVoxels.sepFreq';
        ext_data_2      = 'low.3t20.high5step.50t110';
        ext_data_3      = 'optimisedPACMinEvoked';
        
        for ncue = 1:length(lst_cnd)
            for nmethod = 1:length(lst_mth)
                for ntime = 1:length(lst_tme)
                    for nchan = 1:length(lst_chn)
                        
                        fname   = ['/Volumes/dycog/Aurelie/DATA/MEG/PAT_MEG21/pat.field/data/' suj '.' lst_cnd{ncue} '.' ext_data_1 '.' lst_tme{ntime} '.' ext_data_2 '.' ...
                            lst_chn{nchan} '.' lst_mth{nmethod} '.' ext_data_3 '.mat'];
                        
                        fprintf('Loading %30s\n',fname);
                        load(fname);
                        
                        buttercup.freq                                  = seymour_pac.amp_freq_vec;
                        buttercup.time                                  = seymour_pac.pha_freq_vec;
                        
                        buttercup.powspctrm(1,:,:)                      = seymour_pac.mpac;
                        buttercup.label{1}                              = [lst_chn{nchan} '_nonorm']; %lst_tme{2}];
                        buttercup.dimord                                = 'chan_freq_time';
                        chan_temp{nchan}                                = buttercup; clear buttercup;

                        %                         buttercup.powspctrm(2,:,:)                      = seymour_pac.mpac_norm;
                        %                         buttercup.label{2}                              = [lst_chn{nchan} '_surrnorm']; %lst_tme{2}];
                        %                         mpac(1,:,:)                                         = seymour_pac.mpac;
                        %                         msur(1,:,:)                                         = seymour_pac.mpac_surr;
                        %                         mstd(1,:,:)                                         = seymour_pac.mpac_std;
                        %                         time_temp{ntime}.powspctrm(3,:,:)                   = (mpac-msur) ./ mstd;
                        %                         time_temp{ntime}.label{3}                           = 'audR_zs_norm'; % lst_tme{2}];
                        
                        clear seymour_pac
                        
                    end
                    
                    cfg                 = []; cfg.parameter = 'powspctrm' ; cfg.appenddim = 'chan';
                    tmp                 = ft_appendfreq(cfg,chan_temp{:}); clear chan_temp
                    
                    time_temp{ntime}    = h_transform_freq(tmp,{1:10,11:20},{'aud_L','aud_R'}); clear tmp;
                    
                end
                
                bsl_carrier{1}                  = time_temp{2};
                bsl_carrier{1}.powspctrm        = (time_temp{2}.powspctrm - time_temp{1}.powspctrm)./time_temp{1}.powspctrm;
                
                %                 [bsl_carrier{1},bsl_carrier{2},bsl_carrier{3}]                  = deal(time_temp{2});
                %                 bsl_carrier{3}.powspctrm     = time_temp{2}.powspctrm - time_temp{1}.powspctrm;
                
                list_bsl                     = {'rel'}; % ,'rel','abs'};  clear time_temp;
                
                for nbsl = 1:length(list_bsl)
                    for nx  = 1:length(bsl_carrier{nbsl}.label)
                        
                        bsl_carrier{nbsl}.label{nx} = [bsl_carrier{nbsl}.label{nx} '_' list_bsl{nbsl}];
                        
                    end
                end
                
                cfg = []; cfg.parameter = 'powspctrm' ; cfg.appenddim = 'chan';
                allsuj_data{ngroup}{sb,ncue,nmethod} = ft_appendfreq(cfg,bsl_carrier{:}); clear bsl_carrier;
                
                clc;
                
            end
        end
    end
end

clearvars -except allsuj_data lst_* ext_data*; clc ;

fOUT = '/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/4R/Newprep21_PhaseAmplitudeCoupling_p600p1000';
fOUT = [fOUT '_' ext_data_1 '_' ext_data_2 '_' ext_data_3  '.txt'];

fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','METHOD','CHAN','HIGH_FREQ','LOW_FREQ','POW','BSL_TYPE','NORM_TYPE');

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        for ncue = 1:size(allsuj_data{ngroup},2)
            for nmethod = 1:size(allsuj_data{ngroup},3)
                for nchan = 1:length(allsuj_data{ngroup}{sb,ncue,nmethod}.label)
                    
                    fhi_wind  = 10;
                    fhi_list  = 60:fhi_wind:90; %
                    
                    flo_wind = 0;
                    flo_list = [9 13];
                    
                    for nf_hi = 1:length(fhi_list)
                        for nf_lo = 1:length(flo_list)
                            
                            ls_group            = {'Young'};
                            
                            data_in             = allsuj_data{ngroup}{sb,ncue,nmethod};
                            name_chan           = data_in.label{nchan};
                            name_parts          = strsplit(name_chan,'_');
                            
                            bsl_type            = name_parts{end};
                            nrm_type            = 'no_norm';
                            chn_type            = [name_parts{2} '_Hemi'];
                            
                            which_cue           = lst_cnd{ncue}(1);
                            
                            if strcmp(chn_type,'L_Hemi')
                                
                                if strcmp(which_cue,'L')
                                    group_rt                = 'ipsilateral';
                                elseif strcmp(which_cue,'R')
                                    group_rt                = 'contralateral';
                                else
                                    group_rt                = 'uninformative';
                                end
                                
                            elseif strcmp(chn_type,'R_Hemi')
                                
                                if strcmp(which_cue,'L')
                                    group_rt                = 'contralateral';
                                elseif strcmp(which_cue,'R')
                                    group_rt                = 'ipsilateral';
                                else
                                    group_rt                = 'uninformative';
                                end
                                
                            end
                            
                            if flo_list(nf_lo) < 10
                                ls_time  = ['0' num2str(flo_list(nf_lo)) 'Hz'];
                            else
                                ls_time  = [num2str(flo_list(nf_lo)) 'Hz'];
                            end
                            
                            if fhi_list(nf_hi) < 100
                                ls_freq  = ['0' num2str(fhi_list(nf_hi)) 'Hz'];
                            else
                                ls_freq  = [num2str(fhi_list(nf_hi)) 'Hz'];
                            end
                            
                            chan_method         = lst_mth{nmethod};
                            
                            x1                  = find(round(data_in.time)== round(flo_list(nf_lo)));
                            x2                  = find(round(data_in.time)== round(flo_list(nf_lo)+flo_wind));
                            
                            y1                  = find(round(data_in.freq)== round(fhi_list(nf_hi)));
                            y2                  = find(round(data_in.freq)== round(fhi_list(nf_hi)+fhi_wind));
                            
                            if isempty(x1) || isempty(x2) || isempty(y1) || isempty(y2)
                                error('ahhhh')
                            else
                                pow      = mean(data_in.powspctrm(nchan,y1:y2,x1:x2),3);
                                pow      = squeeze(mean(pow,2));
                                
                                if size(pow,1) > 1 || size(pow,2) > 1
                                    error('oohhhhhhh')
                                else
                                    
                                    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%.5f\t%s\t%s\n',ls_group{ngroup},[ls_group{ngroup} num2str(sb)],group_rt,chan_method, ...
                                        chn_type,ls_freq,ls_time,pow,bsl_type,nrm_type);
                                    
                                end
                            end
                        end
                    end
                    
                end
            end
        end
    end
end

fclose(fid);