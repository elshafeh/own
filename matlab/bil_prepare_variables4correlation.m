clear;clc;
global ft_default;
ft_default.spmversion = 'spm12';

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName               	= suj_list{nsuj};
    auc_measures             	= [];
    
    dir_data                 	= 'D:/Dropbox/project_me/data/bil/decode/';
    
    frequency_list           	= {'broadband'};
    decoding_list            	= {'pre.ori.vs.spa' 'retro.ori.vs.spa'};
    
    avg                         = [];
    avg.avg                     = [];
    
    for ndeco = 1:length(decoding_list)
        fname                  	= [dir_data subjectName '.1stcue.lock' ...
            '.broadband.centered.decodingcue.' decoding_list{ndeco}  '.correct.auc.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        avg.avg                 = [avg.avg;scores]; clear scores;
    end
    
    avg.time                	= time_axis;
    
    t1                          = find(round(time_axis,2) == round(0.1,2));
    t2                          = find(round(time_axis,2) == round(0.6,2));
    t3                          = find(round(time_axis,2) == round(1.6,2));
    t4                          = find(round(time_axis,2) == round(2.1,2));
    
    auc_measures(1).name        = 'cue deco';
    auc_measures(1).value    	= mean(avg.avg(1,[t1:t2 t3 t4]),2);
    
    %     auc_measures(2).name        = 'retro task';
    %     auc_measures(2).value    	= mean(avg.avg(1,t3:t4),2);
    
    keep auc_measures nsuj subjectName suj_list dir_data
    
    frequency_list                      = {'broadband'};
    
    decoding_list                       = {'frequency' 'orientation'};
    
    avg                             = [];
    avg.avg                         = [];
    
    for ndeco = 1:length(decoding_list)
        
        % load files for both gabors
        tmp1                 	= dir([dir_data subjectName '.1stgab.lock' ...
            '.broadband.centered.decodinggabor.' decoding_list{ndeco}  '.correct.bsl.auc.mat']);
        
        tmp2                 	= dir([dir_data subjectName '.2ndgab.lock' ...
            '.broadband.centered.decodinggabor.' decoding_list{ndeco}  '.correct.bsl.auc.mat']);
        
        flist                   = [tmp1;tmp2];
        
        
        for nf = 1:length(flist)
            fname             	= [flist(nf).folder filesep flist(nf).name];
            fprintf('loading %s\n',fname);
            load(fname);
            
            avg.avg         	= [avg.avg;scores]; clear scores
        end
        
        
    end
    
    tmp                         = [mean(avg.avg([1 3],:),1);mean(avg.avg([2 4],:),1)];
    avg.avg                     = tmp;
    avg.time                	= time_axis;
    
    t1                          = find(round(time_axis,2) == round(0.1,2));
    t2                          = find(round(time_axis,2) == round(0.4,2));
    
    auc_measures(2).name        = 'gab deco';
    auc_measures(2).value    	= mean(mean(avg.avg(:,t1:t2),2));
    
    %     auc_measures(4).name        = 'gab2 prop';
    %     auc_measures(4).value    	= mean(avg.avg(2,t1:t2),2);
    
    keep auc_measures nsuj subjectName suj_list dir_data
    
    decoding_list             	= {'match'};
    
    avg                         = [];
    avg.avg                     = [];
    
    for ndeco = 1:length(decoding_list)
        
        % load files for both gabors
        flist                   = dir([dir_data subjectName '.1stcue.lock' ...
            '.broadband.centered.decodingresp.' decoding_list{ndeco}  '.auc.mat']);
        
        if length(flist )== 1
            score_concat     	= [];
            
            for nf = 1:length(flist)
                fname         	= [flist(nf).folder filesep flist(nf).name];
                fprintf('loading %s\n',fname);
                load(fname);
                score_concat   	= [score_concat;scores]; clear scores;
            end
        else
            error('files missing');
        end
        
        avg.avg                 = [avg.avg;nanmean(score_concat,1)];clear score_concat;
    end
    
    avg.time                	= time_axis;
    
    t1                          = find(round(time_axis,2) == round(4.8,2));
    t2                          = find(round(time_axis,2) == round(5.2,2));
    
    auc_measures(3).name        = 'match deco';
    auc_measures(3).value    	= mean(avg.avg(1,t1:t2),2);
    
    keep auc_measures nsuj subjectName suj_list dir_data
    
    fname_out                   = ['P:/3015079.01/data/' subjectName '/behav/' subjectName '.auc2correlate.trio.mat'];
    
    fprintf('saving %s\n\n',fname_out);
    save(fname_out,'auc_measures');
    
    keep nsuj suj_list
    
end