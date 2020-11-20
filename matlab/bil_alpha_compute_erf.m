function  bil_alpha_compute_erf(subjectName)

if isunix
    subject_folder = ['/project/3015079.01/data/' subjectName];
else
    subject_folder = ['P:/3015079.01/data/' subjectName];
end

chk                                     = dir([subject_folder '/erf/*gratinglock.demean.erfComb.mat']);

if isempty(chk)
    
    fname                               = [subject_folder '/preproc/' subjectName '_gratinglock_dwnsample100Hz.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    % do we want to exclude blocks with perfoamces either at chance
    % or celing?
    % i guess here this is irrelevant
    %     data                                = h_excludebehav(data,13,16);
    
    cfg                                 = [];
    cfg.demean                          = 'yes';
    cfg.baselinewindow                  = [-0.1 0];
    cfg.lpfilter                        = 'yes';
    cfg.lpfreq                          = 20;
    
    data                                = ft_preprocessing(cfg,data);
    
    avg                                 = ft_timelockanalysis([], data);
    
    cfg                                 = [];
    cfg.feedback                        = 'yes';
    cfg.method                          = 'template';
    cfg.neighbours                      = ft_prepare_neighbours(cfg, avg); close all;
    
    cfg.planarmethod                    = 'sincos';
    avg_planar                          = ft_megplanar(cfg, avg);
    
    avg_comb                            = ft_combineplanar([],avg_planar);
    
    avg_comb                            = rmfield(avg_comb,'cfg');
    avg                                 = rmfield(avg,'cfg');
    
    dir_data                            = [subject_folder '/erf/'];
    mkdir(dir_data);
    
    ext_name                            = 'gratinglock.demean.erfComb';
    
    clc;
    
    fname                               = [dir_data subjectName '.' ext_name '.mat'];
    fprintf('Saving %s\n',fname);
    save(fname,'avg_comb','-v7.3');
    
    fprintf('\ndone\n\n');

end