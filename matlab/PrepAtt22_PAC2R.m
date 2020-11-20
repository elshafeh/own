clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat
suj_group = suj_group(3);

% suj_group{1} = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj             = suj_list{sb};
        
        lst_cnd         = {'RCnD','LCnD','NCnD'};
        lst_mth         = {'PLV','canolty','tort'};
        lst_chn         = {'broad_aud_R','5Neig_aud_R'}; %{'aud_R'};
        lst_tme         = {'m600m200','p600p1000'};
        
        for ncue = 1:length(lst_cnd)
            for nmethod = 1:length(lst_mth)
                for nchan = 1:length(lst_chn)
                    for ntime = 1:length(lst_tme)
                        
                        %                         fname   = ['../data/paper_data/' suj '.' lst_cnd{ncue} '.prep21.AV.' lst_tme{ntime} '.low.7t20.high2step.50t110.' ...
                        %                             lst_chn{nchan} '.' lst_mth{nmethod} '.optimisedPACMinEvoked.mat'];
                        
                        fname   = ['../data/yc_all_data/' suj '.' lst_cnd{ncue} '.AllYc4Roisexplor.' lst_tme{ntime} '.low.7t20.high.50t110.' ...
                            lst_chn{nchan} '.' lst_mth{nmethod} '.optimisedPACMinEvoked.mat'];
                        
                        fprintf('Loading %30s\n',fname);
                        load(fname);
                        
                        time_temp{ntime}.freq                               = seymour_pac.amp_freq_vec;
                        time_temp{ntime}.time                               = seymour_pac.pha_freq_vec;
                        
                        time_temp{ntime}.powspctrm(1,:,:)                   = seymour_pac.mpac;
                        
                        %                         time_temp{ntime}.powspctrm(2,:,:)                   = seymour_pac.mpac_norm;
                        %
                        %                         mpac(1,:,:)                                         = seymour_pac.mpac;
                        %                         msur(1,:,:)                                         = seymour_pac.mpac_surr;
                        %                         mstd(1,:,:)                                         = seymour_pac.mpac_std;
                        %
                        %                         time_temp{ntime}.powspctrm(3,:,:)                   = (mpac-msur) ./ mstd;
                        
                        time_temp{ntime}.label{1}                           = [lst_chn{nchan} '_no_norm']; %lst_tme{2}];
                        
                        %                         time_temp{ntime}.label{2}                           = 'audR_mn_norm'; % lst_tme{2}];
                        %                         time_temp{ntime}.label{3}                           = 'audR_zs_norm'; % lst_tme{2}];
                        
                        time_temp{ntime}.dimord                             = 'chan_freq_time';
                        
                        clear seymour_pac
                        
                    end
                    
                    chan_temp{nchan,1}               = time_temp{2};
                    chan_temp{nchan,2}               = time_temp{2};
                    chan_temp{nchan,3}               = time_temp{2};

                    chan_temp{nchan,1}.powspctrm     = (time_temp{2}.powspctrm - time_temp{1}.powspctrm)./time_temp{1}.powspctrm;
                    chan_temp{nchan,2}.powspctrm     = time_temp{2}.powspctrm - time_temp{1}.powspctrm;
                    
                    list_bsl                         = {'rel','abs','no'};
                    
                    for nbsl = 1:length(list_bsl)
                        for nx  = 1:length(chan_temp{nchan,nbsl}.label)
                            
                            chan_temp{nchan,nbsl}.label{nx} = [chan_temp{nchan,nbsl}.label{nx} '_' list_bsl{nbsl}];
                            
                        end
                    end
                    
                    clear time_temp;
                    
                end
                
                
                cfg = []; cfg.parameter = 'powspctrm' ; cfg.appenddim = 'chan';
                allsuj_data{ngroup}{sb,ncue,nmethod} = ft_appendfreq(cfg,chan_temp{:,:});
                
                clear chan_temp;
                
            end
        end
    end
end

clearvars -except allsuj_data lst_* ; clc ;

fOUT = '/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/4R/allyc_PhaseAmplitudeCoupling_p600p1000_2Freq_avgHI.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','METHOD','CHAN','HIGH_FREQ','LOW_FREQ','POW','BSL_TYPE','NORM_TYPE');

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        for ncue = 1:size(allsuj_data{ngroup},2)
            for nmethod = 1:size(allsuj_data{ngroup},3)
                for nchan = 1:length(allsuj_data{ngroup}{sb,ncue,nmethod}.label)
                    
                    fhi_wind  = 40;
                    fhi_list  = 60; % :fhi_wind:90; %
                    
                    flo_wind = 0;
                    flo_list = [8 13];
                    
                    for nf_hi = 1:length(fhi_list)
                        for nf_lo = 1:length(flo_list)
                            
                            ls_group            = {'Young'};
                            ls_threewise        = {'ipsilateral','contralateral','uninformative'};

                            data_in             = allsuj_data{ngroup}{sb,ncue,nmethod};
                            name_chan           = data_in.label{nchan};
                            name_parts          = strsplit(name_chan,'_');
                            
                            if length(name_parts) < 4
                                bsl_type            = name_parts{end};
                                nrm_type            = [name_parts{2} name_parts{3}];
                                chn_type            = name_parts{1};
                            else
                                bsl_type            = name_parts{end};
                                nrm_type            = [name_parts{4} name_parts{5}];
                                chn_type            = [name_parts{1} name_parts{2} name_parts{3}];
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
                            
                            chan_method = lst_mth{nmethod};
                            
                            x1          = find(round(data_in.time)== round(flo_list(nf_lo)));
                            x2          = find(round(data_in.time)== round(flo_list(nf_lo)+flo_wind));
                            
                            y1          = find(round(data_in.freq)== round(fhi_list(nf_hi)));
                            y2          = find(round(data_in.freq)== round(fhi_list(nf_hi)+fhi_wind));
                            
                            if isempty(x1) || isempty(x2) || isempty(y1) || isempty(y2)
                                error('ahhhh')
                            else
                                pow      = mean(data_in.powspctrm(nchan,y1:y2,x1:x2),3);
                                pow      = squeeze(mean(pow,2));
                                
                                if size(pow,1) > 1 || size(pow,2) > 1
                                    error('oohhhhhhh')
                                else
                                    
                                    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%.5f\t%s\t%s\n',ls_group{ngroup},[ls_group{ngroup} num2str(sb)],ls_threewise{ncue},chan_method, ...
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