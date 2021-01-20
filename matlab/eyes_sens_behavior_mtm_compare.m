clear ; clc;

suj_list          	= {};
for j = 1:9
    suj_list{j,1} 	= ['sub00', num2str(j)];
end
for k = [10:12,17,18,20:37,39]
    j             	= j+1;
    suj_list{j,1} 	= ['sub0', num2str(k)];
end

list_eye            = {'open' 'close'};
list_cue            = {'*'}; %{'left' 'right'};
list_beh            = {'correct' 'incorrect'};
i                   = 0 ;

for a = 1:length(list_eye)
    for b = 1:length(list_cue)
        for c = 1:length(list_beh)
            
            i                       = i + 1;
            
            list_cond(i).eye       	= list_eye{a};
            list_cond(i).cue        = list_cue{b};
            list_cond(i).beh     	= list_beh{c};
            
        end
    end
end

list_beh                = {'fast' 'slow'};

for a = 1:length(list_eye)
    for b = 1:length(list_cue)
        for c = 1:length(list_beh)
            
            i                       = i + 1;
            
            list_cond(i).eye       	= list_eye{a};
            list_cond(i).cue        = list_cue{b};
            list_cond(i).beh     	= list_beh{c};
            
        end
    end
end

keep suj_list list_cond

for nsuj = 1:length(suj_list)
    
    subjectName                       	= suj_list{nsuj};
    
    for nc = 1:length(list_cond)
    
        dir_data                        = '~/Dropbox/project_me/data/eyes/tf/';
        flist                           = dir([dir_data subjectName '.stimlock.eyes.'  list_cond(nc).eye '.cue.' list_cond(nc).cue '.beh.' list_cond(nc).beh '.mtm.mat']);
        tmp                             = {};
        
        for nf = 1:length(flist)
            
            fname                     	= [flist(nf).folder filesep flist(nf).name];
            fprintf('Loading %s\n',fname);
            load(fname);
            
            t1                        	= find(round(freq.time,2) == round(-2.496,2));
            t2                        	= find(round(freq.time,2) == round(-2,2));
            bsl                      	= nanmean(freq.powspctrm(:,:,t1:t2),3);
            freq.powspctrm           	= (freq.powspctrm - bsl) ./ bsl; clear bsl t1 t2;
            tmp{nf}                     = freq; clear freq;
            
        end
        
        if length(tmp) > 1
            alldata{nsuj,nc}            = tmp{1};
            alldata{nsuj,nc}.powspctrm	= mean(cat(4,tmp{1}.powspctrm,tmp{2}.powspctrm),4);
        else
            alldata{nsuj,nc}            = tmp{1};
        end
        
        clear tmp nf
        
    end
    
    clc;
    
end

keep alldata list_cond

%%

keep alldata list_cond

nsuj                                    = size(alldata,1);
[design,neighbours]                     = h_create_design_neighbours(nsuj,alldata{1,1},'meg','t'); clc;

list_test                               = [1 2; 3 4; 5 6; 7 8];
list_name                               = {};
i                                       = 0;

for ntest = 1:size(list_test,1)
    
    cfg                                 = [];
    cfg.clusterstatistic                = 'maxsum';cfg.method = 'montecarlo';
    cfg.correctm                        = 'cluster';cfg.statistic = 'depsamplesT';
    cfg.uvar                            = 1;cfg.ivar = 2;
    cfg.tail                            = 0;cfg.clustertail  = 0;
    cfg.neighbours                      = neighbours;
    
    cfg.clusteralpha                    = 0.05; % !!
    cfg.minnbchan                       = 3; % !!
    cfg.alpha                           = 0.025;
    
    cfg.numrandomization                = 1000;
    cfg.design                          = design;
    
    i                                   = i +1;
    ix1                                 = list_test(ntest,1);
    ix2                                 = list_test(ntest,2);
    
    cfg.latency                         = [-2 0];
    cfg.frequency                       = [7 30];
    
    list_name{i}                        = [list_cond(ix1).eye '.' list_cond(ix1).cue '.' list_cond(ix1).beh ' vs ' list_cond(ix2).eye '.' list_cond(ix2).cue '.' list_cond(ix2).beh];
        
    stat{i}                             = ft_freqstatistics(cfg, alldata{:,ix1},alldata{:,ix2});
    [min_p(i), p_val{i}]                = h_pValSort(stat{i});
    
end

keep alldata list_cond stat min_p p_val list_name

%%

keep alldata list_cond stat min_p p_val list_name;
close all;

for ntest = 1:length(stat)
    
    plimit                              = 0.15;
    
    if min_p(ntest) < plimit
        cfg                            	= [];
        cfg.layout                    	= 'CTF275_helmet.mat';
        cfg.zlim                     	= [-3 3];
        cfg.colormap                  	= brewermap(256,'*RdBu');
        cfg.plimit                   	= plimit;
        cfg.vline                      	= [0];
        cfg.sign                       	= [-1 1];
        cfg.test_name                  	= list_name{ntest};
        h_plotstat_3d(cfg,stat{ntest});
    end
    
end