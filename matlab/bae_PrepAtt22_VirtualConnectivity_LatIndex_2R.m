clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));


[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        list_ix_cue         = {'RCnD','LCnD','NCnD'};
        list_method         = {'plvMinEvoked100Slct'};
        
        for ncue = 1:length(list_ix_cue)
            for nmethod = 1:length(list_method)
                
                fname_in          = ['../data/' suj '/field/' suj '.' list_ix_cue{ncue} '.NewAVSchaef.' list_method{nmethod} '.mat'];
                fprintf('Loading %s\n',fname_in);
                load(fname_in)
                
                freq              = [];
                freq.time         = freq_conn.time;
                freq.freq         = freq_conn.freq;
                freq.dimord       = 'chan_freq_time';
                
                freq.powspctrm    = [];
                freq.label        = {};
                
                i                 = 0;
                
                list_chan_seed    =  1:4;
                list_chan_target  =  5:17;
                
                for ntarget = 1:length(list_chan_target)
                    
                    for nseed = 1:length(list_chan_seed)
                        
                        pow                     = freq_conn.powspctrm(list_chan_seed(nseed),list_chan_target(ntarget),:,:);                        
                        new_pow(nseed,:,:)      = squeeze(pow);
                        
                        clear pow ;
                        
                    end
                    
                    audL                    = new_pow(3,:,:);
                    audR                    = new_pow(4,:,:);
                    
                    visL                    = new_pow(1,:,:);
                    visR                    = new_pow(2,:,:);
                    
                    aud_lIdx                = (audR-audL) ./ ((audR+audL)/2);
                    vis_lIdx                = (visR-visL) ./ ((visR+visL)/2);
                    
                    clear new_pow ;
                    
                    i                       = i + 1;
                    freq.powspctrm(i,:,:)   = squeeze(aud_lIdx);
                    freq.label{i}           = [list_method{nmethod}(1:3) '_aud_LatIndex_' freq_conn.label{list_chan_target(ntarget)}];
                    
                    i                       = i + 1;
                    freq.powspctrm(i,:,:)   = squeeze(vis_lIdx);
                    freq.label{i}           = [list_method{nmethod}(1:3) '_vis_LatIndex_' freq_conn.label{list_chan_target(ntarget)}];
                    
                end
            
                allsuj_data{ngroup}{sb,ncue,nmethod} = freq ; clear freq ; clc;
                
            end
        end
    end
end

clearvars -except allsuj_* list_* ;

fOUT = '../documents/4R/NewBroadM_Alpha_AlSchaef_AudioVisual_LatIndexFuncitonalConnectivity_100Slct_2Freq_and_Beta_new_time.txt';
fid  = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','TARGET','FREQ','TIME','POW','CUE_CAT','CUE_CONC','CUE_ORIG','SEED','SEED_HEMI','SEED_MODALITY');

for ngroup = 1:length(allsuj_data)
    for sb = 1:size(allsuj_data{ngroup},1)
        
        fprintf('Writing Data for suj%d\n',sb)
        
        for ncue = 1:size(allsuj_data{ngroup},2)
            for nmethod = 1:size(allsuj_data{ngroup},3)
                for nchan = 1:length(allsuj_data{ngroup}{sb,ncue,nmethod}.label)
                    
                    frq_win  = [4 4 10 10] ;
                    frq_list = [7 11 20 30];
                    
                    tim_wind = 0.25;
                    tim_list = 0.6:tim_wind:1;
                    
                    for nfreq = 1:length(frq_list)
                        for ntime = 1:length(tim_list)
                            
                            ls_group            = {'allyoung'};
                            ls_cue              = {'R','L','RL'};
                            ls_cue_cat          = {'informative','informative','uninformative'};
                            ls_threewise        = {'RCue','LCue','NCue'};
                            original_cue_list   = {'R','L','N'};
                            
                            ls_chan             = allsuj_data{ngroup}{sb,ncue,nmethod}.label{nchan};
                            
                            ls_time             = [num2str(tim_list(ntime)*1000) 'ms'];
                            
                            if frq_list(nfreq) < 10
                                ls_freq             = ['0' num2str(frq_list(nfreq)) 'Hz'];
                            else
                                ls_freq             = [num2str(frq_list(nfreq)) 'Hz'];
                            end
                            
                            name_chan           =  ls_chan;
                            name_parts          =  strsplit(name_chan,'_');
                            
                            chan_seed           = [name_parts{2} name_parts{3}];
                            chan_mod            = name_parts{1};
                            chan_target         = [name_parts{4} name_parts{5}];
                            
                            if frq_list(nfreq) < 11
                                freq_cat = 'high_cat';
                            else
                                freq_cat = 'high_freq';
                            end
                            
                            chn_prts = strsplit(name_chan,'_');
                            
                            x1       = find(round(allsuj_data{ngroup}{sb,ncue,nmethod}.time,2)== round(tim_list(ntime),2));
                            x2       = find(round(allsuj_data{ngroup}{sb,ncue,nmethod}.time,2)== round(tim_list(ntime)+tim_wind,2));
                            
                            y1       = find(round(allsuj_data{ngroup}{sb,ncue,nmethod}.freq)== round(frq_list(nfreq)));
                            y2       = find(round(allsuj_data{ngroup}{sb,ncue,nmethod}.freq)== round(frq_list(nfreq)+frq_win(nfreq)));
                            
                            if isempty(x1) || isempty(x2) || isempty(y1) || isempty(y2)
                                error('ahhhh')
                            else
                                pow      = mean(allsuj_data{ngroup}{sb,ncue,nmethod}.powspctrm(nchan,y1:y2,x1:x2),3);
                                pow      = squeeze(mean(pow,2));
                                
                                if size(pow,1) > 1 || size(pow,2) > 1
                                    error('oohhhhhhh')
                                else
                                    
                                    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%.5f\t%s\t%s\t%s\t%s\t%s\t%s\n',ls_group{ngroup},[ls_group{ngroup} num2str(sb)],ls_cue{ncue},chan_target,ls_freq,ls_time,pow,ls_cue_cat{ncue},original_cue_list{ncue},ls_threewise{ncue},chan_seed,[name_parts{3} 'Hemi'],name_parts{2});
                                    
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