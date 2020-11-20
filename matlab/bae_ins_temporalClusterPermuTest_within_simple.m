% ins_temporalClusterPermuTest_within_simple.m
function result = ins_temporalClusterPermuTest_within_simple(data, def, cfg, structTemplate)
% http://meg.univ-amu.fr/wiki/Main_Page %%%%%%%%%%%%%
%
% Nonparametric MEG data analysis of effects within two conditions
% on two levels (paired samples) for each group. Permutation test based on
% temporal clusters on the data grouped into regions of interest.
%
% DEPENDANCES:
% This function uses the FieldTrip MATLAB software toolbox
% (http://www.fieldtriptoolbox.org/)
%
% USAGE:
% result = ins_temporalClusterPermuTest_within_simple(
%                               data,
%                               def,
%                               cfg,
%                               structTemplate)
%
% INPUTS:
% cf. function ins_temporalClusterPermuTest_WithinBetween.m
%
% OUTPUTS:
% result = %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% REFERENCES:
% * Cluster-based permutation tests on event related fields.
%   http://www.fieldtriptoolbox.org/tutorial/cluster_permutation_timelock
% ________________________________
% Bernard Giusiano & Sophie Chen
% INSERM UMR 1106 Institut de Neurosciences des Systèmes
% Sept/2015 (first version)
% Nov/2015 (this version)
% http://ins.univ-amu.fr
 
%% dimensions and grand average parameters
groupLevels = unique(def.list.group);
 
sizeSamples = size(data(1,1).(def.time));
nSamples = sizeSamples(2);
 
cfgGM = [];
cfgGM.keepindividual = 'yes';
cfgGM.latency = cfg.latency;
 
%% parameters specific to this function
cfg.statistic = 'depsamplesT';    % paired samples
% cfg.parameter = string          (default = 'trial' or 'avg')
 
% design : in the loop on criteria because it may be specific for each group
 
%% loop on criteria
for roi_ind = 1:length(def.list.roi)
    roi = char(def.list.roi(roi_ind));
    fig = figure;
    set(fig,'Units','pixels');
    set(fig,'Position',[10 74 1419 740]);
    nplot = 1;
 
    for group_ind = 1:length(groupLevels)
        group = char(groupLevels(group_ind));
        groupSubjects = def.list.subject(strcmp(def.list.group,group));
 
        % design
        nSubjects = length(groupSubjects);
        design = zeros(2,2*nSubjects);
        for i = 1:nSubjects
            design(1,i) = i;
        end
        for i = 1:nSubjects
            design(1,nSubjects+i) = i;
        end
        design(2,1:nSubjects)             = 1;
        design(2,nSubjects+1:2*nSubjects) = 2;
        cfg.design = design;            % design matrix
        cfg.uvar  = 1;                  % indice of the unit variable
        cfg.ivar  = 2;                  % number or list with indices indicating the independent variable(s)
        % end design
 
        for other_ind = 1:length(def.list.other)
            other = char(def.list.other(other_ind));
 
            % components of grand average
            component = cell(2,1);  % 2 conditions. 2° dim -> length(def.list.subject) but initialized to 1
            ind_component = zeros(2);
 
            for subject_ind = 1:length(groupSubjects)
                subject = char(groupSubjects(subject_ind));
 
                for cond_ind = 1:length(def.list.cond)
                    cond = char(def.list.cond(cond_ind));
 
                    disp([roi,' ',cond,' ',other,' ',group,' ',subject]);
                    object_ind = find(strcmp({data.(def.roi)},roi) & strcmp({data.(def.cond)},cond)...
                        & strcmp({data.(def.other)},other) & strcmp({data.(def.subject)},subject));
 
                    objectstat = [cond subject];
                    eval([objectstat ' = structTemplate;']);
                    eval([objectstat '.trial{1,1} = data(' num2str(object_ind) ').(def.value);']);
                    eval([objectstat '.time{1,1} = data(' num2str(object_ind) ').(def.time);']);
                    eval([objectstat '.fsample = nSamples;']);
                    eval([objectstat '.sampleinfo = [1 nSamples];']);
                    eval([objectstat '.trialinfo = 1;']);
                    ind_component(cond_ind) = ind_component(cond_ind) + 1;
                    component{cond_ind,ind_component(cond_ind)} = eval(objectstat);
                end
            end
 
            % grand average by condition
            % set1.GM: cond level 1, set2.GM: cond level 2
            set1.GM = ft_timelockgrandaverage(cfgGM,component{1,1:ind_component(1)});
            set2.GM = ft_timelockgrandaverage(cfgGM,component{2,1:ind_component(2)});
 
            set1.mean = squeeze(mean(set1.GM.individual,1));
            set1.stdmean = squeeze(std(set1.GM.individual,1)/sqrt(nSubjects));
            set2.mean = squeeze(mean(set2.GM.individual,1));
            set2.stdmean = squeeze(std(set2.GM.individual,1)/sqrt(nSubjects));
 
            % test calculus
            stat_cond1_cond2 = ft_timelockstatistics(cfg,set1.GM,set2.GM);
            disp([roi,' ',cond,' ',other,' ',subject,' mask: ',num2str(sum(stat_cond1_cond2.mask))]);
 
            % figure
            subplot(2,2,nplot);
            nplot = nplot + 1;
 
            set1.legend = def.list.cond{1};
            set2.legend = def.list.cond{2};
            stat_cond1_cond2.title = [roi,' ',group,' ',other];
            stat_cond1_cond2.ylabel = def.value;
            res = ins_temporalClusterPermuTest_graph(set1, set2, stat_cond1_cond2, def, cfg);
        end
    end
    filename = ['./output/f_within_simple_' roi '_' datestr(now, 'yyyymmdd_HHMM') '.fig'];
    disp([' -> saving ' filename]);
    saveas(gcf,filename);
end
 
%%
result = 'END of script ins_temporalClusterPermuTest_within_simple.m';