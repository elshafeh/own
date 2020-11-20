clear ; close all;

suj_list 	= [1:33 35:36 38:44 46:51];

run_test    = 1;
ext_fix     = 'target';

for nsuj = 1:length(suj_list)
    
    suj_name                                    = ['sub' num2str(suj_list(nsuj))];
    
    switch run_test
        case 1
            list_lock                           = {'alpha.peak.centered.istarget','beta.peak.centered.istarget'};
        case 2
            list_lock                         	= {['alpha.peak.centered.lockedon.' ext_fix],['beta.peak.centered.lockedon.' ext_fix]};
    end
    
    list_cond                                   = {'0back','1back','2back'};
    
    for nback = 1:length(list_cond)
        for nlock = 1:length(list_lock)
            
            i                                   = i +1;
            ext_lock                            = list_lock{nlock};
            
            switch run_test
                case 1
                    flist                     	= dir(['J:/temp/nback/data/sens_level_auc/timegen/' suj_name '.sess*' ...
                        '.' list_cond{nback} '.' ext_lock '.bsl.excl.timegen.mat']);
                case 2
                    
                    flist                      	= dir(['J:/temp/nback/data/sens_level_auc/timegen/' suj_name '.decoding' ...
                        '.' list_cond{nback} '.agaisnt.all.' ext_lock '.bsl.excl.timegen.mat']);
            end
            
            tmp                                 = [];
            
            for nf = 1:length(flist)
                fname                           = [flist(nf).folder filesep flist(nf).name];
                fprintf('Loading %s\n',fname);
                load(fname);
                tmp                             = cat(3,tmp,scores); clear scores;
            end
            
            pow(nlock,:,:)                      = mean(tmp,3); clear tmp;
            
        end
        
        freq                                  	= [];
        freq.dimord                          	= 'chan_freq_time';
        freq.label                            	= list_lock;
        freq.freq                              	= time_axis;
        freq.time                             	= time_axis;
        freq.powspctrm                         	= pow;
        alldata{nsuj,nback}                     = freq; clear pow ;
        
    end
    
    %     alldata{nsuj,3}                            = alldata{nsuj,1};
    %     alldata{nsuj,3}.powspctrm(:)            	= 0.5;
    
end

keep alldata list_* run_test ext_fix

i                                     	= 0;
nrow                                 	= 2;
ncol                                 	= 3;

plimit                                  = 0.05;


for nchan = 1:length(alldata{1,1}.label)
    for ncond = 1:size(alldata,2)
        
        gavg                        	= ft_freqgrandaverage([],alldata{:,ncond});
        
        cfg                          	= [];
        cfg.colormap                	= brewermap(256, '*RdBu');
        cfg.channel                 	= nchan;
        cfg.parameter               	= 'powspctrm';
        cfg.zlim                      	= [0 1];
        cfg.colorbar                  	='yes';
        
        i = i +1;
        subplot(nrow,ncol,i)
        ft_singleplotTFR(cfg,gavg);
        
        title([gavg.label{nchan} ' ' list_cond{ncond}]);
        
        c = colorbar;
        c.Ticks = cfg.zlim;
        
        ylabel('Training Time');
        xlabel('Testing Time');
        
        ylim([-0.5 2]);
        xlim([-0.5 2]);
        
        xticks([-0.5 0 0.5 1 1.5 2]);
        yticks([-0.5 0 0.5 1 1.5 2]);
        
        vline(0,'-k');
        hline(0,'-k');
        
        set(gca,'FontSize',10,'FontName', 'Calibri','FontWeight','normal');
        
        
    end
end