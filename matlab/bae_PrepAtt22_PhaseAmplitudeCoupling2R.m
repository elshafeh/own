clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj             = suj_list{sb};
        
        lst_cnd         = {'RCnD','LCnD','NCnD'};
        lst_method      = {'PLV.optimisedPACMinEvoked','PLV.optimisedPAC','PLV.optimisedPACMinEvoked100Slct'};
        lst_chn         = {'aud_L','aud_R'};
        lst_tme         = {'m1000m200','p200p1000'};
        
        for ncue = 1:length(lst_cnd)
            for nmethod = 1:length(lst_method)
                for nchan = 1:length(lst_chn)
                    for nfhigh = 1:length(lst_tme)
                        
                        fname   = ['../data/' suj '/field/' suj '.' lst_cnd{ncue} '.broadAreas.' lst_tme{nfhigh} '.' lst_chn{nchan} '.' lst_method{nmethod} '.mat'];
                        
                        fprintf('Loading %30s\n',fname);
                        load(fname);
                        
                        time_temp{nfhigh}.powspctrm(1,:,:)                 = seymour_pac.mpac_norm;
                        time_temp{nfhigh}.freq                             = seymour_pac.amp_freq_vec;
                        time_temp{nfhigh}.time                             = seymour_pac.pha_freq_vec;
                        time_temp{nfhigh}.label                            = lst_chn(nchan);
                        time_temp{nfhigh}.dimord                           = 'chan_freq_time';
                        
                        clear seymour_pac
                        
                    end
                    
                    chan_temp{nchan}               = time_temp{2};
                    chan_temp{nchan}.powspctrm     = (time_temp{2}.powspctrm - time_temp{1}.powspctrm)./time_temp{1}.powspctrm;
                    
                    clear time_temp;
                    
                end
                
                
                cfg = []; cfg.parameter = 'powspctrm' ; cfg.appenddim = 'chan';
                allsuj_data{ngroup}{sb,ncue,nmethod} = ft_appendfreq(cfg,chan_temp{:});
                
                clear chan_temp;
                
            end
        end
    end
end

clearvars -except allsuj_data lst_* ; clc ;

fOUT = '../documents/4R/BroadAuditoryAreas_PhaseAmplitudeCoupling_with_normalization_3methods.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','METHOD','CHAN','LOW_FREQ','HIGH_FREQ','POW');

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        for ncue = 1:size(allsuj_data{ngroup},2)
            for nmethod = 1:size(allsuj_data{ngroup},3)
                for nchan = 1:length(allsuj_data{ngroup}{sb,ncue,nmethod}.label)
                    
                    fhi_wind  = 10;
                    fhi_list  = 60:fhi_wind:90;
                    
                    flo_wind = 0;
                    flo_list = 7:15;
                    
                    for nf_hi = 1:length(fhi_list)
                        for nf_lo = 1:length(flo_list)
                            
                            ls_group            = {'allYoung'};
                            
                            ls_threewise        = {'RCue','LCue','NCue'};
                            
                            name_chan  = allsuj_data{ngroup}{sb,ncue,nchan}.label{nchan};
                            
                            ls_time  = [num2str(flo_list(nf_lo)) 'Hz'];
                            
                            ls_freq  = [num2str(fhi_list(nf_hi)) 'Hz'];
                                                        
                            chan_method = lst_method{nmethod};
                                                        
                            x1       = find(round(allsuj_data{ngroup}{sb,ncue,nchan}.time)== round(flo_list(nf_lo)));
                            x2       = find(round(allsuj_data{ngroup}{sb,ncue,nchan}.time)== round(flo_list(nf_lo)+flo_wind));
                            
                            y1       = find(round(allsuj_data{ngroup}{sb,ncue,nchan}.freq)== round(fhi_list(nf_hi)));
                            y2       = find(round(allsuj_data{ngroup}{sb,ncue,nchan}.freq)== round(fhi_list(nf_hi)+fhi_wind));
                            
                            if isempty(x1) || isempty(x2) || isempty(y1) || isempty(y2)
                                error('ahhhh')
                            else
                                pow      = mean(allsuj_data{ngroup}{sb,ncue,nchan}.powspctrm(nchan,y1:y2,x1:x2),3);
                                pow      = squeeze(mean(pow,2));
                                
                                if size(pow,1) > 1 || size(pow,2) > 1
                                    error('oohhhhhhh')
                                else
                                    
                                    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%.5f\n',ls_group{ngroup},[ls_group{ngroup} num2str(sb)],ls_threewise{ncue},lst_method{nmethod}, ...
                                        name_chan,ls_freq,ls_time,pow);
                                    
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