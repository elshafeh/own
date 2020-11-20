clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

% [~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_group{1}        = suj_group{1}(2:22);

suj_group{1}        = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        list_ix_cue         = {'RCnD','LCnD','NCnD'};
        list_method         = {'plv'};
        
        for ncue = 1:length(list_ix_cue)
            for nmethod = 1:length(list_method)
                
                fname_in          = ['../data/paper_data/' suj '.' list_ix_cue{ncue} '.prep21.AV.TDBU.' list_method{nmethod} 'MinEvoked.mat'];
                fprintf('Loading %s\n',fname_in);
                load(fname_in)
                
                freq              = [];
                freq.time         = freq_conn.time;
                freq.freq         = freq_conn.freq;
                freq.dimord       = 'chan_freq_time';
                
                freq.powspctrm    = [];
                freq.label        = {};
                
                i                 = 0;
                
                original_list     = [2 3 4 6 14 16 18 19] ; %[3 4 5 6 8 13 14];
                
                list_chan_seed    =  4;
                list_chan_target  =  original_list+4 ; % 1:length(freq_conn.label);
                
                chan_comb         = [];
                
                for nseed = 1:length(list_chan_seed)
                    for ntarget = 1:length(list_chan_target)
                        
                        if list_chan_target(ntarget) ~= list_chan_seed(nseed)
                            
                            if ~isempty(chan_comb)
                                chk1                    =  chan_comb(chan_comb(:,1) ==  list_chan_seed(nseed) &  chan_comb(:,2) ==  list_chan_target(ntarget));
                                chk2                    =  chan_comb(chan_comb(:,2) ==  list_chan_seed(nseed) &  chan_comb(:,1) ==  list_chan_target(ntarget));
                            else
                                chk1                    = [];
                                chk2                    = [];
                            end
                            
                            if isempty(chk1) && isempty(chk2)
                                
                                i                       = i + 1;
                                pow                     = freq_conn.powspctrm(list_chan_seed(nseed),list_chan_target(ntarget),:,:);
                                pow                     = squeeze(pow);
                                
                                freq.powspctrm(i,:,:)   = pow;
                                freq.label{i}           = [list_method{nmethod} ' ' freq_conn.label{list_chan_seed(nseed)} ' ' freq_conn.label{list_chan_target(ntarget)}];
                                
                            end
                        end
                    end
                end
                
                
                cfg                                       = [];
                cfg.baseline                              = [-0.6 -0.2];
                cfg.baselinetype                          = 'relchange';
                allsuj_data{ngroup}{sb,ncue,nmethod}      = ft_freqbaseline(cfg,freq);
                
                clear tmp freq ;
                
            end
        end
    end
end

clearvars -except allsuj_* list_* ;

fOUT = '../documents/4R/prep21_allTDBU_slct_VirtualConnectivity_MinEvoked_2Freq_sep_time.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','TARGET','FREQ','TIME','POW','CUE_CAT','CUE_CONC','CUE_ORIG','SEED','SEED_HEMI','METHOD');

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        
        fprintf('Writing Data for suj%d\n',sb)
        
        for ncue = 1:size(allsuj_data{ngroup},2)
            for nmethod = 1:size(allsuj_data{ngroup},3)
                for nchan = 1:length(allsuj_data{ngroup}{sb,ncue,nmethod}.label)
                    
                    frq_win  = 0;
                    frq_list = [9 13];
                    
                    tim_wind = 0.1;
                    tim_list = 0.6:tim_wind:0.9;
                    
                    for nfreq = 1:length(frq_list)
                        for ntime = 1:length(tim_list)
                            
                            ls_group            = {'prep21_young'};
                            ls_cue              = {'R','L','RL'};
                            ls_cue_cat          = {'informative','informative','uninformative'};
                            ls_threewise        = {'RCue','LCue','NCue'};
                            original_cue_list   = {'Ipsilateral','Contralateral','Uninformative'};
                            
                            ls_chan             = allsuj_data{ngroup}{sb,ncue,nmethod}.label{nchan};
                            
                            ls_time             = [num2str(tim_list(ntime)*1000) 'ms'];
                            
                            if frq_list(nfreq) < 10
                                ls_freq             = ['0' num2str(frq_list(nfreq)) 'Hz'];
                            else
                                ls_freq             = [num2str(frq_list(nfreq)) 'Hz'];
                            end
                            
                            name_chan           =  ls_chan;
                            name_parts          =  strsplit(name_chan,' ');
                            
                            chan_seed           = [name_parts{2} name_parts{3}];
                            chan_mod            = name_parts{1};
                            
                            chan_target         = [];
                            for rox = 4:length(name_parts)
                                chan_target         = [chan_target name_parts{rox}];
                            end
                            
                            if frq_list(nfreq) < 11
                                freq_cat = 'high_cat';
                            else
                                freq_cat = 'high_freq';
                            end
                            
                            chn_prts = strsplit(name_chan,'_');
                            
                            x1       = find(round(allsuj_data{ngroup}{sb,ncue,nmethod}.time,2)== round(tim_list(ntime),2));
                            x2       = find(round(allsuj_data{ngroup}{sb,ncue,nmethod}.time,2)== round(tim_list(ntime)+tim_wind,2));
                            
                            y1       = find(round(allsuj_data{ngroup}{sb,ncue,nmethod}.freq)== round(frq_list(nfreq)-frq_win));
                            y2       = find(round(allsuj_data{ngroup}{sb,ncue,nmethod}.freq)== round(frq_list(nfreq)+frq_win));
                            
                            if isempty(x1) || isempty(x2) || isempty(y1) || isempty(y2)
                                error('ahhhh')
                            else
                                pow      = mean(allsuj_data{ngroup}{sb,ncue,nmethod}.powspctrm(nchan,y1:y2,x1:x2),3);
                                pow      = squeeze(mean(pow,2));
                                
                                if size(pow,1) > 1 || size(pow,2) > 1
                                    error('oohhhhhhh')
                                else
                                    
                                    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%.5f\t%s\t%s\t%s\t%s\t%s\t%s\n',ls_group{ngroup},[ls_group{ngroup} num2str(sb)],ls_cue{ncue},chan_target,ls_freq,ls_time,pow,ls_cue_cat{ncue},original_cue_list{ncue},ls_threewise{ncue},chan_seed,[name_parts{3} 'Hemi'],chan_mod);
                                    
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

clearvars -except allsuj_* list_* ;