function bil_meg2R

if ispc
    start_dir = 'P:/3015079.01/';
else
    start_dir = '/project/3015079.01/';
end

suj_list                                                = dir([start_dir '/data/sub*/preproc/*rej.mat']);
    
all_struct                                              = [];

for sb = 1:length(suj_list)
    
    suj                                                 = suj_list(sb).name(1:6);
    ntrial_tot                                          = 0;
    sub_struct                                          = [];
    
    fileName                                            = dir([start_dir '/data/' suj '/log/*_JYcent_block_Logfile.mat']);
    fileName                                            = [fileName(1).folder '/' fileName(1).name];
    
    fprintf('Loading %s\n',fileName);
    load(fileName);
    
    mapping                                             = [];
    
    for nb = 1:length(Info.MappingList)
        mapping                                         = [mapping; repmat(Info.MappingList(nb),64,1) repmat(nb,64,1) [1:64]'];
    end
    
    trialinfo                                           = Info.TrialInfo; clear Info;
    
    ix_end                                              = [];
    
    for n = 1:height(trialinfo)
        if isempty(trialinfo(n,:).repRT{:})
            ix_end                                      = [ix_end;n];
        end
    end
    
    if ~isempty(ix_end)
        trialinfo                                       = trialinfo(1:ix_end-1,:);
        mapping                                         = mapping(1:ix_end-1,:);
    end
    
    exclude_correct                                     = 'no';
    exclude_reaction                                 	= 'yes';
    
    original_nb_trials                                  = height(trialinfo);
    
    % exclude blocks with perf either at ceiling or chance
    switch exclude_correct
        case 'yes'
            [trialinfo,mapping]                         = h_excludebehav_percond(trialinfo,mapping,0.6,0.95);
            ext_name_1                                  = 'excl.cor';
        case 'no'
            ext_name_1                                  = 'keep.cor';
    end
    
    % excude RT outliers based on the tukey method on all trials
    switch exclude_reaction
        case 'yes'
            [indx]                                      = calc_tukey(cell2mat(trialinfo.repRT));
            trialinfo                                 	= trialinfo(indx,:);
            mapping                                   	= mapping(indx,:);
            ext_name_2                                  = 'excl.rt';
        case 'no'
            ext_name_2                                  = 'keep.rt';
    end
    
    final_nb_trials                                     = height(trialinfo);
    
    list_cue                                            = {'pre','retro'};
    list_task                                           = {'Orientation','Frequency'};
    list_color                                          = {'black','white'};
    
    sub_struct.suj                                      = repmat({suj},height(trialinfo),1);
    
    sub_struct.perc_rej                                 = repmat((final_nb_trials ./ original_nb_trials) * 100,final_nb_trials,1);
    
    sub_struct.cue_type                                 = [list_cue(trialinfo.cue)]';
    sub_struct.feat_attend                              = [list_task(trialinfo.task)]';
    
    a                                                   = sub_struct.cue_type;
    b                                                   = repmat({'-'},length(a),1);
    c                                                   = sub_struct.feat_attend;
    
    sub_struct.cue_feat                                 = strcat(a,b,c);
    
    sub_struct.match                                    = trialinfo.match;
    
    sub_struct.tarlen                                   = trialinfo.DurTar*1000;
    sub_struct.tar_color                                = [list_color(trialinfo.color)]';
    
    sub_struct.react_time                               = cell2mat(trialinfo.repRT) * 1000;
    sub_struct.corr_rep                                 = cell2mat(trialinfo.repCorrect);
    
    sub_struct.rep_button                               = cell2mat(trialinfo.repButton);
    
    vct                                                 = trialinfo.target;
    sub_struct.tarOri                                   = vct(:,1);
    sub_struct.tarFreq                                  = vct(:,2);
    
    vct                                                 = trialinfo.probe;
    sub_struct.proOri                                   = vct(:,1);
    sub_struct.proFreq                                  = vct(:,2);
    
    sub_struct.mapping                                  = mapping(:,1);
    sub_struct.bloc_nb                                  = mapping(:,2);
    
    sub_struct.trial_nb_blc                             = mapping(:,3);
    sub_struct.trial_nb_tot                             = [1:height(trialinfo)]';
    
    sub_struct.sub_match                                = [];
    
    for nt = 1:length(sub_struct.corr_rep)
        
        if sub_struct.corr_rep(nt) == 1
            sub_struct.sub_match(nt,1)                  = sub_struct.match(nt);
        else
            if sub_struct.match(nt) == 1
                sub_struct.sub_match(nt,1)              = 0;
            else
                sub_struct.sub_match(nt,1)              = 1;
            end
        end
        
    end
    
    sub_struct                                          = struct2table(sub_struct);
    all_struct                                          = [all_struct;sub_struct];
    
    clear sub_struct mapping;
    
end

clearvars -except all_struct suj_list ext_* start_dir;

writetable(all_struct,[start_dir '/data/bil.behavioralReport.n' num2str(length(suj_list)) '.' ext_name_1 '.' ext_name_2 '.txt']);
writetable(all_struct,['../doc/bil.behavioralReport.n' num2str(length(suj_list)) '.' ext_name_1 '.' ext_name_2 '.txt']);