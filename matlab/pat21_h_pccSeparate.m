function h_pccSeparate(suj,n_prt,data_in,list_time,time_win,trilili,f_focus,tap)

for t = 1:length(list_time)
    
    lm1             = list_time(t)-trilili;
    lm2             = list_time(t)+time_win+trilili;
    
    cfg             = [];
    cfg.toilim      = [lm1 lm2];
    data            = ft_redefinetrial(cfg, data_in);
    
    cfg               = [];
    cfg.method        = 'mtmfft';
    cfg.output        = 'fourier';
    cfg.keeptrials    = 'yes';
    cfg.foi           = f_focus;
    cfg.tapsmofrq     = tap;
    
    freq              = ft_freqanalysis(cfg,data);
    
    fprintf('\nLoading Leadfield\n');
    load(['../data/headfield/' suj '.pt' num2str(n_prt) '.adjusted.leadfield.5mm.mat']);
    load(['../data/headfield/' suj '.VolGrid.5mm.mat']);
    
    ext_freq            = [num2str(f_focus-tap) 't' num2str(f_focus+tap) 'Hz'];
    
    ext_com         = '.CnD.m800p2000.5t15Hz.NewCommonFilter' ;
    FnameFilterIn   = ['../data/filter/' suj '.pt' num2str(n_prt) ext_com '.mat'];
    
    fprintf('Loading %50s \n\n',FnameFilterIn);
    load(FnameFilterIn);
    
    cfg                     = [];
    cfg.method              = 'pcc';
    cfg.frequency           = freq.freq;
    cfg.grid                = leadfield;
    cfg.headmodel           = vol;
    cfg.keeptrials          = 'yes';
    cfg.pcc.fixedori        = 'yes';
    cfg.pcc.projectnoise    = 'yes';
    cfg.pcc.lambda          = '5%';
    cfg.pcc.keepmom         = 'yes';
    cfg.grid.filter         = com_filter;
    source                  = ft_sourceanalysis(cfg, freq);
    
    mom                     = source.avg.mom ;
    
    mom = cellfun(@(x) abs(x).^2, mom, 'UniformOutput',false);
    iy  = size(source.avg.mom{find(source.inside,1,'first')},2);
    iz  = length(freq.trialinfo);
    
    mom(cellfun(@isempty, mom)) = {nan(1,iy)};
    
    source = cell2mat(mom);
    
    if iy ~= iz
        
        fct = iy/iz ;
        
        for ii = 1:fct
            
            lmSrc1 = ((ii-1) * iz) + 1;
            lmSrc2 = lmSrc1 + iz - 1;
            
            src{ii}   = source(:,lmSrc1:lmSrc2);
            
        end
        
        source = cat(3,src{:});
        source = mean(source,3);
        
        clear src lmSrc1 lmSrc2 fct
        
    end
    
    clear mom ix iy iz
    
    if lm1 < 0
        ext1= 'm';
    else
        ext1='p';
    end
    
    ext_time = [ext1 num2str(round(abs(list_time(t))*1000)) ext1 num2str(round((abs(list_time(t)+time_win))*1000))];
    
    ext_com = '.SingleTrial.NewDpss';
    
    f_name_source = [suj '.pt' num2str(n_prt) '.CnD.' ext_freq '.' ext_time ext_com];
    
    fprintf('\n\nSaving %50s \n\n',f_name_source);
    
    save(['../data/source/' f_name_source '.mat'],'source','-v7.3');
    
end