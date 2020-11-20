function bil_preproc_ica_clean

% inspection and removal of ICA components

% check all -raw files
if ispc
    start_dir = 'P:/';
else
    start_dir = '/project/';
end

close all;

file_list                           = dir([start_dir '3015079.01/data/sub*/preproc/*_firstCueLock_ICAcomp.mat']);
i                                   = 0;

for nf = 1:length(file_list)
    sub                             = file_list(nf).name(1:6);
    chk                             = dir([start_dir '3015079.01/data/' sub '/preproc/*_firstCueLock_ICAlean.mat']);
    % check if this stip hasn't been done before
    if isempty(chk)
        i                           = i +1;
        list{i}                     = sub;
    end
end

% make a list for experimenter to choose from
[indx,~]                            = listdlg('ListString',list,'ListSize',[200,200]);

subjectName                         = list{indx};

dir_data                            = [start_dir '3015079.01/data/' subjectName '/preproc/'];

% Load components and data
fname                               = [dir_data subjectName '_firstCueLock_ICAcomp.mat'];
fprintf('Loading %s\n',fname);
load(fname);

fname                               = [dir_data subjectName '_firstCueLock_preICA.mat'];
fprintf('Loading %s\n',fname);
load(fname);

% Check topography
for n = 14:-1:1
    h_plotICA(comp,n);
end

suspect_components                  = input('enter suspect components : ','s');
suspect_components                  = strsplit(suspect_components,',');

% Plot Suspect Components
cfg                                 = [];
cfg.layout                          = 'CTF275_helmet.mat';
cfg.viewmode                        = 'component';
cfg.colormap                        = brewermap(256, '*RdYlBu');
ft_databrowser(cfg,comp);

final_components                    = input('enter final components : ','s');
final_components                    = strsplit(final_components,',');

% Remove suspect components
cfg                                 = [];
cfg.component                       = str2double(final_components);
cfg.demean                          = 'no';
dataPostICA                         = ft_rejectcomponent(cfg,comp,SecondRej);clc;

% save data and removed components
fname                               = [dir_data subjectName '_ica_rej_comp.mat'];
fprintf('Saving %s\n',fname);
save(fname,'cfg','-v7.3'); clear cfg;

dataPostICA                         = rmfield(dataPostICA,'cfg');
fname                               = [dir_data subjectName '_firstCueLock_ICAlean.mat'];
fprintf('Saving %s\n',fname);
save(fname,'dataPostICA','-v7.3');

fprintf('done!\n');