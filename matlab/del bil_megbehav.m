clear;

if ispc
    start_dir = 'P:/3015079.01/';
else
    start_dir = '/project/3015079.01/';
end

suj_list                                                = dir([start_dir '/data/sub*/preproc/*rej.mat']);
all_matrx                                               = [];

for sb = 1:length(suj_list)
    
    suj                                                 = suj_list(sb).name(1:6);
    ntrial_tot                                          = 0;
    sub_struct                                          = [];
    
    fileName                                            = [start_dir '/data/' suj '/log/' suj '_JYcent_block_Logfile.mat'];
    
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
    
    list_cue                                            = {'pre','retro'};
    list_task                                           = {'Orientation','Frequency'};
    list_color                                          = {'black','white'};
    
    sub_struct.suj                                      = repmat(sb,height(trialinfo),1);
    
    sub_struct.cue_type                                 = trialinfo.cue;%[list_cue(trialinfo.cue)]';
    sub_struct.feat_attend                              = trialinfo.task;%[list_task(trialinfo.task)]';
    
    a                                                   = sub_struct.cue_type;
    b                                                   = repmat({'-'},length(a),1);
    c                                                   = sub_struct.feat_attend;
    
    %     sub_struct.cue_feat                                 = strcat(a,b,c);
    
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
    sub_mtrx                                            = [sub_struct.suj sub_struct.cue_type sub_struct.feat_attend sub_struct.corr_rep sub_struct.react_time];
    
    all_matrx                                           = [all_matrx;sub_mtrx];
    
    clear sub_struct mapping sub_mtrx;
    
end

clearvars -except all_matrx;

suj_list                                                = unique(all_matrx(:,1));

final_mtrx                                              = [];

for ns = 1:length(suj_list)
    
    data                                                = [];
    i                                                   = 0;
    
    for ncue = 1:2
        for nfeat = 1:2
            
            tmp                                         = all_matrx(all_matrx(:,1) == ns & all_matrx(:,2) == ncue & all_matrx(:,3) == nfeat,:);
            i                                           = i +1;
            data.rts(i)                                 = mean(tmp(:,5));
            data.pc(i)                                  = sum(tmp(:,4)) ./ length(tmp);
            data.suj(i)                                 = ns;
            data.cue(i)                                 = ncue;
            data.feat(i)                                = nfeat;
            
        end
    end
    
    data                                                = BIS(data);
    
    final_mtrx                                          = [final_mtrx; data.suj(:) data.cue(:) data.feat(:) data.rts(:) data.pc(:) data.bis(:)];
        
end

clearvars -except all_matrx final_mtrx;

mean_mtrx                                               = [];
i                                                       = 0;

for ncue = 1:2
    for nfeat = 1:2
        
        tmp                                             = final_mtrx(final_mtrx(:,2) == ncue & final_mtrx(:,3) == nfeat,6);
        i                                               = i + 1;
        mean_mtrx(i)                                    = mean(tmp);
        
    end
end

clearvars -except all_matrx final_mtrx mean_mtrx;