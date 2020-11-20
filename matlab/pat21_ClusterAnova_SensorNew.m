clear ; clc ;  dleiftrip_addpath ;

load ../data/yctot/rt/rt_CnD_adapt.mat

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    list_cnd = {'RCnD','LCnD','NCnD'};
    
    for cnd = 1:3
        
        fname = ['../data/' suj '/tfr/' suj '.' list_cnd{cnd} '.all.wav.5t18Hz.m4p4.mat'];
        fprintf('Loading %30s\n',fname);
        load(fname);
        
        cfg = [];
        cfg.baseline                = [-0.6 -0.2];
        cfg.baselinetype            = 'relchange';
        allsuj_GA{sb,cnd}           = ft_freqbaseline(cfg,freq);
        allsuj_GA{sb,cnd}.cfg       = [];
        
    end
    
end

clearvars -except allsuj_GA

frq_list = 5:15;
tm_list  = 0:0.1:1.1;
chn_list = allsuj_GA{1,1}.label ;

nb_test_tot = length(frq_list) * length(tm_list) * 275 ; 
nb_test = 0 ;

for t = 1:length(tm_list)
    
    for f = 1:length(frq_list)
        
        for chn = 1:275
            
            nb_test = nb_test + 1; 
            
            fprintf('Computing Test no. %5d out of %5d\n',nb_test,nb_test_tot);
            
            Y   = [];  S = [];
            F1  = []; F2 = [];
            
            for cnd = 1:3
                
                for sb = 1:14
                    
                    lm_t1  = find(round(allsuj_GA{1,1}.time,2) == round(tm_list(t),2));
                    lm_t2  = find(round(allsuj_GA{1,1}.time,2) == round(tm_list(t)+0.1,2));
                    lm_f   = find(allsuj_GA{1,1}.freq == frq_list(f));
                    
                    data = squeeze(nanmean(allsuj_GA{sb,cnd}.powspctrm(chn,lm_f,lm_t1:lm_t2)));
                    
                    Y   =   [Y; data];
                    S   =   [S;sb];
                    F1  =   [F1;cnd];
                    F2  =   [F2;1];
                    
                    clear data 
                    
                end
                
            end
            
            res                             =   PrepAtt2_rm_anova(Y,S,F1,F2,{'Cue','F'});
            anovaResults_P(chn,f,t)         =   res{2,6};
            anovaResults_F(chn,f,t)         =   res{2,5};
            
            clear res
            
        end
        
    end
    
end

clearvars -except anovaResults_P anovaResults_F frq_list tm_list chn_list

for sb = 1:14
   
    allsuj{sb,1}.powspctrm          =  anovaResults_P ;
    allsuj{sb,2}.powspctrm          =  anovaResults_F ;
    allsuj{sb,3}.powspctrm          =  allsuj{sb,1}.powspctrm ;
    allsuj{sb,3}.powspctrm(:,:,:)   = 0 ;
    
    for cnd = 1:3
        allsuj{sb,cnd}.freq     = frq_list ;
        allsuj{sb,cnd}.time     = tm_list ;
        allsuj{sb,cnd}.dimord   = 'chan_freq_time' ;
        allsuj{sb,cnd}.label    = chn_list ; 
    end
    
end

clearvars -except allsuj

create_design_neighbours ; clc;

cfg                     = [];
cfg.channel             = 'MEG';
cfg.latency             = [0 1.1];
cfg.frequency           = [5 15];
cfg.clusterstatistic    = 'maxsum';
cfg.method              = 'montecarlo';
cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.alpha               = 0.025;
cfg.minnbchan           = 2;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.numrandomization    = 1000;
cfg.design              = design;
cfg.neighbours          = neighbours;
cfg.uvar                = 1;
cfg.ivar                = 2;
stat{1}                 = ft_freqstatistics(cfg, allsuj{:,1}, allsuj{:,3});
stat{2}                 = ft_freqstatistics(cfg, allsuj{:,2}, allsuj{:,3});

for s = 1:2
    [min_p{s} , p_val{s}] = h_pValSort(stat{s}) ;
    stat2plot{s} = h_plotStat(stat{s},0.05,'p','yes');
end


for f = 5:15
    
    subplot(3,4,f-4)
    
    cfg                 = [];
    cfg.layout          = 'CTF275.lay';
    cfg.ylim            = [f f];
    cfg.zlim            = [-0.5 0.5];
    cfg.comment         = 'no';
    ft_topoplotTFR(cfg,stat2plot{2})
    title([num2str(f) 'Hz']);
    
end