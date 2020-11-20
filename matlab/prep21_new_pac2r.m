clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list       = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj         = ['yc' num2str(suj_list(sb))] ;
    
    lst_mth     = {'canolty','tort','PLV','ozkurt'};
    
    lst_chn     = {'maxHL_1','maxHL_2','maxHL_3','maxHL_4','maxHL_5','maxSTL_1','maxSTL_2','maxSTL_3','maxSTL_4','maxSTL_5', ...
        'maxHR_1','maxHR_2','maxHR_3','maxHR_4','maxHR_5','maxSTR_1','maxSTR_2','maxSTR_3','maxSTR_4','maxSTR_5'};
    
    lst_tme     = {'m600m200','p600p1000'};
    
    
    for nmethod = 1:length(lst_mth)
        
        lst_cnd     = {'RCnD','LCnD','NCnD'};
        
        for ncue = 1:length(lst_cnd)
            for ntime = 1:length(lst_tme)
                
                for nchan = 1:length(lst_chn)
                    
                    fname   = ['../data/paper_data/' suj '.' lst_cnd{ncue} '.prep21.maxAVMsepVoxels.1t120.' lst_tme{ntime} '.low.9t13.high5step.50t110.' ...
                        lst_chn{nchan} '.' lst_mth{nmethod} '.optimisedPACeEvoked.mat'];
                    
                    fprintf('Loading %30s\n',fname);
                    load(fname);
                    
                    tempotemp.freq                               = seymour_pac.amp_freq_vec;
                    tempotemp.time                               = seymour_pac.pha_freq_vec;
                    
                    mpacF                                        = .5.*log((1+seymour_pac.mpac)./(1-seymour_pac.mpac));
                    
                    tempotemp.powspctrm(nchan,:,:)               = mpacF; % seymour_pac.mpac;
                    
                    tempotemp.label{nchan}                       = lst_chn{nchan}; % ['audR no norm ' lst_tme{2} ' ' lst_mth{nmethod}];
                    tempotemp.dimord                             = 'chan_freq_time';
                    
                    clear seymour_pac
                    
                    %                     time_temp{ntime}.powspctrm(2,:,:)                   = seymour_pac.mpac_norm;
                    %                     mpac(1,:,:)                                         = seymour_pac.mpac;
                    %                     msur(1,:,:)                                         = seymour_pac.mpac_surr;
                    %                     mstd(1,:,:)                                         = seymour_pac.mpac_std;
                    %                     time_temp{ntime}.powspctrm(3,:,:)                   = (mpac-msur) ./ mstd;
                    %                     time_temp{ntime}.label{2}                           = ['audR min norm ' lst_tme{2} ' ' lst_mth{nmethod}];
                    %                     time_temp{ntime}.label{3}                           = ['audR z norm ' lst_tme{2} ' ' lst_mth{nmethod}];
                    
                    
                    
                end
                
                tempotemp                       = h_transform_freq(tempotemp,{1:10,11:20},{'audL','audR'});
                
                for nka = 1:length(tempotemp.label)
                    tempotemp.label{nka} = [tempotemp.label{nka} ' ' lst_mth{nmethod}];
                end
                
                time_temp{ntime}                = tempotemp; clear tempotemp
                
            end
                            
            tenytemp                        = time_temp{2};
            tenytemp.powspctrm              = (time_temp{2}.powspctrm - time_temp{1}.powspctrm)./time_temp{1}.powspctrm;
            %             tenytemp.powspctrm              = (time_temp{2}.powspctrm - time_temp{1}.powspctrm); % ./time_temp{1}.powspctrm;

            allsuj_data{1}{sb,ncue,nmethod}    = tenytemp;
            
            clear time_temp;
            
        end

        
        
    end
end

clearvars -except allsuj_data lst_* ; clc ;

fOUT = '/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/4R/prep21_new_PhaseAmplitudeCoupling_p600p1000_z_rel.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','METHOD','HEMI','HIGH_FREQ','LOW_FREQ','POW','BSL_TYPE','NORM_TYPE');

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
                            
                            name_parts          = strsplit(name_chan,' ');
                            
                            bsl_type            = 'abs'; % name_parts{end};
                            nrm_type            = 'nonorm'; % name_parts{3};
                            chn_type            = [name_parts{1}(end) '_Hemi'];
                            
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