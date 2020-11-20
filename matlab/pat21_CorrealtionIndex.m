clear ; clc ; dleiftrip_addpath;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    load(['../data/tfr/' suj '.CnD.Paper.TimeCourse.KeepTrial.wav.5t18Hz.m4p4.mat'])
    
    lst_chan = {{'maxLO','maxRO'},{'maxRO'},{'maxLO'} ...
        {'maxHL','maxSTL'},{'maxHR','maxSTR'},{'maxHL','maxSTL','maxHR','maxSTR'} , ...
        {'maxHL','maxHR'},{'maxSTR','maxSTL'}};
    
    lst_freq    = [9 13];
    lst_time    = [0.2 0.6 1.4];
    
    cfg                 = [];
    cfg.baseline        = [-0.6 -0.2];
    cfg.baselinetype    = 'relchange';
    freq                = ft_freqbaseline(cfg,freq);
    
    for c_chan = 1:length(lst_chan)
        for c_freq = 1:2
            for c_time = 1:3
                
                cfg                                 = [];
                cfg.channel                         = lst_chan{c_chan};
                cfg.latency                         = [lst_time(c_time) lst_time(c_time)+0.4];
                cfg.frequency                       = [lst_freq(c_freq)-2 lst_freq(c_freq)+2];
                cfg.avgovertime                     = 'yes';
                cfg.avgoverfreq                     = 'yes';
                cfg.avgoverchan                     = 'yes';
                data                                = ft_selectdata(cfg,freq);
                big_data(c_chan,c_freq,c_time,:)    = data.powspctrm ;
                
            end
        end
    end
    
    lst_freq_compare = [1 1; 2 2; 1 2; 2 1];
    
    lst_chan_compare = [1 4; 1 5 ;1 6;1 7;1 8; ...
       2 4; 2 5 ;2 6;2 7;2 8; ...
       3 4; 3 5 ;3 6;3 7;3 8];
    
    %     lst_chan_compare = [ones(length(lst_chan)-1,1) [2:length(lst_chan)]'];
    
    load '../data/yctot/rt/rt_cond_classified.mat';
    
    for c_time = 1:3
        for x = 1:size(lst_freq_compare,1)
            for y = 1:size(lst_chan_compare,1)
                
                dataOcc     = squeeze(big_data(lst_chan_compare(y,1),lst_freq_compare(x,1),c_time,:));
                dataAud     = squeeze(big_data(lst_chan_compare(y,2),lst_freq_compare(x,2),c_time,:));
                dataMean    = mean([dataOcc dataAud],2);
                corrIndex   = (dataAud-dataOcc)./(dataMean);
                
                [rho,p]         = corr(corrIndex,rt_all{sb} , 'type', 'Spearman');
                rhoF            = .5.*log((1+rho)./(1-rho));
                corr2R(sb,c_time,x,y) = rhoF;
                
            end
        end
    end
    
    clearvars -except sb corr2R
    
end

clearvars -except corr2R

lst_chan    = {'RLocc.Laud','RLocc.Raud','RLocc.RLaud','RLocc.Hesch','RLocc.STG', ...
                'Rocc.Laud','Rocc.Raud','Rocc.RLaud', 'Rocc.Hesch','Rocc.STG',...
                  'Locc.Laud','Locc.Raud','Locc.RLaud','Locc.Hesch','Locc.STG',};

lst_freq    = {'lowOcc.lowAud','highOcc.highAud','lowOcc.highAud','highOcc.lowAud'};

lst_time    = {'early','late','post'};

fOUT        = '../txt/ActivityIndexAll.sepOcc.sepAud.2taper.txt';
fid         = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','SUB','DIR','TIME','CHAN','CORR');


for sb = 1:14
    for t = 1:size(corr2R,2)
        for f = 1:size(corr2R,3)
            for c = 1:size(corr2R,4)
                
                fprintf(fid,'%s\t%s\t%s\t%s\t%.2f\n',['yc' num2str(sb)],lst_freq{f},lst_time{t},lst_chan{c},corr2R(sb,t,f,c));
                
            end
        end
    end
end

fclose(fid); clc ;