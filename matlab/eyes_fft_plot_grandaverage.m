clear ;

suj_list                                    = {'pilot01','pilot02','pilot03'};
list_name                                   = {'open.both','closed.both'};

i                                           = 0;

for ncue = 1:length(list_name)
    for ns = 1:length(suj_list)
        
        subjectName                         = suj_list{ns};
        
        ext_name                            = ['cuelock.fft.comb.' list_name{ncue}];
        dir_data                            = ['../data/' subjectName '/tf/'];
        
        fname                               = [dir_data subjectName '_' ext_name '.mat'];
        fprintf('Loading %s\n',fname);
        load(fname);
        
        freq                                = ft_freqdescriptives([],freq_comb);
        tmp{ns}                             = freq;
        
    end
    
    i                                       = i +1;
    alldata{i}                              = ft_freqgrandaverage([],tmp{:}); clear tmp;
    lim_name                                = [4 6];
    alllegend{i}                            = [list_name{ncue}(1:lim_name(ncue))];
    
end

clearvars -except alldata alllegend;

nsuj                                            = 1;

for i = 1:length(alldata)
    
    %     subplot(2,nsuj*2,i)
    list_i                                      = [1 3];
    subplot(2,2,list_i(i))
    
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
    
    set(gca,'fontsize', 16);
    
end

% subplot(2,nsuj*2,(i+1):(2*nsuj*2));
subplot(2,2,[2 4]);

hold on

list_col                                        = 'kkrrbb';
list_shape                                      = {'-','--'};

for i = 1:length(alldata)
    
    data                                        = nanmean(alldata{i}.powspctrm);
    prop                                        = [list_shape{i} list_col(i)];
    
    plot(alldata{i}.freq,data,prop,'LineWidth',3);
    xlim(alldata{i}.freq([1 end]));
    grid;
    
end

legend(alllegend);
grid;
set(gca,'fontsize', 16);