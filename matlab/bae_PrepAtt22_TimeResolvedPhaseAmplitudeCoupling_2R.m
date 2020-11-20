clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_group{1}        = suj_group{1}(2:22);

suj_group{1}        = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj             = suj_list{sb};
        
        %         ext_bsl         = 'm300m150';
        %         lst_tme         = {'m150m0','p0p150','p150p300','p300p450','p450p600','p600p750','p750p900','p900p1050'};
        %         lst_new_tme     = {'m150','p0','p150','p300','p450','p600','p750','p900'};
        
        ext_bsl         = 'm600m200';
        lst_tme         = {'p600p1000'};
        lst_new_tme     = {'p600p1000'};
        
        %         ext_bsl         = 'm1000m200';
        %         lst_tme         = {'p200p1000'};
        %         lst_new_tme     = {'p200p1000'};
        
        lst_cnd         = {'RCnD','LCnD','NCnD'};
        lst_method      = {'PLV.optimisedPACMinEvoked'};
        lst_chn         = {'aud_R'};
        
        
        ext_data        = 'prep21';
        dir_data        = '../../PAT_MEG21/pat.field/data/';
        
        for ncue = 1:length(lst_cnd)
            for nmethod = 1:length(lst_method)
                for nchan = 1:length(lst_chn)
                    for ntime = 1:length(lst_tme)
                        
                        fname   = [dir_data suj '.' lst_cnd{ncue} '.' ext_data '.' lst_tme{ntime} '.' lst_chn{nchan} '.' lst_method{nmethod} '.mat'];
                        
                        fprintf('Loading %30s\n',fname);
                        load(fname);
                        
                        data_act                  = seymour_pac.mpac_norm; clear seymour_pac
                        
                        fname   = [dir_data suj '.' lst_cnd{ncue} '.' ext_data '.' ext_bsl '.' lst_chn{nchan} '.' lst_method{nmethod} '.mat'];
                        
                        fprintf('Loading %30s\n',fname);
                        load(fname);
                        
                        data_bsl                  = seymour_pac.mpac_norm;
                        
                        allsuj_data{ngroup}{sb,ncue,nmethod,nchan,ntime}.powspctrm(1,:,:)                 = (data_act-data_bsl)./data_bsl;
                        allsuj_data{ngroup}{sb,ncue,nmethod,nchan,ntime}.freq                             = seymour_pac.amp_freq_vec;
                        allsuj_data{ngroup}{sb,ncue,nmethod,nchan,ntime}.time                             = seymour_pac.pha_freq_vec;
                        allsuj_data{ngroup}{sb,ncue,nmethod,nchan,ntime}.label                            = lst_chn(nchan);
                        allsuj_data{ngroup}{sb,ncue,nmethod,nchan,ntime}.dimord                           = 'chan_freq_time';
                        
                        clear seymour_pac
                        
                    end
                end
            end
        end
    end
end

clc ; clearvars -except allsuj_data lst*;

fOUT = '../documents/4R/prep21_pac_TimeResolved_p600p1000.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','METHOD','CHAN','TIME','LOW_FREQ','HIGH_FREQ','POW');

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        for ncue = 1:size(allsuj_data{ngroup},2)
            for nmethod = 1:size(allsuj_data{ngroup},3)
                for nchan = 1:size(allsuj_data{ngroup},4)
                    for ntime = 1:size(allsuj_data{ngroup},5)
                        
                        fhi_wind  = 10;
                        fhi_list  = 60:fhi_wind:90;
                        
                        flo_wind = 0;
                        flo_list = 7:15;
                        
                        for nf_hi = 1:length(fhi_list)
                            for nf_lo = 1:length(flo_list)
                                
                                data_to_write  = allsuj_data{ngroup}{sb,ncue,nmethod,nchan,ntime};
                                
                                ls_group        = {'prep21'};
                                ls_threewise    = {'ipsilateral','contralateral','uninformative'};
                                
                                name_chan       = data_to_write.label{:};
                                
                                if flo_list(nf_lo) > 9
                                    name_low_freq   = [num2str(flo_list(nf_lo)) 'Hz'];
                                else
                                    name_low_freq   = ['0' num2str(flo_list(nf_lo)) 'Hz'];
                                end
                                
                                name_hi_freq    = [num2str(fhi_list(nf_hi)) 'Hz'];
                                name_time       = lst_new_tme{ntime};
                                chan_method     = lst_method{nmethod};
                                
                                x1       = find(round(data_to_write.time)== round(flo_list(nf_lo)));
                                x2       = find(round(data_to_write.time)== round(flo_list(nf_lo)+flo_wind));
                                
                                y1       = find(round(data_to_write.freq)== round(fhi_list(nf_hi)));
                                y2       = find(round(data_to_write.freq)== round(fhi_list(nf_hi)+fhi_wind));
                                
                                if isempty(x1) || isempty(x2) || isempty(y1) || isempty(y2)
                                    error('ahhhh')
                                else
                                    pow      = mean(data_to_write.powspctrm(1,y1:y2,x1:x2),3);
                                    pow      = squeeze(mean(pow,2));
                                    
                                    if size(pow,1) > 1 || size(pow,2) > 1
                                        error('oohhhhhhh')
                                    else
                                        
                                        fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%.5f\n',ls_group{ngroup},[ls_group{ngroup} num2str(sb)],ls_threewise{ncue},lst_method{nmethod}, ...
                                            name_chan,name_time,name_low_freq,name_hi_freq,pow);
                                        
                                    end
                                    
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