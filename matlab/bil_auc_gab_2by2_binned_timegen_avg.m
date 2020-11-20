clear;clc;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                         = suj_list{nsuj};
    dir_data                            = '~/Dropbox/project_me/data/bil/decode/';
    
    list_frequency                      = {'beta'}; % 'theta' 'alpha' 'gamma' 
    decoding_list                       = {'frequency'}; % 'orientation'
    
    list_bin                            = [1 5];
    name_bin                            = {'Bin1' 'Bin5'};
    
    for nfreq = 1:length(list_frequency)
        for nbin = 1:length(list_bin)
            
            ext_name                    = '.all.bsl.timegen.mat';
            
            pow                         = [];
            
            for ndeco = 1:length(decoding_list)
                
                %                 flist_1               	= dir([dir_data subjectName '.1stgab.decodinggabor.' frequency_list{nfreq} ...
                %                     '.band.preGab1.window.bin' num2str(list_bin(nbin)) '.' decoding_list{ndeco}  ext_name]);
                
                flist_1               	= dir([dir_data subjectName '.1stgab.decodinggabor.' list_frequency{nfreq} ...
                    '.band.preGab1.window.bin' num2str(list_bin(nbin)) '.' decoding_list{ndeco}  ext_name]);
                
                flist                   = [flist_1]; clear flist_* %;flist_2];
                
                tmp                     = [];
                
                for nf = 1:length(flist)
                    fname               = [flist(nf).folder filesep flist(nf).name];
                    fprintf('loading %s\n',fname);
                    load(fname);
                    tmp(nf,:,:)     	= scores;clear scores;
                end
                
                pow(ndeco,:,:)          = squeeze(mean(tmp,1)); clear tmp;
                
            end
            
            t1                          = find(round(time_axis,3) == round(0.0,3));
            t2                          = find(round(time_axis,3) == round(0.3,3));
            
            avg                         = [];
            
            avg.avg                     = squeeze(mean(pow(:,t1:t2,:),2));
            if size(avg.avg,2) < size(avg.avg,1)
                avg.avg                     = avg.avg';
            end
            avg.label                   = decoding_list;
            avg.dimord                  = 'chan_time';
            avg.time                    = time_axis;
            
            alldata{nsuj,nfreq,nbin}  	= avg; clear avg;
            
        end
    end
end

keep alldata list_*

%%

nsuj                            = size(alldata,1);
[design,neighbours]             = h_create_design_neighbours(nsuj,alldata{1,1},'gfp','t'); clc;

for nfreq = 1:size(alldata,2)
    
    cfg                         = [];
    cfg.clusterstatistic        = 'maxsum';cfg.method = 'montecarlo';
    cfg.correctm                = 'cluster';cfg.statistic = 'depsamplesT';
    cfg.uvar                    = 1;cfg.ivar = 2;
    cfg.tail                    = 0;cfg.clustertail  = 0;
    cfg.neighbours              = neighbours;
    
    cfg.latency                 = [-0.05 3];
    cfg.clusteralpha            = 0.05; % !!
    cfg.minnbchan               = 0; % !!
    cfg.alpha                   = 0.025;
    
    cfg.numrandomization        = 1000;
    cfg.design                  = design;
    
    allstat{nfreq}              = ft_timelockstatistics(cfg, alldata{:,nfreq,1}, alldata{:,nfreq,2});
    
end

keep alldata list_* allstat name_bin

%% - % - 

figure;
nrow                            = 2;
ncol                            = 2;
i                               = 0;
zlimit                          = [0.55 0.8];
plimit                          = 0.1;

for nfreq = 1:length(allstat)
    
    stat                        = allstat{nfreq};
    stat.mask                   = stat.prob < plimit;
    
    for nchan = 1:length(stat.label)
        
        vct                     = stat.prob(nchan,:);
        min_p                   = min(vct);
        
        cfg                     = [];
        cfg.channel             = nchan;
        cfg.time_limit          = stat.time([1 end]);
        cfg.color               = {'-b' '-r'};
        cfg.z_limit             = zlimit(nchan,:);
        cfg.linewidth           = 10;
        
        i = i+1;
        subplot(nrow,ncol,i);
        h_plotSingleERFstat_selectChannel_nobox(cfg,stat,squeeze(alldata(:,nfreq,[1 2])));
        
        ylabel({stat.label{nchan}, ['p= ' num2str(round(min_p,3))]})
        
        
        vline([0],'--k');
        
        xticks([0 0.5 1 1.5 2 2.5 3]);
        xticklabels({'Gab' '0.5' '1' 'Cue2' '2' '2.5' 'Gab2'});
        
        title(list_frequency{nfreq});
        
        %         legend(name_bin);
        
        set(gca,'FontSize',16,'FontName', 'Calibri','FontWeight','normal');
        
    end
end