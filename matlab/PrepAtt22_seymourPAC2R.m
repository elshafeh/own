clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

% load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat

suj_group{1} = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj             = suj_list{sb};
        
        lst_cnd         = {'RCnD','LCnD','NCnD'};
        lst_mth         = {'canolty','tort','PLV','ozkurt'};
        lst_chn         = {'aud_R','aud_L'};
        lst_tme         = {'m600m200','p600p1000'};
        
        for ntime = 1:length(lst_tme)
            
            ihi = 0 ;
            
            for ncue = 1:length(lst_cnd)
                for nchan = 1:length(lst_chn)
                    for nmethod = 1:length(lst_mth)
                        
                        ihi     = ihi + 1;
                        
                        fname   = ['../data/paper_data/' suj '.' lst_cnd{ncue} '.prep21.AV.' lst_tme{ntime} '.low.7t20.high2step.50t110.' ...
                            lst_chn{nchan} '.' lst_mth{nmethod} '.optimisedPACMinEvoked.mat'];
                        
                        fprintf('Loading %30s\n',fname);
                        load(fname);
                        
                        m_pac                                     = seymour_pac.mpac;
                        m_pac                                     = 0.5 .* (log((1+m_pac)./(1-m_pac)));
                        
                        tmp{ihi}.powspctrm(1,:,:)                 = m_pac;
                        tmp{ihi}.freq                             = seymour_pac.amp_freq_vec;
                        tmp{ihi}.time                             = seymour_pac.pha_freq_vec;
                        
                        tmp{ihi}.label                            = {[lst_chn{nchan} '_' lst_cnd{ncue} '_' lst_mth{nmethod}]};
                        tmp{ihi}.dimord                           = 'chan_freq_time';
                        
                        clear seymour_pac
                        
                    end
                end
            end
            
            cfg = []; cfg.parameter = 'powspctrm' ; cfg.appenddim = 'chan';
            tmp_time{ntime} = ft_appendfreq(cfg,tmp{:}); clear tmp ;
            
        end
        
        allsuj_data{ngroup}{sb,1}           = tmp_time{2};
        
        pac_bsl                             = tmp_time{1}.powspctrm;
        pac_act                             = tmp_time{2}.powspctrm;
        
        allsuj_data{ngroup}{sb,1}.powspctrm = pac_act - pac_bsl ; %(pac_act - pac_bsl)./pac_bsl; % pac_act - pac_bsl ; % (pac_act - pac_bsl)./pac_bsl; %
        clear tmp_time;
        
    end
end

clearvars -except allsuj_data lst_* ; clc ;

fOUT = '/Users/heshamelshafei/GoogleDrive/PhD/Fieldtripping/documents/4R/prep21_pre_target_seymourPAC_p600p1000_2_low_sep_high_abs_norm.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','METHOD','CHAN','HIGH_FREQ','LOW_FREQ','POW','BSL_TYPE','NORM_TYPE');

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        for nchan = 1:length(allsuj_data{ngroup}{sb,1}.label)
            
            fhi_wind  = 10;
            fhi_list  = 60:fhi_wind:90;
            
            flo_wind = 0;
            flo_list = [9 13];
            
            for nf_hi = 1:length(fhi_list)
                for nf_lo = 1:length(flo_list)
                    
                    ls_group            = {'prep21_Young'};
                    
                    data_in             = allsuj_data{ngroup}{sb,1};
                    name_chan           = data_in.label{nchan};
                    
                    name_parts          = strsplit(name_chan,'_');
                    
                    bsl_type            = 'abs';
                    nrm_type            = 'nonorm';
                    chn_type            = [name_parts{2} 'Hemi'];
                    cue_type            = name_parts{3};
                    
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
                    
                    chan_method = name_parts{end};
                    
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

fclose(fid);