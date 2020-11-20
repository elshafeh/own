addpath(genpath('../fieldtrip-20151124/'));
addpath('DrosteEffect-BrewerMap-b6a6efc/');

suj_list                = [1:4 8:17];

for ngroup = 1
    for sb = 1:length(suj_list)
        
        suj                 = ['yc' num2str(suj_list(sb))] ;
        
        list_cnd            = {'NCnD','LCnD','RCnD'};
        
        list_mth            = {'KLD','MVL','ndPAC','HR','PhaSyn'};
        
        list_tme            = {'m600m200','p600p1000'};
        
        for ncue = 1:length(list_cnd)
            for nmethod = 1:length(list_mth)
                for ntime = 1:length(list_tme)
                    
                    fname   = ['../data/paper_data/' suj '.' list_cnd{ncue} '.' list_tme{ntime} '.' ...
                        list_mth{nmethod} '.NoSurr.NoNorm.SameFreqNonZTransMinEvokedSepTensorPac.mat'];
                    
                    fprintf('Loading %30s\n',fname);
                    load(fname);
                    
                    transform_label                     = {'LHemi_Aud','RHemi_Aud'};
                    transform_index                     = {1:10,11:20};
                    
                    sub_tmp{ntime}                      = h_transform_freq(py_pac,transform_index,transform_label);
                    
                end
                
                allsuj_data{ngroup}{sb,ncue,nmethod}            = sub_tmp{1};
                allsuj_data{ngroup}{sb,ncue,nmethod}.powspctrm  = (sub_tmp{2}.powspctrm - sub_tmp{1}.powspctrm)./sub_tmp{1}.powspctrm; clear sub_tmp
            end
        end
    end
end

clearvars -except allsuj_data list_*

fOUT = '/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/4R/prep21_pre_target_NewTensorPAC_relbaseline_SameFreq.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','METHOD','CHAN','HIGH_FREQ','LOW_FREQ','POW','BSL_TYPE','NORM_TYPE');

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        for ncue = 1:length(list_cnd)
            for nmethod = 1:length(list_mth)
                
                data_in     = allsuj_data{ngroup}{sb,ncue,nmethod};
                
                for nchan = 1:length(data_in.label)
                    
                    fhi_wind  = 10;
                    fhi_list  = 60:fhi_wind:90;
                    
                    flo_wind = 0;
                    flo_list = [9 13];
                    
                    for nf_hi = 1:length(fhi_list)
                        for nf_lo = 1:length(flo_list)
                            
                            ls_group            = {'prep21_Young'};
                            
                            name_chan           = data_in.label{nchan};
                            name_parts          = strsplit(name_chan,'_');
                            
                            bsl_type            = 'abs';
                            nrm_type            = 'nonorm';
                            
                            chn_type            = name_parts{1};
                            cue_type            = list_cnd{ncue};
                            
                            if strcmp(chn_type,'LHemi')
                                
                                if strcmp(cue_type,'LCnD')
                                    ls_threewise                = 'ipsilateral';
                                elseif strcmp(cue_type,'RCnD')
                                    ls_threewise                = 'contralateral';
                                else
                                    ls_threewise                = 'uninformative';
                                end
                                
                            elseif strcmp(chn_type,'RHemi')
                                
                                if strcmp(cue_type,'LCnD')
                                    ls_threewise                = 'contralateral';
                                elseif strcmp(cue_type,'RCnD')
                                    ls_threewise                = 'ipsilateral';
                                else
                                    ls_threewise                = 'uninformative';
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
                            
                            chan_method = list_mth{nmethod};
                            
                            x1          = find(round(data_in.time)== round(flo_list(nf_lo)));
                            x2          = find(round(data_in.time)== round(flo_list(nf_lo)+flo_wind));
                            
                            y1          = find(round(data_in.freq)== round(fhi_list(nf_hi)));
                            y2          = find(round(data_in.freq)== round(fhi_list(nf_hi)+fhi_wind));
                            
                            if isempty(x1) || isempty(x2) || isempty(y1) || isempty(y2)
                                error('ahhhh')
                            else
                                pow      = nanmean(data_in.powspctrm(nchan,y1:y2,x1:x2),3);
                                pow      = squeeze(mean(pow,2));
                                
                                if size(pow,1) > 1 || size(pow,2) > 1
                                    error('oohhhhhhh')
                                else
                                    
                                    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%.5f\t%s\t%s\n',ls_group{ngroup},[ls_group{ngroup} num2str(sb)],ls_threewise,chan_method, ...
                                        chn_type,ls_freq,ls_time,pow,bsl_type,nrm_type);
                                    
                                end
                            end
                        end
                    end
                    
                end
            end
        end
    end
    
    fclose(fid);
    
end