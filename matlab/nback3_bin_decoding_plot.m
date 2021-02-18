clear;

clear ; close all; global ft_default
ft_default.spmversion = 'spm12';

suj_list                                    = [1:33 35:36 38:44 46:51]; % 

for nsuj = 1:length(suj_list)
    
    subjectname                             = ['sub' num2str(suj_list(nsuj))];
    dir_data                                = '/Users/heshamelshafei/Dropbox/project_me/data/nback/bin_decode/auc/';
    
    list_band                               = {'slow' 'alpha' 'beta' 'gamma1' 'gamma2'}; %{'broadband'}; %
    list_deco                               = {'condition' 'first' 'target'  'stim*'}; %
    list_bin                                = {'b1' 'b2'};
    
    for ndeco = 1:length(list_deco)
        for nband = 1:length(list_band)
            for nbin = 1:length(list_bin)
                
                flist                       = dir([dir_data subjectname '.' list_band{nband} '.decoding.' ...
                    list_deco{ndeco} '.' list_bin{nbin} '.4fold.nodemean.auc.mat']);
                
                if isempty(flist)
                    flist                	= dir([dir_data subjectname '.' list_band{nband} '.decoding.' ...
                        list_deco{ndeco} '.' list_bin{nbin} '.3fold.nodemean.auc.mat']);
                end
                
                if isempty(flist)
                    flist                	= dir([dir_data subjectname '.' list_band{nband} '.decoding.' ...
                        list_deco{ndeco} '.' list_bin{nbin} '.*fold.nodemean.auc.mat']);
                end
                
                if isempty(flist)
                    flist                   = [];
                end
                
                mtrx_data                   = [];
                
                for nf = 1:length(flist)
                    fname                   = [flist(nf).folder filesep flist(nf).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    mtrx_data(nf,:)         = scores; clear scores fname;
                end
                
                avg                         = [];
                avg.label                   = {'auc'};
                avg.time                    = time_axis;
                avg.avg                     = mean(mtrx_data,1);
                avg.dimord                  = 'chan_time';
                
                alldata{nsuj,ndeco,nband,nbin}  = avg; clear avg;
                
            end
        end
    end
end

keep alldata list_*

%%

nrow                    = length(list_deco);
ncol                    = length(list_band);
i                       = 0;

list_z                  = [0.6 0.6 0.8 0.6];

for ndeco = 1:length(list_deco)
    for nband = 1:length(list_band)
        
        gavg1           = ft_timelockgrandaverage([],alldata{:,ndeco,nband,1});
        
        if length(list_bin) >1
            gavg2     	= ft_timelockgrandaverage([],alldata{:,ndeco,nband,2});
        else
            gavg2       = gavg1;
        end
        
        cfg             = [];
        cfg.xlim        = [-0.5 2];
        %         cfg.ylim        = [0.45 list_z(ndeco)];
        cfg.figure      = 0;
        i               = i +1;
        subplot(nrow,ncol,i);
        ft_singleplotER(cfg,gavg1,gavg2);
        
        title(list_band{nband})
        ylabel(['Decoding ' list_deco{ndeco}]);
        vline(0,'--k');
        hline(0.5,'--k');
        
    end
end