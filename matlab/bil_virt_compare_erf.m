clear;clc; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                 = suj_list{nsuj};
    dir_data                    = '~/Dropbox/project_me/data/bil/virt/';
    list_cond                   = {'correct' 'incorrect'}; % {'preCue.correct' 'retroCue.correct'};
    
    for nc = 1:length(list_cond)
        
        fname                   = [dir_data subjectName '.wallis.' list_cond{nc} '.erf.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
                
        ix1                     = find(round(avg.time,3) == round(-0.1,3));
        ix2                     = find(round(avg.time,3) == round(0,3));
        bsl                     = mean(avg.avg(:,ix1:ix2),2);
        act                     = avg.avg;
        
        avg.avg                 = act - bsl;
        alldata{nsuj,nc}        = avg; clear avg ix1 ix2 act bsl;
        
    end
end

keep alldata list_cond

nsuj                            = size(alldata,1);
[design,neighbours]             = h_create_design_neighbours(nsuj,alldata{1,1},'gfp','t'); clc;

cfg                             = [];
cfg.clusterstatistic            = 'maxsum';cfg.method = 'montecarlo';
cfg.correctm                    = 'cluster';cfg.statistic = 'depsamplesT';
cfg.uvar                        = 1;cfg.ivar = 2;
cfg.tail                        = 0;cfg.clustertail  = 0;
cfg.neighbours                  = neighbours;

cfg.clusteralpha                = 0.05; % !!
cfg.minnbchan                   = 0; % !!
cfg.alpha                       = 0.025;

cfg.numrandomization            = 1000;
cfg.design                      = design;

cfg.latency                     = [-0.1 5.5];

stat                            = ft_timelockstatistics(cfg, alldata{:,1},alldata{:,2});
[min_p, p_val]                  = h_pValSort(stat);


%%

close all; figure;
nrow                            = 2;
ncol                            = 2;
i                               = 0;

plimit                          = 0.05;

nw_stat                         = stat;
nw_stat.mask                    = nw_stat.prob < plimit;

for nchan = 1:length(nw_stat.label)
    
    flg                         = length(unique(nw_stat.mask(nchan,:)));
    
    if flg > 1
        
        i = i+1;
        
        cfg                     = [];
        cfg.channel             = nchan;
        cfg.time_limit          = nw_stat.time([1 end]);
        cfg.color               = 'br';
        cfg.z_limit             = [-0.000045 0.0001];
        cfg.linewidth           = 10;
        
        subplot(nrow,ncol,i);
        h_plotSingleERFstat_selectChannel_nobox(cfg,nw_stat,alldata)
        
        chk                     = nw_stat.prob(nchan,:);
        chk(chk==0)             = NaN;
        chk                     = nanmin(chk);
        
        title({nw_stat.label{nchan}});
        ylabel(['p= ' num2str(round(chk,3))]);
        
        vct_plt                 = [0 1.5 3 4.5 5.5];
        
        vline(vct_plt,'--k');
        xticklabels({'Cue1' 'Gab1' 'Cue2' 'Gab2' 'RT'}); % '1st Cue'
        xticks(vct_plt);
        
        hline(0,'--k');
        
        legend({list_cond{1} '' list_cond{2} ''});
        
        
        
    end
end