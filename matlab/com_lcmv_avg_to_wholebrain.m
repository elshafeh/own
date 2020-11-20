clear;

suj_list                                                = [1:4 8:17] ;
data_list                                               = {'meg','eeg'};

for nsuj = 1:length(suj_list)
    
    suj                                                 = ['yc' num2str(suj_list(nsuj))] ;
    
    for ndata = 1:2
        
        fname_in                                        = ['../data/lcmv_brain/' suj '.CnD.brainnetome.' data_list{ndata} '.mat'];
        fprintf('\nLoading %50s\n',fname_in);
        load(fname_in);
        
        avg                                             = ft_timelockanalysis([],data);
        avg.avg                                         = abs(avg.avg);
        
        ix1                                             = find(round(avg.time,2) == -0.1);
        ix2                                             = find(round(avg.time,2) == 0);
        
        pow                                             = avg.avg;
        bsl                                             = mean(avg.avg(:,ix1:ix2),2);
        
        avg.avg                                         = (pow - bsl) ./ bsl;

        %         ix1                                             = find(round(avg.time,2) == 0.11);
        %         ix2                                             = find(round(avg.time,2) == 0.41);
        
        ix1                                             = find(round(avg.time,2) == 1.2);
        ix2                                             = find(round(avg.time,2) == 1.3);
        
        mtrx                                            = mean(avg.avg(:,ix1:ix2),2);
       
        source                                          = h_towholebrain(mtrx,'../data/template/com_btomeroi.mat','../data/template/template_grid_5mm.mat');
        
        alldata{nsuj,ndata}                             = source; clear source mtrx avg data;
        
    end
end

keep alldata data_list

for ndata = 1:2
    gavg{ndata}                                         = ft_sourcegrandaverage([],alldata{:,ndata});
end

cfg                                                     =   [];
cfg.method                                              =   'surface';
cfg.funparameter                                        =   'pow';
cfg.funcolorlim                                         =   [-5 5];
cfg.opacitylim                                          =   [-5 5];
cfg.opacitymap                                          =   'rampup';
cfg.colorbar                                            =   'off';
cfg.camlight                                            =   'no';
cfg.projmethod                                          =   'nearest';
cfg.surffile                                            =   'surface_white_both.mat';
cfg.surfinflated                                        =   'surface_inflated_both_caret.mat';
% cfg.projthresh                                          = 0.55;

for ndata = 1:2
    ft_sourceplot(cfg, gavg{ndata});
    title(data_list{ndata});
end

