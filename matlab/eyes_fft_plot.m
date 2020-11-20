clear ;

suj_list                                    = {'pilot01','pilot02','pilot03'};
list_name                                   = {'open.both','closed.both'};

i                                           = 0;

for ns = 1:length(suj_list)
    for ncue = 1:length(list_name)
        
        subjectName                         = suj_list{ns};
        
        ext_name                            = ['cuelock.fft.comb.' list_name{ncue}];
        dir_data                            = ['../data/' subjectName '/tf/'];
        
        fname                               = [dir_data subjectName '_' ext_name '.mat'];
        fprintf('Loading %s\n',fname);
        load(fname);
        
        freq                                = ft_freqdescriptives([],freq_comb);
        
        i                                   = i + 1;
        alldata{i}                          = freq; clear freq;
        
        lim_name                            = [4 6];
        
        alllegend{i}                        = [suj_list{ns} ' ' list_name{ncue}(1:lim_name(ncue))];
        
    end
end

clearvars -except alldata alllegend;

nsuj                                            = 3;

for i = 1:length(alldata)
    
    subplot(2,nsuj*2,i)
    cfg                                         = [];
    cfg.layout                                  = 'CTF275_helmet.mat';
    cfg.ylim                                    = 'zeromax';
    cfg.marker                                  = 'off';
    cfg.comment                                 = 'no';
    cfg.colorbar                                = 'no';
    cfg.colormap                                = brewermap(256, '*RdYlBu');
    cfg.xlim                                    = [9 11];
    ft_topoplotTFR(cfg,alldata{i});
    title(alllegend{i});
    
end

subplot(2,nsuj*2,(i+1):(2*nsuj*2));
hold on

list_col                                        = 'kkrrbb';
list_shape                                      = {'-','--','-','--','-','--'};

for i = 1:length(alldata)
    
    data                                        = nanmean(alldata{i}.powspctrm);
    prop                                        = [list_shape{i} list_col(i)];
    
    plot(alldata{i}.freq,data,prop,'LineWidth',3);
    xlim(alldata{i}.freq([1 end]));
    
end

legend(alllegend);