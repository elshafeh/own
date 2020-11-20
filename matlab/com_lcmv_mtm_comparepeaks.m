clear;

suj_list                            = [1:4 8:17] ;
data_list                          	= {'meg','eeg'};

for nsuj = 1:length(suj_list)
    
    suj                          	= ['yc' num2str(suj_list(nsuj))] ;
    
    for ndata = 1:2
        
        % m1000m0ms or p200p1200ms
        fname_in                    = ['../data/tf/' suj '.CnD.brainnetome.' data_list{ndata} '.m1000m0ms.alphapeak.mat'];
        fprintf('Loading %50s\n',fname_in);
        load(fname_in);
        
        mtrx                      	= allpeaks(:,2);
        source                      = h_towholebrain(mtrx,'../data/template/com_btomeroi.mat','../data/template/template_grid_5mm.mat');
        alldata{nsuj,ndata}         = source; clear source mtrx avg data allpeaks;
        
    end
end

keep alldata data_list

cfg                                 =   [];
cfg.dim                             =   alldata{1}.dim;
cfg.method                          =   'montecarlo';
cfg.statistic                       =   'depsamplesT';
cfg.parameter                       =   'pow';
cfg.correctm                        =   'cluster';
cfg.clusteralpha                    =   0.0001;  % First Threshold
cfg.clusterstatistic                =   'maxsum';
cfg.numrandomization                =   1000;
cfg.alpha                           =   0.025;
cfg.tail                            =   0;
cfg.clustertail                     =   0;

nsuj                                =   size(alldata,1);
cfg.design(1,:)                     =   [1:nsuj 1:nsuj];
cfg.design(2,:)                     =   [ones(1,nsuj) ones(1,nsuj)*2];
cfg.uvar                            =   1;
cfg.ivar                            =   2;
stat                                =   ft_sourcestatistics(cfg, alldata{:,1},alldata{:,2});

z_lim                               = 5;

clear source ;

[min_p,p_val]                       = h_pValSort(stat);

stolplot                            = stat;
stolplot.mask                       = stolplot.prob < 0.05;

source.pos                          = stolplot.pos ;
source.dim                          = stolplot.dim ;
tpower                              = stolplot.stat .* stolplot.mask;
tpower(tpower == 0)                 = NaN;
source.pow                          = tpower ; clear tpower;

cfg                                 = [];
cfg.method                          = 'surface';
cfg.funparameter                    = 'pow';
cfg.funcolorlim                     = [-z_lim z_lim];
cfg.opacitylim                      = [-z_lim z_lim];
cfg.opacitymap                      = 'rampup';
cfg.colorbar                        = 'off';
cfg.camlight                        = 'no';
cfg.projmethod                      = 'nearest';
cfg.surffile                        = 'surface_white_both.mat';
cfg.surfinflated                    =  'surface_inflated_both_caret.mat';
ft_sourceplot(cfg, source);