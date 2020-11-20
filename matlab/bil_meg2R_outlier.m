function bil_meg2R_outlier

if ispc
    start_dir = 'P:/3015079.01/';
else
    start_dir = '/project/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

all_struct                                              = [];

for sb = 1:length(suj_list)
    
    suj                                                 = suj_list{sb};%(sb).name(1:6);
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
    
    % calc_tukey(cell2mat(trialinfo.repRT));
    
    
    list_cue                                            = {'pre','retro'};
    list_task                                           = {'Orientation','Frequency'};
    
    sub_struct.suj                                      = repmat({suj},height(trialinfo),1);
    sub_struct.cue_type                                 = [list_cue(trialinfo.cue)]';
    sub_struct.feat_attend                              = [list_task(trialinfo.task)]';
    sub_struct.react_time                               = cell2mat(trialinfo.repRT) * 1000;
    sub_struct.corr_rep                                 = cell2mat(trialinfo.repCorrect);
    sub_struct                                          = struct2table(sub_struct);
    
    new_struct                                          = [];
    i                                                   = 0;
    
    for ncue = 1:length(list_cue)
        for ntask = 1:length(list_task)
            
            i                                           = i + 1;
            find_trials                                 = find(strcmp(sub_struct.cue_type,list_cue{ncue}) & ...
                strcmp(sub_struct.feat_attend,list_task{ntask}));
            
            vct                                         = [sub_struct.react_time(find_trials) sub_struct.corr_rep(find_trials)];
            [indx_inliers]                              = calc_tukey(vct(:,1));
            
            new_struct(i).suj                          	= sub_struct.suj(1);
            new_struct(i).cue_type                      = list_cue{ncue};
            new_struct(i).feat_attend                   = list_task{ntask};
            new_struct(i).rt                            = median(vct(indx_inliers,1));
            
            tmp                                         = vct(indx_inliers,2);
            new_struct(i).perc_corr                 	= length(tmp(tmp==1)) ./ length(tmp); clear tmp vct find_* indx_*;
            
        end
    end
    
    all_struct                                          = [all_struct;struct2table(new_struct)];
    
    clear sub_struct new_struct mapping;
    
end

clearvars -except all_struct suj_list ext_* start_dir;

writetable(all_struct,['../doc/bil.behavioralReport.n' num2str(length(suj_list)) '.condspec.outlier.txt']);