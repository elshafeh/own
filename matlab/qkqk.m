clear ; clc ; 

load('/Users/heshamelshafei/Dropbox/untitled folder/ADE Main/Decoding/raw/lyonDataset/sub1/sub1.BroadAud.datasetInfo.mat')

for nchan = 1:length(chan_list)
    
    fprintf('%s',['"c' num2str(nchan) '",']);
    
    %     name                        = chan_list{nchan};
    %     name(strfind(name,'_'))     = '';
    %     chan_list{nchan}            = name; % ['aud' num2str(nchan)];
    %
    %     clear name
    
end

% clearvars -except chan_list ;

% save /Users/heshamelshafei/GoogleDrive/NeuroProj/Fieldtripping/scripts_field/tmp_chan_list.mat

