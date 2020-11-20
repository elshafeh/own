close all;

file_list                           = dir('../data/preproc/*.fixlock.icacomp.mat');
i                                   = 0;

for nf = 1:length(file_list)
    
    subjectName                     = strsplit(file_list(nf).name,'.');
    subjectName                     = subjectName{1};
    i                               = i +1;
    list{i}                         = subjectName;

end

% make a list for experimenter to choose from
[indx,~]                            = listdlg('ListString',list,'ListSize',[200,200]);

subjectName                         = list{indx};

dir_data                            = '../data/preproc/';

% Load components and data
fname                               = [dir_data subjectName '.fixlock.icacomp.mat'];
fprintf('Loading %s\n',fname);
load(fname);

fname                               = [dir_data subjectName '.fixlock.preica.mat'];
fprintf('Loading %s\n',fname);
load(fname);

% Check topography
for n = 14:-1:1
    h_plotICA(comp,n);
end

suspect_components                  = input('continue? : ','s');
suspect_components                  = strsplit(suspect_components,',');

% Plot Suspect Components
cfg                                 = [];
cfg.layout                          = 'CTF275_helmet.mat';
cfg.viewmode                        = 'component';
cfg.colormap                        = brewermap(256, '*RdBu');
ft_databrowser(cfg,comp);

final_components                    = input('enter final components : ','s');
final_components                    = strsplit(final_components,',');

% Remove suspect components
cfg                                 = [];
cfg.component                       = str2double(final_components);
cfg.demean                          = 'no';
data                                = ft_rejectcomponent(cfg,comp,data);clc;

% save data and removed components
fname                               = [dir_data subjectName '.ica.rej.comp.mat'];
fprintf('Saving %s\n',fname);
save(fname,'cfg','-v7.3'); clear cfg;

data                                = rmfield(data,'cfg');
fname                               = [dir_data subjectName '.fixlock.ica.clean.mat'];
fprintf('Saving %s\n',fname);
save(fname,'data','-v7.3');

fprintf('done!\n');