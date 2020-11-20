clear;

suj_list                                                = [1:4 8:17] ;
data_list                                               = {'meg','eeg'};

for nsuj = 1:length(suj_list)
    
    suj                                                 = ['yc' num2str(suj_list(nsuj))] ;
    
    for ndata = 1:2
        
        fname_in                                        = ['../data/tf/' suj '.CnD.brainnetome.' data_list{ndata} '.m1000m0ms.alphapeak.mat'];
        fprintf('Loading %50s\n',fname_in);
        load(fname_in);
        
        mtrx                                            = allpeaks(:,1);
        %         mtrx                                            = mtrx ./ mean(mtrx);
        
        
        source                                          = h_towholebrain(mtrx,'../data/template/com_btomeroi.mat','../data/template/template_grid_5mm.mat');
        
        alldata{nsuj,ndata}                             = source; clear source mtrx avg data allpeaks;
        
    end
end

keep alldata data_list

for ndata = 1:2
    gavg{ndata}                                         = ft_sourcegrandaverage([],alldata{:,ndata});
end

cfg                                                     =   [];
cfg.method                                              =   'surface';
cfg.funparameter                                        =   'pow';
cfg.funcolorlim                                         =   [7 15]; % 'maxabs';
cfg.opacitylim                                          =   cfg.funcolorlim;
cfg.opacitymap                                          =   'rampup';
cfg.colorbar                                            =   'yes';
cfg.camlight                                            =   'no';
cfg.projmethod                                          =   'nearest';
cfg.surffile                                            =   'surface_white_both.mat';
cfg.surfinflated                                        =   'surface_inflated_both_caret.mat';
cfg.funcolormap                                         = brewermap(256, '*Spectral');
% cfg.projthresh                                          = 0.55;

for ndata = 1:2
    ft_sourceplot(cfg, gavg{ndata});
    title(data_list{ndata});
end