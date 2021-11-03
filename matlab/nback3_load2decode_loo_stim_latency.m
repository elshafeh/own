clear;clc;

suj_list                    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    sujname                 = ['sub' num2str(suj_list(nsuj))];
    
    dir_files            	= '~/Dropbox/project_me/data/nback/';
    ext_decode          	= 'stim';
    
    %     fname                   = [dir_files 'trialinfo/' sujname '.flowinfo.mat'];
    
    fname                   = [dir_files 'trialinfo/' sujname '.trialinfo.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    cfg                     = [];
    cfg.stim_focus        	= 'all';
    cfg.outliers            = 'keep';
    cfg.incorrect        	= 'keep';
    cfg.zeros               = 'keep';
    cfg.equalize            = 'yes';
    [index_trials]          = func_load_split(cfg,trialinfo);
    
    list_stim               = [1 2 3 4 5 6 7 8 9];
    
    for nstim = 1:length(list_stim)
        
        % load decoding output
        dir_files          	= '~/Dropbox/project_me/data/nback/';
        fname            	= [dir_files 'auc/' sujname '.decoding.stim' num2str(list_stim(nstim)) '.nodemean.leaveone.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        % transpose matrices
        y_array            	= y_array';
        yproba_array      	= yproba_array';
        e_array          	= e_array';
        yhat_array          = yhat_array';
        
        measure           	= 'yproba'; % auc yproba
        
        for nbin = [1 2]
            
            idx_trials   	= index_trials{nbin};
            AUC_bin_test   	= [];
            
            disp('computing AUC');
            
            for ntime = 1:size(y_array,2)
                
                if strcmp(measure,'yproba')
                    
                    yproba_array_test     	= yproba_array(idx_trials,ntime);
                    
                    if min(unique(y_array(:,ntime))) == 1
                        yarray_test        	= y_array(idx_trials,ntime) - 1;
                    else
                        yarray_test       	= y_array(idx_trials,ntime);
                    end
                    
                    try
                        [~,~,~,AUC_bin_test(ntime)]	= perfcurve(yarray_test,yproba_array_test,1);
                    catch
                        AUC_bin_test(ntime)         = NaN;
                    end
                    
                elseif strcmp(measure,'auc')
                    AUC_bin_test(ntime)     = mean(e_array(idx_trials,ntime));
                elseif strcmp(measure,'confidence')
                    AUC_bin_test(ntime)     = mean(yhat_array(idx_trials,ntime));
                end
            end
            
            avg             = [];
            avg.avg         = AUC_bin_test;
            avg.time        = time_axis;
            avg.label       = {['decoding ' ext_decode]};
            avg.dimord   	= 'chan_time';
            
            alldata{nsuj,nbin,nstim}        = avg; clear avg;
            
        end
    end
    
end

%%

keep alldata list_* ext_decode

for nsuj = 1:size(alldata,1)
    for nbin = 1:size(alldata,2)
        
        tmp         = [];
        i           = 0;
        
        for nstim = 1:size(alldata,3)
            if ~isempty(alldata{nsuj,nbin,nstim})
                tmp     = [tmp; alldata{nsuj,nbin,nstim}.avg];
                i       = nstim;
            end
        end
        
        newdata{nsuj,nbin}          = alldata{nsuj,nbin,1};
        newdata{nsuj,nbin}.avg      = nanmean(tmp,1); clear tmp;
        
        
        clear tmp;
        
    end
end

alldata                         = newdata;

%%

keep alldata

for nsuj = 1:size(alldata,1)
    for ncond = 1:size(alldata,2)
        
        time_axis               = alldata{nsuj,ncond}.time;
        
        t1                      = nearest(time_axis,0.1);
        t2                      = nearest(time_axis,0.4);
        
        vector                  = alldata{nsuj,ncond}.avg(1,t1:t2);
        time_axis               = time_axis(t1:t2);
        
        
        find_max                = find(vector == max(vector));
        
        allatency(nsuj,ncond)   = time_axis(find_max(1));
        
        clear time_axis vector find_max
        
    end
end


clc;close all;

x                       = allatency(:,1);
y                       = allatency(:,2);

[h,p,ci,stats]          = ttest(x,y);
boxplot([x y]);
xticklabels({'1back' '2back'});

ylabel('Peak latency');

title({[' t = ' num2str(round(stats.tstat,2)) ' p = ' num2str(round(p,2))]});
set(gca,'FontSize',18,'FontName', 'Calibri','FontWeight','normal');

