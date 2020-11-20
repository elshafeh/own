% RunningExample_TCPTWB.m
% Example of utilization of the function
%    ins_temporalClusterPermuTest_WithinBetween.m
% Bernard Giusiano & Sophie Chen - oct 2015
 

% definition of the experiment
mydef.subject = 'person';
mydef.list.subject = {'01','02','03','04','05','06','07','11',...
    '12','13','14','15','16','17','18','19'};
mydef.group = 'group';
mydef.list.group = {'subject','subject','subject','subject','subject','subject','subject','subject',...
    'control','control','control','control','control','control','control','control'};
mydef.cond = 'condition';
mydef.list.cond =  {'condition_A','condition_B'};
mydef.roi = 'roi';
% mydef.list.roi = {'roi_1','roi_2','roi_3','roi_4','roi_5','roi_6','roi_7'};
mydef.list.roi = {'roi_1','roi_5','roi_6','roi_7'}; % select 4 roi only
mydef.other = 'side';
% mydef.list.other = {'L','R'};
mydef.list.other = {'L'};                           % select left side only
mydef.time = 'time';
mydef.value = 'avgabs';
 
mydef.stats = {...  % select statistical calculations to be made (true) or not (false):
    true,...    % Interaction between groups and conditions
    false,...    % Main effect of conditions (within)
    true,...    % Main effect of groups (between)
    true,...    % Simple effect of conditions by group
    false,...    % Simple effect of groups by condition
    };
 
% global parameters
% for other parameters values cf. http://www.fieldtriptoolbox.org/tutorial/cluster_permutation_timelock
cfg                     = [];
cfg.latency             = [-0.3 0.9]; 
cfg.numrandomization    = 10000;
cfg.clusteralpha        = 0.05;  
cfg.tail                = 0;

cfg.clusterstatistic    = 'wcm';  % How to combine the single samples that belong to a cluster test statistic that will be evaluated under the permutation distribution

cfg.wcm_weight = 0.5;      % cf. Hayasaka & Nichols (2004) NeuroImage (page 62)
cfg.clustertail = 0;              % -1, 1 or 0 (default = 0 : two-tail test)
cfg.correcttail = 'alpha';        
cfg.alpha = 0.05;  % 0.05/10;     % alpha level of the permutation test / 10 tests

% ATTENTION:
% alpha SHOULD BE CORRECTED based on the number of tests
% example of correction for 7 roi, 2 groups, 2 conditions, 2 sides:
%   - interactions: 7 roi * 2 sides = 14 tests
%   - main effects: 2 factors (groups and conditions) * 7 roi * 2 sides = 28 tests
%   - simple effects: 2 groups * 2 cond * 7 roi * 2 sides = 56 tests
% => 14 + 28 + 56 = 98 tests => Bonferroni's correction: 0.05/98 = 0.0005
% => cfg.alpha = 0.0005;  for a global alpha threshold really equal to 0.05
 
cfg.neighbours  = {};
 
resultat = ins_temporalClusterPermuTest_WithinBetween(mydata, mydef, cfg, structurePorteuseDataMEG);