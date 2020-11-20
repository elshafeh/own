clear ; dleiftrip_addpath ; close all;

ext_stat = 'Lcmv.CnD.m150m50.p500p1100.tresolved';
load(['../data/yctot/stat/' ext_stat  '.mat']);

t_lim = 0; z_lim = 5;

for iside = 1:2;
    
    % [-2000 200 -80] [1100 80 60] [0 -200 0]
    
    lst_title               = [-2000 200 -80;1100 80 60;0 -200 0];
    lst_side                = {'left','right','both'};
    lst_view                = [-95 1;95,11;0 50];
    
    vidObj = VideoWriter(['../movies/' ext_stat '.' lst_side{iside} 'hemi'],'MPEG-4');
    vidObj.FrameRate = 1;
    vidObj.Quality = 100;
    open(vidObj);
    
    stat.mask = stat.prob < 0.1;
    
    for ntime           = [1:length(stat.time) length(stat.time) length(stat.time)]
        
        clear source ;
        source.pos              = stat.pos ;
        source.dim              = stat.dim ;
        tpower                  = stat.stat .* stat.mask;
        
        source.pow              = squeeze(tpower(:,ntime)) ; clear tpower;
        
        cfg                     =   [];
        cfg.method              =   'surface';
        cfg.funparameter        =   'pow';
        cfg.funcolorlim         =   [-z_lim z_lim];cfg.opacitylim          =   [-z_lim z_lim];
        cfg.opacitymap          =   'rampup';cfg.colorbar            =   'off';
        cfg.camlight            =   'no';
        cfg.projthresh          =   0.2;
        cfg.projmethod          =   'nearest';
        cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat']; cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
        ft_sourceplot(cfg, source);
        
        view(lst_view(iside,1),lst_view(iside,2))
        title([num2str(stat.time(ntime)*1000) ' ms to ' num2str(stat.time(ntime)*1000 + 100) ' ms']);
        
        set(get(gca,'title'),'Position',lst_title(iside,:))
        
        %     currFrame = getframe(gcf,[90 90 400 300]);
        currFrame = getframe(gcf);
        writeVideo(vidObj,currFrame);
        h = gcf;
        close(h);
        clear source
    end
    
    close(vidObj);close all;
    
end