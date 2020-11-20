clear;

suj_list                            = dir('../data/ds/*.ds');

for nsuj = 1:length(suj_list)
    
    fname                           = [suj_list(nsuj).folder filesep suj_list(nsuj).name];
    suj_name                        = strsplit(suj_list(nsuj).name,'_');
    suj_name                        = suj_name{1};
    
    events                          = ft_read_event(fname);
    events                          = events(find(strcmp({events.type},'UPPT001')));
    events                          = [events.value;events.sample]';
    
    ntrial                          = 0;
    all_fix                         = find(events(:,1) == 103); % find first fixation
    all_trl                         = {};
    
    trialinfo                       = [];
    
    for nt = 1:length(all_fix)
        if nt < length(all_fix)
            all_trl{nt}             = events(all_fix(nt):all_fix(nt+1)-1,:);
        else
            all_trl{nt}             = events(all_fix(nt):end,:);
        end
        
        trl                         = all_trl{nt};
        find_zeros                  = find(trl(:,1) == 105);
        time_zeros                  = trl(find_zeros,2);
        diff_zeros                  = mean(diff(time_zeros)) / 1200;
        
        if diff_zeros > 0.7
            trialinfo(nt,1)         = 1;
        elseif diff_zeros < 0.5 && diff_zeros > 0.4
            trialinfo(nt,1)         = 2;
        else
            trialinfo(nt,1)         = 3; % 1 - frq condition
        end
        
        find_tar                    = find(ismember(trl(:,1),[111 121 113 123 115 125 117 127]));
        
        if isempty(find_tar)
            trialinfo(nt,2)         = 0; % 2 - target condition
            trialinfo(nt,3)         = 0; % 3 - rt
        else
            onset_tar               = trl(find_tar,2);
            onset_last_cue          = trl(find_zeros(end),2);
            nb_cycles               = round(((onset_tar - onset_last_cue) / 1200)/diff_zeros);
            trialinfo(nt,2)         = nb_cycles;
            trialinfo(nt,3)         = (onset_tar - onset_last_cue) / 1200; % rt
        end
        
        end_trial                   = find(ismember(trl(:,1),[102 202 204]));
        strt_trial                  = find(ismember(trl(:,1),103));
        lngth_trial                 = (trl(end_trial,2) - trl(strt_trial,2)) / 1200;
        trialinfo(nt,4)             = lngth_trial; % 4 - length trial
        
    end
    
    cfg                             = [];
    cfg.dataset                     = fname;
    cfg.trialfun                    = 'ft_trialfun_general';
    cfg.trialdef.eventtype          = 'UPPT001';
    cfg.trialdef.eventvalue         = 103; %lock to fixation
    cfg.trialdef.prestim            = 1;
    cfg.trialdef.poststim           = 8;
    cfg                             = ft_definetrial(cfg);
    
    cfg.trl                         = [cfg.trl trialinfo];
    
    cfg.channel                     = {'MEG'};
    cfg.continuous                  = 'yes';
    cfg.bsfilter                    = 'yes';
    cfg.bsfreq                      = [49 51; 99 101; 149 151];
    cfg.precision                   = 'single';
    data                            = ft_preprocessing(cfg);
    
    cfg                             = [];
    cfg.resamplefs                  = 100;
    cfg.detrend                     = 'no';
    cfg.demean                      = 'no';
    data                            = ft_resampledata(cfg, data);
    data                            = rmfield(data,'cfg');
    
    fname                           = ['../data/preproc/' suj_name '.fixlock.raw.mat'];
    fprintf('saving %s\n',fname);
    save(fname,'data','-v7.3');
    
    keep suj_list nsuj
    
end