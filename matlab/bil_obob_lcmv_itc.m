clear ; close all;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                         = suj_list{nsuj};
    fname                               = ['/project/3015039.06/bil/virtual/' subjectName '.obob333.dwn70.mat'];
    fprintf('loading: %s\n',fname);
    load(fname);data                 	= data_virt; clear data_virt;
    
    % choose correct trials [keep that in mind for later]
    cfg                                 = [];
    cfg.trials                       	= find(data.trialinfo(:,16) == 1);
    data                                = ft_selectdata(cfg,data);
    
    alldata{1}                          = data;
    alldata{2}                          = h_removeEvoked(data); clear data;
    
    list_data                           = {'withevoked','minevoked'};
    
    for ndata = 1:length(list_data)
        
        load itc_obob_time_axis.mat
        
        cfg                              	= [];
        cfg.output                       	= 'fourier';
        cfg.method                      	= 'mtmconvol';
        cfg.taper                        	= 'hanning';
        cfg.foi                             = 1:1:10;
        cfg.toi                          	= itc_time_axis;
        cfg.t_ftimwin                   	= ones(length(cfg.foi),1).*0.5;   % 5 cycles
        cfg.keeptrials                  	= 'yes';
        cfg.pad                             = 10;
        freq_comb                           = ft_freqanalysis(cfg,alldata{ndata});
        
        cfg                             	= [];
        cfg.indexchan                    	= 'all';
        cfg.index                           = cfg.indexchan;
        cfg.alpha                        	= 0.05;
        cfg.time                            = freq_comb.time([1 end]);
        cfg.freq                         	= freq_comb.freq([1 end]);
        phase_lock                          = mbon_PhaseLockingFactor(freq_comb, cfg);
        
        fname                             	= ['/project/3015039.06/bil/tf/' subjectName '.obob.itc.correct.' list_data{ndata} '.mat'];
        fprintf('\nSaving %s\n',fname);
        tic;save(fname,'phase_lock','-v7.3');toc; clear phase_lock;
        
        nb_bin                              = 5;
        phase_lock                          = bil_itc_sortRT_compute_virt(freq_comb,nb_bin);
        
        fname                             	= ['/project/3015039.06/bil/tf/' subjectName '.obob.itc.correct.' num2str(nb_bin) 'binned.' list_data{ndata} '.mat'];
        fprintf('\nSaving %s\n',fname);
        tic;save(fname,'phase_lock','-v7.3');toc; clear phase_lock;
        
    end
end