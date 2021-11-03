clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                        = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    subjectname                 = ['sub' num2str(suj_list(nsuj))];
    
    dir_data                    = '~/Dropbox/project_me/data/nback/virt/';
    fname                       = [dir_data 'sub' num2str(suj_list(nsuj)) '.wallis.roi.mat'];
    fprintf('\n Loading %s\n',fname);
    load(fname);
    
    % - - averaging
    avg                         = ft_timelockanalysis([],data);
    
    % - - baseline correction
    t1                          = nearest(avg.time,-0.1);
    t2                          = nearest(avg.time,0);
    
    bsl                         = mean(avg.avg(:,t1:t2),2);
    avg.avg                     = avg.avg - bsl ; clear bsl t1 t2;
    
    alldata{nsuj,1}             = avg; clear avg_comb; clc;
    
end

keep alldata

%%

for nchan = 1:length(alldata{1}.label)
    
    cfg                      	= [];
    cfg.label                   = alldata{1}.label(nchan);
    cfg.xlim                 	= [-0.1 0.6];
    cfg.color               	= 'k';
    cfg.plot_single           	= 'no';
    
    subplot(6,4,nchan);
    h_plot_erf(cfg,alldata);
    
    
    ylim([-3e-3 3e-3]);
    %     yticks([-0.035 0 0.035]);
    
    vline(0,'-k');
    hline(0,'-k');
    
    title(alldata{1}.label{nchan});
    
    set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
    
end