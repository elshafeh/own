clear ;

subjectName                     = 'pilot03';
dir_data                        = ['../data/' subjectName '/preproc/'];

% Load components and data
fname                           = [dir_data subjectName '_cueLock_ICAcomp.mat'];
fprintf('Loading %s\n',fname);
load(fname);

fname                           = [dir_data subjectName '_cueLock_preICA.mat'];
fprintf('Loading %s\n',fname);
load(fname);

% Check topography
for n = 4:-1:1
    h_plotICA(comp,n);
end

% Plot Suspect Components
cfg                             = [];
cfg.layout                      = 'CTF275_helmet.mat';
cfg.viewmode                    = 'component';
cfg.colormap                    = brewermap(256, '*RdYlBu');
ft_databrowser(cfg,comp);

% Remove suspect components
cfg                             = [];
cfg.component                   = [1 2 5 16];
cfg.demean                      = 'no';
dataPostICA                     = ft_rejectcomponent(cfg,comp,SecondRej);clc;

fname                           = [dir_data subjectName '_ica_rej_comp.mat'];
fprintf('Saving %s\n',fname);
save(fname,'cfg','-v7.3'); clear cfg;

dataPostICA                     = rmfield(dataPostICA,'cfg');
fname                           = [dir_data subjectName '_cueLock_ICAlean.mat'];
fprintf('Saving %s\n',fname);
save(fname,'dataPostICA','-v7.3');

fprintf('done\n');