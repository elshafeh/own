clear;

suj_list                            = [1:4 8:17] ;
data_list                          	= {'meg','eeg'};

for nsuj = 1:length(suj_list)
    
    suj                          	= ['yc' num2str(suj_list(nsuj))] ;
    
    for ndata = 1:2
        
        if nsuj == 1 && ndata == 1
            
            fname_in                = ['../data/tf/' suj '.all.CnD.brain.slct.lp.' data_list{ndata} '.1t30Hz.1HzStep.KeepTrials.mat'];
            fprintf('\nLoading %50s\n',fname_in);
            load(fname_in);
            
            chan_list               = freq.label;
            
        end
        
        % m1000m0ms p200p1200ms p1200p2200ms
        
        %         fname_in                    =  ['../data/peaks/' suj '.all.CnD.brain.slct.lp.' data_list{ndata} '.m1000m0ms.alpha.peak.mat'];
        %         fprintf('Loading %50s\n',fname_in);
        %         load(fname_in);
        %         bsl                         = allpeaks;
        
        fname_in                    =  ['../data/peaks/' suj '.all.CnD.brain.slct.lp.' data_list{ndata} '.p1200p2200ms.alpha.peak.mat'];
        fprintf('Loading %50s\n',fname_in);
        load(fname_in);
        act                         = allpeaks;
        
        allpeaks                    = act;%(act-bsl) ./ bsl;
        
        avg                         = [];
        avg.time                    = 1;
        avg.avg                     = allpeaks(:,1);
        
        avg.label                   = chan_list;
        
        list_unique                 = h_grouplabel(avg,'yes');
        new_avg                     = h_transform_avg(avg,list_unique(:,2),list_unique(:,1));
        
        alldata{nsuj,ndata}         = new_avg; clear avg allpeaks;
        mtrx_data(nsuj,ndata,:)   	= alldata{nsuj,ndata}.avg;
        
    end
end

keep alldata mtrx_data data_list;

nbsuj                           	= size(alldata,1);
[design,neighbours]                 = h_create_design_neighbours(nbsuj,alldata{1,1},'gfp','t');

cfg                                 = [];
cfg.statistic                       = 'ft_statfun_depsamplesT';
cfg.method                          = 'montecarlo';
cfg.correctm                        = 'fdr';
cfg.minnbchan                       = 0;
cfg.tail                            = 0;
cfg.alpha                           = 0.025;
cfg.numrandomization                = 1000;
cfg.uvar                            = 1;
cfg.ivar                            = 2;
cfg.design                          = design;

stat                                = ft_timelockstatistics(cfg, alldata{:,1}, alldata{:,2});

sort_stat                           = [[1:length(stat.label)]' stat.stat];
sort_stat                           = sortrows(sort_stat,2);
sort_stat                           = sort_stat(:,1);

stat.prob                           = stat.prob(sort_stat);
stat.stat                           = stat.stat(sort_stat);
stat.mask                           = stat.mask(sort_stat);
stat.label                      	= stat.label(sort_stat);

plimit                              = 0.05;
nb_plots                            = length(stat.prob(stat.prob < plimit));
nrow                                = 5;
ncol                                = 5;

i                                   = 0;

for nchan = 1:length(stat.label)
    if stat.prob(nchan) < plimit
        
        i                           = i +1;
        subplot(nrow,ncol,i);
        
        hold on;
        boxplot(squeeze(mtrx_data(:,:,nchan)));
        scatter(repmat(1,14,1),squeeze(mtrx_data(:,1,nchan)));
        scatter(repmat(2,14,1),squeeze(mtrx_data(:,2,nchan)));
        
        tmp=strsplit(stat.label{nchan},',');tmp=tmp{1};
        tmp                         = stat.label{nchan};
        
        if stat.stat(nchan) < 0
            title([tmp ' -ve']);
        else
            title([tmp ' +ve']);
        end
        
        ylim([6 15]);%ylim([-0.5 0.5]);
        xticklabels(data_list);
        
    end
end