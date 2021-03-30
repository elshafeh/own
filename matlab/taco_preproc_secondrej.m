function taco_preproc_secondrej

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
    
    name_ext.output                   	= ['_' ext_lock '_icalean_finalrej.mat'];
    
    chk                                 = dir([dir_data sub name_ext.output]);
    % check if this stip hasn't been done before
    if isempty(chk)
        i                               = i +1;
        list{i}                     	= [sub '_' ext_lock];
    end
end

if isempty(list)
    disp('no ica to be done!')
else
    [indx,~]                         	= listdlg('ListString',list,'ListSize',[200,200]);
    
    namepart                          	= strsplit(list{indx},'_');
    subjectName                       	= namepart{1};
    ext_lock                          	= namepart{2};
    
    name_ext.input                    	= ['_' ext_lock '_icalean.mat'];
    name_ext.output                     = ['_' ext_lock '_icalean_finalrej.mat'];
    
    % Load components and data
    fname                               = [dir_data subjectName name_ext.input];
    fprintf('Loading %s\n',fname);
    load(fname);
    
    cfg                                 = [];
    cfg.method                          = 'summary';
    cfg.metric                          = 'var';
    cfg.megscale                        = 1;
    cfg.alim                            = 1e-12;
    postICA_Rej                         = ft_rejectvisual(cfg,dataPostICA);
    
%     chan_group                          = {'MLC' 'MRC' 'MLP' 'MRP' 'MLT' 'MRT' 'MLF' 'MRF'};
%     
%     for ng = 1:length(chan_group)
%         chan_index{ng}                	 = [];
%     end
%     
%     for n = 1:length(postICA_Rej.label)
%         nme                             = postICA_Rej.label{n}(1:3);
%         flg                             = find(strcmp(nme,chan_group));
%         if ~isempty(flg)
%             chan_index{flg}             = [chan_index{flg};n]; clear nme flg;
%         end
%     end
%     
%     chan_inspect                        = [];
%     
%     for ng = 1:length(chan_group)
%         tmp                             = chan_index{ng};
%         tmp                             = tmp(randperm(length(tmp)));
%         chan_inspect                 	= [chan_inspect;tmp(1:4)];
%     end
    
    cfg                                 = [];
    cfg.viewmode                        = 'butterfly';
    %     cfg.channel                         = postICA_Rej.label(chan_inspect);
    cfg.ylim                            = [-2.7000e-10 2.7000e-10];
    cfg.megscale                        = 1;
    RejCfg                              = ft_databrowser(cfg,postICA_Rej);
    dataPostICA_clean                   = ft_rejectartifact(RejCfg,postICA_Rej);

    fname                               = [dir_data subjectName name_ext.output];
    fprintf('Saving %s\n',fname);
    save(fname,'dataPostICA_clean','-v7.3');
    
    datainfo.index                   	= dataPostICA_clean.trialinfo;
    datainfo.hdr                        = dataPostICA_clean.hdr;
    datainfo.grad                       = dataPostICA_clean.grad;
    
    fname                               = [dir_data subjectName name_ext.output(1:end-4) '_datainfo.mat'];
    fprintf('Saving %s\n',fname);
    save(fname,'datainfo');
    
    index                               = dataPostICA_clean.trialinfo;

    fname                               = [dir_data subjectName name_ext.output(1:end-4) '_trialinfo.mat'];
    fprintf('Saving %s\n',fname);
    save(fname,'index');
    
end