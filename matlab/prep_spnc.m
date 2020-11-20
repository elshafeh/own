clear ; clc ; 

load ../data_fieldtrip/template/template_grid_0.5cm.mat

indx        = h_createIndexfieldtrip(template_grid.pos,'../../fieldtrip-20151124/');

list_roi    = {[79 81 80 82],[43 49 51 53 44 50 52 54]};
list_val    = {-5,5};

source                                      = [];
source.pos                                  = template_grid.pos;
source.dim                                  = template_grid.dim; 
tpower                                      = zeros(length(template_grid.pos),1);

for nroi = 1:length(list_roi)
    for sub_roi = 1:length(list_roi{nroi})
        
        tpower(indx(indx(:,2)==list_roi{nroi}(sub_roi),1)) = list_val{nroi};
        
    end
end

source.pow                                      = tpower ; clear tpower;

for iside = 1:3
    
    lst_side                                    = {'left','right','both'};
    lst_view                                    = [-95 1;95,11;0 24];
    
    z_lim                                       =  7;
    
    cfg                                         =   [];
    cfg.method                                  =   'surface';
    cfg.funparameter                            =   'pow';
    cfg.funcolorlim                             =   [-z_lim z_lim];
    cfg.opacitylim                              =   [-z_lim z_lim];
    cfg.opacitymap                              =   'rampup';
    
    cfg.colorbar                                =   'yes';
    
    cfg.camlight                                =   'no';
    cfg.projthresh                              =   0.2;
    cfg.projmethod                              =   'nearest';
    cfg.surffile                                =   ['surface_white_' lst_side{iside} '.mat'];
    cfg.surfinflated                            =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
    ft_sourceplot(cfg, source);
    view(lst_view(iside,:))
    
    saveas(gcf,['../images/spnc_hesham/paper_summary/audplusocc.' lst_side{iside} '.withColorbar.png']);
    close all;
    
end