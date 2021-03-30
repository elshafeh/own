function taco_preproc_ica_clean

clc;

if ispc
    start_dir                           = 'D:/Dropbox/project_me/data/taco/';
else
    start_dir                           = '~/Dropbox/project_me/data/taco/';
end

dir_data                                = [start_dir 'preproc/'];

file_list                               = dir([dir_data '*_preica.mat']);
i                                       = 0;
list                                    = {};

for nf = 1:length(file_list)
    
    namepart                        	= strsplit(file_list(nf).name,'_');
    
    sub                                 = namepart{1};
    ext_lock                            = namepart{2};
    
    name_ext.output                   	= ['_' ext_lock '_icalean.mat'];
    
    chk                                 = dir([dir_data sub name_ext.output]);
    % check if this stip hasn't been done before
    if isempty(chk)
        i                               = i +1;
        list{i}                     	= [sub '_' ext_lock];
    end
end

% make a list for experimenter to choose from
if isempty(list)
    disp('no ica to be done!')
else
    [indx,~]                         	= listdlg('ListString',list,'ListSize',[200,200]);
    
    namepart                          	= strsplit(list{indx},'_');
    subjectName                       	= namepart{1};
    ext_lock                          	= namepart{2};
    
    name_ext.input                    	= ['_' ext_lock '_preica.mat'];
    name_ext.ica                      	= ['_' ext_lock '_icacomponents.mat'];
    name_ext.output                     = ['_' ext_lock '_icalean.mat'];
    
    % Load components and data
    fname                               = [dir_data subjectName name_ext.input];
    fprintf('Loading %s\n',fname);
    load(fname);
    
    fname                            	= [dir_data subjectName name_ext.ica];
    fprintf('Loading %s\n',fname);
    load(fname);
    
    % Check topography
    for n = 10:-1:1
        h_plotICA(comp,n);
    end
    
    tmp                                 = input('continue [y/n]: ','s');
    
    % Plot Suspect Components
    cfg                                 = [];
    cfg.layout                          = 'CTF151.lay'; %'CTF275_helmet.mat';
    cfg.viewmode                        = 'component';
    cfg.colormap                        = brewermap(256, '*RdBu');
    ft_databrowser(cfg,comp);
    
    final_components                    = input('enter final components : ','s');
    final_components                    = strsplit(final_components,',');
    
    % Remove suspect components
    cfg                                 = [];
    cfg.component                       = str2double(final_components);
    cfg.demean                          = 'no';
    dataPostICA                         = ft_rejectcomponent(cfg,comp,SecondRej);clc;
    
    % save data and removed components
    fname                               = [dir_data subjectName '_' ext_lock '_ica_rej_comp.mat'];
    fprintf('Saving %s\n',fname);
    save(fname,'cfg','-v7.3'); clear cfg;
    
    dataPostICA                         = rmfield(dataPostICA,'cfg');
    fname                               = [dir_data subjectName name_ext.output];
    fprintf('Saving %s\n',fname);
    save(fname,'dataPostICA','-v7.3');
end