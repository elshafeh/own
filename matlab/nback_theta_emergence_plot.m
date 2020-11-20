clear ;

suj_list                                = [1:33 35:36 38:44 46:51];

for nsuj =1:length(suj_list)
    for ncond = 1:2
        
        dirdata                         = 'J:/temp/nback/data/theta/';
        if ncond == 1
            fname                       = [dirdata 'sub' num2str(suj_list(nsuj)) '.combinedplanar.itc.mat'];
        else
            fname                   	= [dirdata 'sub' num2str(suj_list(nsuj)) '.combinedplanar.minevoked.itc.mat'];
        end
        
        fprintf('loading %s\n',fname);
        load(fname);
        
        freq                            = phase_lock;
        freq                            = rmfield(freq,'rayleigh');
        freq                            = rmfield(freq,'p');
        freq                            = rmfield(freq,'sig');
        freq                            = rmfield(freq,'mask');
        
        alldata{nsuj,ncond}           	= freq; clear freq;
        
    end
    
    alldata{nsuj,3}                     = alldata{nsuj,1};
    alldata{nsuj,3}.powspctrm         	= alldata{nsuj,1}.powspctrm - alldata{nsuj,2}.powspctrm;
    
    
end

keep alldata

nrow    = 3;
ncol    = 3;
i       = 0;

for ncond = 1:size(alldata,2)
    
    cfg                                 = [];
    cfg.layout                          = 'neuromag306cmb.lay';
    cfg.comment                         = 'no';
    cfg.marker                          = 'off';
    cfg.zlim                            = 'zeromax';
    cfg.colormap                        = brewermap(256, '*RdBu'); % PuBuGn % *RdYlBu
    i =i+ 1;
    subplot(nrow,ncol,i)
    ft_topoplotER(cfg,ft_freqgrandaverage([],alldata{:,ncond}));
    
    cfg                                 = [];
    cfg.channel                         = {'MEG1912+1913', 'MEG1922+1923','MEG2032+2033', 'MEG2042+2043', 'MEG2112+2113', 'MEG2342+2343'};
    data                                = ft_selectdata(cfg,ft_freqgrandaverage([],alldata{:,ncond}));
    
    cfg                                 = [];
    cfg.comment                         = 'no';
    cfg.marker                          = 'off';
    cfg.zlim                            = 'zeromax';
    cfg.layout                          = 'neuromag306cmb.lay';
    i =i+ 1;
    subplot(nrow,ncol,i)
    ft_singleplotTFR(cfg,data); title('');
    
    i =i+ 1;
    subplot(nrow,ncol,i)
    tmp                                 = squeeze(nanmean(squeeze(nanmean(data.powspctrm,1)),2));
    plot(data.freq,tmp,'-r','LineWidth',2);xlim(data.freq([1 end]));
    grid on;
end