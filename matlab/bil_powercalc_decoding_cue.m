clear;

load ../data/bil_goodsubjectlist.27feb20.mat
 
for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    
    perc_list                       = {'10perc' '20perc' '30perc' '40perc' ...
        '50perc' '60perc' '70perc' '80perc' '90perc' '100perc'};
    
    decoding_list                   = {'pre.ori.vs.spa' 'retro.ori.vs.spa'};
    
    for nper = 1:length(perc_list)
        
        avg                         = [];
        avg.avg                     = [];
        
        for ndeco = 1:length(decoding_list)
            fname                   = ['~/Dropbox/project_me/data/bil/decode/' subjectName '.1stcue.lock.beta.centered' ...
                '.decodingcue.' decoding_list{ndeco}  '.correct.' perc_list{nper} '.auc.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            avg.avg                 = [avg.avg;scores]; clear scores;
        end
        
        avg.label                   = decoding_list;
        avg.dimord                  = 'chan_time';
        avg.time                    = time_axis;
        
        alldata{nsuj,nper}          = avg; clear avg;
        
    end
end

keep alldata *_list

list_time                           = [0.1 0.8; 3 4.5];

for nsuj = 1:size(alldata,1)
    for nper = 1:size(alldata,2)
        for nfeat = 1:size(alldata{nsuj,nper}.avg,1)
            
            t1                              = find(round(alldata{nsuj,nper}.time,2) == round(list_time(nfeat,1),2));
            t2                              = find(round(alldata{nsuj,nper}.time,2) == round(list_time(nfeat,2),2));
            
            mtrx_data(nsuj,nper,nfeat,:) 	= mean(alldata{nsuj,nper}.avg(nfeat,t1:t2));
            
        end
    end
end

keep alldata *_list mtrx_data list_*

perc_list                       = {'10%' '20%' '30%' '40%' '50%' '60%' '70%' '80%' '90%' '100%'};
decoding_list                   = {'Pre Cue: Orientation vs Frequency' 'Retro Cue: Orientation vs Frequency'};

for nfeat = 1:2
    
    subplot(2,2,nfeat)
    
    sub_data                = squeeze(mtrx_data(:,:,nfeat,:));
    mean_data               = squeeze(nanmean(sub_data,1));
    bounds                  = squeeze(nanstd(sub_data, [], 1));
    bounds_sem              = squeeze(bounds ./ sqrt(size(sub_data,1)));
    
    errorbar([1:10],mean_data,bounds_sem,'-s','MarkerSize',10,'MarkerEdgeColor','red','MarkerFaceColor','red');
    
    xticks([1 2 3 4 5 6 7 8 9 10]);
    xlim([0 11]);
    xticklabels(perc_list);
    
    ylim([0.47 0.55]);
    yticks([0.47 0.55]);
    
    title(decoding_list{nfeat});
    
    hline(0.5,'--k');
    
    set(gca,'FontSize',16,'FontName', 'Calibri');
    
end

for nsuj = 1:length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    
    perc_list                       = {'10perc' '20perc' '30perc' '40perc' ...
        '50perc' '60perc' '70perc' '80perc' '90perc' '100perc'};
    
    decoding_list                   = {'orientation' 'frequency'};
    
    for nper = 1:length(perc_list)
        
        avg                         = [];
        avg.avg                     = [];
        
        for ndeco = 1:length(decoding_list)
            
            flist                   = dir(['~/Dropbox/project_me/data/bil/decode/' subjectName '.*.lock.beta.centered' ...
                '.decodinggabor.' decoding_list{ndeco}  '.correct.' perc_list{nper} '.auc.mat']);
            tmp                     = [];
            
            for nfile = 1:length(flist)
                fname               = [flist(nfile).folder filesep flist(nfile).name];    
                fprintf('loading %s\n',fname);
                load(fname);
                tmp                 = [tmp;scores];clear scores;
            end
            
            avg.avg                 = [avg.avg ;mean(tmp,1)]; clear tmp;
        end
        
        avg.label                   = decoding_list;
        avg.dimord                  = 'chan_time';
        avg.time                    = time_axis;
        
        alldata{nsuj,nper}          = avg; clear avg;
        
    end
end


list_time                           = [0.05 0.4; 0 0.75];

for nsuj = 1:size(alldata,1)
    for nper = 1:size(alldata,2)
        for nfeat = 1:size(alldata{nsuj,nper}.avg,1)
            
            t1                              = find(round(alldata{nsuj,nper}.time,2) == round(list_time(nfeat,1),2));
            t2                              = find(round(alldata{nsuj,nper}.time,2) == round(list_time(nfeat,2),2));
            
            mtrx_data(nsuj,nper,nfeat,:) 	= mean(alldata{nsuj,nper}.avg(nfeat,t1:t2));
            
        end
    end
end

keep alldata *_list mtrx_data list_*

perc_list                       = {'10%' '20%' '30%' '40%' '50%' '60%' '70%' '80%' '90%' '100%'};

for nfeat = 1:2
    
    subplot(2,2,nfeat+2)
    
    sub_data                = squeeze(mtrx_data(:,:,nfeat,:));
    mean_data               = squeeze(nanmean(sub_data,1));
    bounds                  = squeeze(nanstd(sub_data, [], 1));
    bounds_sem              = squeeze(bounds ./ sqrt(size(sub_data,1)));
    
    errorbar([1:10],mean_data,bounds_sem,'-s','MarkerSize',10,'MarkerEdgeColor','red','MarkerFaceColor','red');
    
    xticks([1 2 3 4 5 6 7 8 9 10]);
    xlim([0 11]);
    xticklabels(perc_list);
    
    ylim([0.47 0.55]);
    yticks([0.47 0.55]);
    
    title(decoding_list{nfeat});
    
    hline(0.5,'--k');
    
    set(gca,'FontSize',16,'FontName', 'Calibri');
    
end