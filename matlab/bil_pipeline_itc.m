clear ; close all;

if isunix
    project_dir = '/project/3015079.01/';
else
    project_dir = 'P:/3015079.01/';
end

suj_list                                                = dir([project_dir 'data/sub*/preproc/*finalrej.mat']);

for ns = 1:length(suj_list)
    
    subjectName                                         = suj_list(ns).name(1:6);
    chk                                                 = [];%dir([project_dir 'data/' subjectName '/tf/' subjectName '.cuelock.itc.comb.5binned.allchan.mat']);
    
    if isempty(chk)
        
        fname                                           = [suj_list(ns).folder '/' suj_list(ns).name];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        data_axial                                      = dataPostICA_clean; clear dataPostICA_clean;
        
        % -- remove evoked response
        %         data_axial                                      = h_removeEvoked(data_axial);
        
        % -- remove head-movements- confounds
        fname                                           = [project_dir 'data/' subjectName '/preproc/' subjectName '.firstcue.hcData.300Fs.mat'];
        if exist(fname)
            fprintf('loading %s\n',fname);
            load(fname);
        else
            headpos                                     =  bil_preproc_hc_cuelock(subjectName);
        end
        
        data_planar                                     = h_ax2plan(data_axial);
        
        index_cnd{1}                                    = 1:length(data_axial.trialinfo);
        list_cnd                                        = {'alltrials'};
        
        for nc = 1:length(list_cnd)
            
            time_win1                                   = -0.1;
            time_win2                                   = 6.5;
            
            cfg                                         = [];
            cfg.output                                  = 'fourier';
            cfg.method                                  = 'mtmconvol';
            cfg.taper                                   = 'hanning';
            cfg.foi                                     = 1:1:10;
            cfg.toi                                     = time_win1:0.05:time_win2;
            cfg.t_ftimwin                               = ones(length(cfg.foi),1).*0.5;   % 5 cycles
            
            % -- !!!
            % choose correct trials [keep that in mind for later]
            cfg.trials                              	= find(data_planar.trialinfo(:,16) == 1);
            % -- !!!
            
            cfg.keeptrials                              = 'yes';
            cfg.pad                                     = 10;
            
            freq_planar                                 = ft_freqanalysis(cfg,data_planar);
            
            cfg                                         = []; cfg.method = 'svd';
            freq_comb                                   = ft_combineplanar(cfg,freq_planar);
            freq_comb                                   = rmfield(freq_comb,'cfg');
            
            phase_lock                                  = bil_itc_sortRT_compute_percond(subjectName,freq_comb,5,'withevoked');
            clear phase_lock freq_comb;
            
        end
    end
end

% bil_itc_sortRT_contrast_WholeSens;

% fname                                       = [project_dir 'data/' subjectName '/tf/' subjectName '.cuelock.fourier.' list_cnd{nc} '.comb.mat'];
% fprintf('Saving %s\n',fname);
% tic;save(fname,'freq_comb','-v7.3');toc;
% cfg                                         = [];
% cfg.indexchan                               = 'all';
% cfg.index                                   = 'all';
% cfg.alpha                                   = 0.05;
% cfg.time                                    = [-0.1 6.5];
% cfg.freq                                    = [1 10];
% phase_lock                                  = mbon_PhaseLockingFactor(freq_comb, cfg);
% fname                                       = [project_dir 'data/' subjectName '/tf/' subjectName '.cuelock.itc.comb.alltrials.allchan.minevoked.mat'];
% fprintf('\nSaving %s\n',fname);
% tic;save(fname,'phase_lock','-v7.3');toc; clear phase_lock
%
% phase_lock                                  = bil_itc_sortRT_compute(subjectName,freq_comb,5,'withevoked');