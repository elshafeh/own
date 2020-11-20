clear ; clc;
close all;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = length(suj_list):-1:1
    
    ext_virt                = 'wallis';
    
    subjectName             = suj_list{nsuj};
<<<<<<< HEAD
    subject_folder          = '~/Dropbox/project_me/data/bil/virt/';
=======
    subject_folder          = ['/project/3015079.01/data/' subjectName '/virt/'];
>>>>>>> 6211a5cbdd8bc6cb3252a3dbb9d6cd4b5cb80fa8
    fname                   = [subject_folder subjectName '.virtualelectrode.' ext_virt '.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
<<<<<<< HEAD
    %  correct trials [keep that in mind for later
=======
<<<<<<< HEAD
    % choose correct trials [keep that in mind for later]
    cfg                 	= [];
    cfg.trials           	= find(data.trialinfo(:,16) == 1);
    data                    = ft_selectdata(cfg,data);

=======
    %  correct trials [keep that in mind for later]
>>>>>>> abb1f436e3a9e25766448ae791a2c331cbbe9b86
    cfg                     = [];
    cfg.trials          	= find(data.trialinfo(:,16) == 1); 
    data                    = ft_selectdata(cfg,data); 
>>>>>>> 6211a5cbdd8bc6cb3252a3dbb9d6cd4b5cb80fa8
    
    time_win1               = -0.1;
    time_win2               = 6.5;
    
    cfg                  	= [];
    cfg.output           	= 'fourier';
    cfg.method            	= 'mtmconvol';
    cfg.taper            	= 'hanning';
    cfg.foi              	= 1:1:10;
    cfg.toi              	= time_win1:0.05:time_win2;
<<<<<<< HEAD
    cfg.t_ftimwin        	= ones(length(cfg.foi),1).*0.5;   % 5 cycles
=======
    cfg.t_ftimwin        	= ones(length(cfg.foi),1).*0.5;   % 5 cycles    
>>>>>>> 6211a5cbdd8bc6cb3252a3dbb9d6cd4b5cb80fa8
    cfg.keeptrials       	= 'yes';
    cfg.pad             	= 10;
    freq                    = ft_freqanalysis(cfg,data);
    phase_lock          	= bil_itc_sortRT_compute(freq,5);
    
<<<<<<< HEAD
    fname               	= ['~/Dropbox/project_me/data/bil/virt/' subjectName '.' ext_virt '.cuelock.itc.5binned.mat'];
=======
    fname               	= [subject_folder subjectName '.' ext_virt '.cuelock.itc.5binned.mat'];
>>>>>>> 6211a5cbdd8bc6cb3252a3dbb9d6cd4b5cb80fa8
    fprintf('\nSaving %s\n',fname);
    tic;save(fname,'phase_lock','-v7.3');toc;
    
    index                   = [];
    
    % for PAC 
    for nbin = 1:length(phase_lock)
        index               = [index phase_lock{nbin}.index];
    end
    
<<<<<<< HEAD
    fname               	= ['~/Dropbox/project_me/data/bil/virt/' subjectName '.' ext_virt '.cuelock.itc.5binned.trialinfo.mat'];
    fprintf('\nSaving %s\n',fname);
    tic;save(fname,'index');toc;

=======
    fname               	= [subject_folder subjectName '.' ext_virt '.cuelock.itc.5binned.trialinfo.mat'];
    fprintf('\nSaving %s\n',fname);
    tic;save(fname,'index');toc;
    
<<<<<<< HEAD
    keep nsuj suj_list
=======
>>>>>>> 6211a5cbdd8bc6cb3252a3dbb9d6cd4b5cb80fa8
    clear freq phase_lock fname
>>>>>>> abb1f436e3a9e25766448ae791a2c331cbbe9b86
    
end