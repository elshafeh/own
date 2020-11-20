clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat

suj_group = suj_group(3);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj             = suj_list{sb};
        
        lst_cnd         = {'RCnD','LCnD','NCnD'};
        lst_method      = {'PLV.optimisedPACMinEvoked100Slct'};
        lst_chn         = {'aud_L','aud_R','occ_L','occ_R'};
        lst_tme         = {'m1000m200','p200p1000'};
        
        for ncue = 1:length(lst_cnd)
            for nmethod = 1:length(lst_method)
                for nchan = 1:length(lst_chn)
                    for nfhigh = 1:length(lst_tme)
                        
                        fname   = ['../data/pat22_data/' suj '.' lst_cnd{ncue} '.NewAVBroad.' lst_tme{nfhigh} '.' lst_chn{nchan} '.' lst_method{nmethod} '.mat'];
                        
                        fprintf('Loading %30s\n',fname);
                        load(fname);
                        
                        time_temp{nfhigh}.powspctrm(1,:,:)                 = seymour_pac.mpac_norm;
                        time_temp{nfhigh}.freq                             = seymour_pac.amp_freq_vec;
                        time_temp{nfhigh}.time                             = seymour_pac.pha_freq_vec;
                        time_temp{nfhigh}.label                            = lst_chn(nchan);
                        time_temp{nfhigh}.dimord                           = 'chan_freq_time';
                        
                        clear seymour_pac
                        
                    end
                    
                    chan_temp{nchan}                           = time_temp{2};
                    
                    clear time_temp;
                    
                end
                
                
                cfg = []; cfg.parameter = 'powspctrm' ; cfg.appenddim = 'chan';
                new_freq = ft_appendfreq(cfg,chan_temp{:});
                
                audL                                            = new_freq.powspctrm(1,:,:);
                audR                                            = new_freq.powspctrm(2,:,:);
                lIdx                                            = (audR-audL) ./ ((audR+audL)/2);
                
                allsuj_data{ngroup}{sb,ncue}                    = new_freq;
                
                allsuj_data{ngroup}{sb,ncue}.powspctrm          = [];
                
                allsuj_data{ngroup}{sb,ncue}.powspctrm(1,:,:)   = squeeze(lIdx); clear lIdx ;
                
                visL                                            = new_freq.powspctrm(3,:,:);
                visR                                            = new_freq.powspctrm(4,:,:);
                lIdx                                            = (visR-visL) ./ ((visR+visL)/2);
                
                allsuj_data{ngroup}{sb,ncue}.powspctrm(2,:,:)   = squeeze(lIdx); clear lIdx ;
                
                allsuj_data{ngroup}{sb,ncue}.label              = {'LatIndex_aud','LatIndex_vis'};
                
                clear chan_temp;
                
            end
        end
    end
end

clearvars -except allsuj_data lst_* ; clc ;

fOUT = '/Users/heshamelshafei/GoogleDrive/google_Desktop/14Feb_r_doc/NewAVBroad_PhaseAmplitudeCoupling_p200p1000_LatIndex.txt';
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
                            
                            name_chan           = allsuj_data{ngroup}{sb,ncue}.label{nchan};
                            
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
                            
                            chan_method = lst_method{nmethod};
                            
                            x1       = find(round(allsuj_data{ngroup}{sb,ncue}.time)== round(flo_list(nf_lo)));
                            x2       = find(round(allsuj_data{ngroup}{sb,ncue}.time)== round(flo_list(nf_lo)+flo_wind));
                            
                            y1       = find(round(allsuj_data{ngroup}{sb,ncue}.freq)== round(fhi_list(nf_hi)));
                            y2       = find(round(allsuj_data{ngroup}{sb,ncue}.freq)== round(fhi_list(nf_hi)+fhi_wind));
                            
                            if isempty(x1) || isempty(x2) || isempty(y1) || isempty(y2)
                                error('ahhhh')
                            else
                                pow      = mean(allsuj_data{ngroup}{sb,ncue}.powspctrm(nchan,y1:y2,x1:x2),3);
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