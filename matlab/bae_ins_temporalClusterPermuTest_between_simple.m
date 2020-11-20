% ins_temporalClusterPermuTest_between_simple.m
function result = ins_temporalClusterPermuTest_between_simple(data, def, cfg, structTemplate)
% http://meg.univ-amu.fr/wiki/Main_Page %%%%%%%%%%%%%
%
% Nonparametric MEG data analysis of effects between two groups
% on two levels for each condition. Permutation test based on temporal
% clusters on the data grouped into regions of interest.
%
% DEPENDANCES:
% This function uses the FieldTrip MATLAB software toolbox
% (http://www.fieldtriptoolbox.org/)
%
% USAGE:
% result = ins_temporalClusterPermuTest_between_simple(
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
groupDesc = tabulate(def.list.group);
nGroupLevel1 = groupDesc{1,2};
nGroupLevel2 = groupDesc{2,2};
groupLevels = unique(def.list.group);
 
sizeSamples = size(data(1,1).(def.time));
nSamples = sizeSamples(2);
 
cfgGM = [];
cfgGM.keepindividual = 'yes';
cfgGM.latency = cfg.latency;
 
%% parameters specific to this function
cfg.statistic = 'indepsamplesT';  % independant samples
% cfg.parameter = string          (default = 'trial' or 'avg')
 
% design
design = zeros(1,nGroupLevel1 + nGroupLevel2);
design(1,1:nGroupLevel1) = 1;
design(1,(nGroupLevel1 + 1):(nGroupLevel1 + nGroupLevel2))= 2;
cfg.design = design;             % design matrix
cfg.ivar  = 1;                   % number or list with indices indicating the independent variable(s)
 
%% loop on criteria
for roi_ind = 1:length(def.list.roi)
    roi = char(def.list.roi(roi_ind));
    fig = figure;
    set(fig,'Units','pixels');
    set(fig,'Position',[10 74 1419 740]);
    nplot = 1;
 
    for cond_ind = 1:length(def.list.cond)
        cond = char(def.list.cond(cond_ind));
 
        for other_ind = 1:length(def.list.other)
            other = char(def.list.other(other_ind));
 
            % components of grand average
            component = cell(2,1);  % 2 conditions. 2° dim -> length(def.list.subject) but initialized to 1
            ind_component = zeros(2);
 
            for subject_ind = 1:length(def.list.subject)
                subject = char(def.list.subject(subject_ind));
 
                group = char(def.list.group(subject_ind));
                group_ind = find(ismember(groupDesc(:,1),group));
 
                disp([roi,' ',cond,' ',other,' ',group,' ',subject]);
                object_ind = find(strcmp({data.(def.roi)},roi) & strcmp({data.(def.cond)},cond)...
                    & strcmp({data.(def.other)},other) & strcmp({data.(def.subject)},subject));
 
                objectstat = [group subject];
                eval([objectstat ' = structTemplate;']);
                eval([objectstat '.trial{1,1} = data(' num2str(object_ind) ').(def.value);']);
                eval([objectstat '.time{1,1} = data(' num2str(object_ind) ').(def.time);']);
                eval([objectstat '.fsample = nSamples;']);
                eval([objectstat '.sampleinfo = [1 nSamples];']);
                eval([objectstat '.trialinfo = 1;']);
                ind_component(group_ind) = ind_component(group_ind) + 1;
                component{group_ind,ind_component(group_ind)} = eval(objectstat);
            end
 
            % grand average by group
            % set1.GM: group level 1, set2.GM: group level 2
            set1.GM = ft_timelockgrandaverage(cfgGM,component{1,1:ind_component(1)});
            set2.GM = ft_timelockgrandaverage(cfgGM,component{2,1:ind_component(2)});
 
            set1.mean = squeeze(mean(set1.GM.individual,1));
            set1.stdmean = squeeze(std(set1.GM.individual,1)/sqrt(nGroupLevel1));
            set2.mean = squeeze(mean(set2.GM.individual,1));
            set2.stdmean = squeeze(std(set2.GM.individual,1)/sqrt(nGroupLevel2));
 
            % test calculus
            stat_group1_group2 = ft_timelockstatistics(cfg,set1.GM,set2.GM);
            disp([roi,' ',other,' ',group,' ',subject,' mask: ',num2str(sum(stat_group1_group2.mask))]);
 
            % figure
            subplot(2,2,nplot);
            nplot = nplot + 1;
 
            set1.legend = groupLevels{1};
            set2.legend = groupLevels{2};
            stat_group1_group2.title = [roi,' ',cond,' ',other];
            stat_group1_group2.ylabel = def.value;
            res = ins_temporalClusterPermuTest_graph(set1, set2, stat_group1_group2, def, cfg);
        end
    end
    filename = ['./output/f_between_simple_' roi '_' datestr(now, 'yyyymmdd_HHMM') '.fig'];
    disp([' -> saving ' filename]);
    saveas(gcf,filename);
end
 
%%
result = 'END of script ins_temporalClusterPermuTest_between_simple.m';