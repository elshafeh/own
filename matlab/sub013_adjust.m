clear;

% load ../data/sub013/preproc/sub013_firstCueLock_ICAlean_finalrej_trialinfo.mat
%
% find_ix                         = trialinfo(:,18);
% find_adjust                     = find(find_ix >= 249);
% nw                              = find_ix(find_adjust)-1;
%
% trialinfo(find_adjust,18)       = nw;
%
% keep trialinfo
%
% save ../data/sub013/preproc/sub013_firstCueLock_ICAlean_finalrej_trialinfo.mat

load ../data/sub013/preproc/sub013_firstCueLock_ICAlean_finalrej_trialinfo.mat

load ../data/sub013/preproc/sub013_firstCueLock_ICAlean_finalrej.mat

dataPostICA_clean.trialinfo     = trialinfo;

save('../data/sub013/preproc/sub013_firstCueLock_ICAlean_finalrej.mat','dataPostICA_clean','-v7.3');


