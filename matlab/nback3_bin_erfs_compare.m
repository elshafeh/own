clear ; close all; clc; global ft_default
ft_default.spmversion = 'spm12';

suj_list                                            = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    subjectname                                     = ['sub' num2str(suj_list(nsuj))];
    
    %     list_back                                       = {'*'};
    %     list_back                                       = {'1back.*','2back.*','*.first','*.target'};
    %     list_back                                       = {'1back.first','2back.first','1back.target','2back.target'};
    
    list_back                                       = {''};
    list_limit                                      = 0.5;
    
    list_band                                       = {'slow' 'alpha' 'beta' 'gamma1' 'gamma2'};
   
    for nback = 1:length(list_back)
        for nband = 1:length(list_band)
            for nbin = [1 2]
                
                %                 flist                               = dir(['/Volumes/heshamshung/nback/erf/' subjectname ...
                %                     '.' list_back{nback} '.' list_band{nband} '.b' num2str(nbin) '.sess*.erfComb.mat']);
                
                flist                               = dir(['/Volumes/heshamshung/nback/erf/' subjectname ...
                    '.' list_band{nband} '.b' num2str(nbin) '.concat.erf.mat']);
                
                for nf = 1:length(flist)
                    
                    fname                           = [flist(nf).folder filesep flist(nf).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    
                    if nf == 1
                        avg_temp                    = avg_comb;
                        avg_temp.avg                = [];
                    end
                    
                    t1                              = nearest(avg_comb.time,-0.1);
                    t2                              = nearest(avg_comb.time,0);
                    bsl                             = mean(avg_comb.avg(:,t1:t2),2);
                    avg_comb.avg                    = avg_comb.avg - bsl ; clear bsl t1 t2;
                    
                    avg_temp.avg(nf,:,:)         	= avg_comb.avg;
                    
                end
                
                avg_temp.avg                        = squeeze(mean(avg_temp.avg,1));
                alldata{nsuj,nback,nband,nbin}      = avg_temp;
                
                clear avg_temp ; clc;
                
            end
        end
    end
end

%%

keep alldata list_*

nbsuj                                               = size(alldata,1);
[design,neighbours]                                 = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');

for nback = 1:size(alldata,2)
    for nband = 1:size(alldata,3)     
        
        cfg                                         = [];
        cfg.latency                                 = [-0.01 list_limit(nback)];
        cfg.statistic                               = 'ft_statfun_depsamplesT';
        cfg.method                                  = 'montecarlo';
        cfg.correctm                                = 'cluster';
        cfg.clusteralpha                            = 0.05;
        cfg.clusterstatistic                        = 'maxsum';
        cfg.minnbchan                               = 3;
   
        cfg.tail                                    = 0;
        cfg.clustertail                             = 0;
        cfg.alpha                                   = 0.025;
        cfg.numrandomization                        = 1000;
        cfg.uvar                                    = 1;
        cfg.ivar                                    = 2;
        cfg.neighbours                              = neighbours;
        cfg.design                                  = design;
        stat{nback,nband}                           = ft_timelockstatistics(cfg,alldata{:,nback,nband,1},alldata{:,nback,nband,2});
        [min_p(nback,nband),p_val{nback,nband}]  	= h_pValSort(stat{nback,nband});clc;
        
    end
end

disp('done testing');
keep alldata list_* stat min_p p_val

%%

close all;

for nback = 1:size(stat,1)
    for nband = 1:size(stat,2)
        
        plimit                                      = 0.13;
        
        if min_p(nback,nband) < plimit
            
            
            cfg                                     = [];
            cfg.layout                              = 'neuromag306cmb.lay';
            cfg.zlim                                = [-3 3];
            cfg.ylim                                = [-0.5e-12 3.5e-12];
            cfg.colormap                            = brewermap(256,'*RdBu');
            cfg.plimit                              = plimit;
            cfg.vline                               = 0;
            cfg.sign                                = [-1 1];
            cfg.maskstyle                           = 'highlight'; %'nan';
            cfg.title                               = [list_back{nback} ' ' list_band{nband}];
            cfg.list_color                          = 'gr';
            [FigH]                                  = h_plotstat_2d(cfg,stat{nback,nband},squeeze(alldata(:,nback,nband,:)));
            
            saveas(FigH, ['~/Dropbox/project_me/presentations/nback_2021/_prep/erf bin concat ' list_band{nband} '.png']);
            close all;
            
        end
    end
end