clear;clc;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName          	= suj_list{nsuj};
    
    list_freq             	= {'theta' 'alpha' 'beta'};
    list_win            	=  {'preGab1' 'preCue2' 'preGab2'};
    
    list_bin            	= [1 5];
    name_bin                = {'Bin1' 'Bin5'};
    
    for nfreq = 1:length(list_freq)
        for nwin = 1:length(list_win)
            for nbin = 1:length(list_bin)
                
                fname               = ['P:/3015079.01/data/' subjectName '\erf\' subjectName '.binning.' list_freq{nfreq} '.band.' list_win{nwin} '.window.bin' num2str(list_bin(nbin)) '.gfp.mat'];
                fprintf('loading %s\n',fname);
                load(fname);
                
                alldata{nsuj,nfreq,nwin,nbin}  	= data_gfp; clear data_gfp;
                
            end
        end
    end
end

keep alldata list_* name_bin

nsuj                      	= size(alldata,1);
[design,neighbours]     	= h_create_design_neighbours(nsuj,alldata{1,1},'gfp','t'); clc;


cfg                         = [];
cfg.clusterstatistic        = 'maxsum';cfg.method = 'montecarlo';
cfg.correctm                = 'cluster';cfg.statistic = 'depsamplesT';
cfg.uvar                    = 1;cfg.ivar = 2;
cfg.tail                    = 0;cfg.clustertail  = 0;
cfg.neighbours              = neighbours;
cfg.latency                 = [-0.1 5.5];
cfg.clusteralpha            = 0.05; % !!
cfg.minnbchan               = 0; % !!
cfg.alpha                   = 0.025;

cfg.numrandomization        = 1000;
cfg.design                  = design;
for nfreq = 1:size(alldata,2)
    for nwin = 1:size(alldata,3)
        allstat{nfreq,nwin}              = ft_timelockstatistics(cfg, alldata{:,nfreq,nwin,1}, alldata{:,nfreq,nwin,2});
    end
end

keep alldata allstat list_*

%% - % -

figure;
nrow                        	= 3;
ncol                            = 3;
i                               = 0;
zlimit                          = [0.4 0.8; 0.45 0.6];

for nfreq = 1:size(allstat,1)
    for nwin = 1:size(allstat,2)
        
        stat                    = allstat{nfreq,nwin};
        stat.mask               = stat.prob < 0.05;
        
        for nchan = 1:length(stat.label)
            
            vct              	= stat.prob(nchan,:);
            min_p             	= min(vct);
            
            cfg               	= [];
            cfg.channel      	= nchan;
            cfg.time_limit     	= stat.time([1 end]);
            cfg.color          	= {'-b' '-r'};
            cfg.z_limit        	= [2.5e-14 1e-13];
            cfg.linewidth      	= 10;
            
            i = i+1;
            subplot(nrow,ncol,i);
            h_plotSingleERFstat_selectChannel_nobox(cfg,stat,squeeze(alldata(:,nfreq,nwin,:)));
            
            ylabel({stat.label{nchan}, ['p= ' num2str(round(min_p,3))]})
            
            vline([0 1.5 3 4.5 5.5],'--k');
            xticks([0 1.5 3 4.5 5.5]);
            xticklabels({'Cue1' 'Gab1' 'Cue2' 'Gab2' 'Mean RT'});
            
            %             hline(0.5,'--k');
            
            title([list_freq{nfreq} ' ' list_win{nwin}]);
                        
            set(gca,'FontSize',14,'FontName', 'Calibri','FontWeight','normal');
            
        end
    end
end