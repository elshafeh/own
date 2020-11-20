clear ; close all;

suj_list    = [1:33 35:36 38:44 46:51];

for ns = 1:length(suj_list)
    
    suj_name                                    = ['sub' num2str(suj_list(ns))];
    
    for nback = [0 1 2]
        
        i                                     	= 0;
        
        for nsess = 1:2
            for nstim = 1:9
                
                fname                           = ['K:/nback/timegen/' suj_name '.sess' num2str(nsess) '.stim' num2str(nstim) '.' num2str(nback) 'back.dwn60.auc.timegen.mat'];
                
                if exist(fname)
                    i                               = i +1;
                    fprintf('Loading %s\n',fname);
                    load(fname);
                    
                    tmp(i,:,:)                  = scores; clear scores;
                end
                
            end
            
            pow(ns,nback+1,:,:)             	= squeeze(mean(tmp,1));
        end
    end
    
    keep ns pow time_axis suj_list
    
end

keep alldata ns pow time_axis

time_width                                  = 0.2;
time_list                                   = [0:time_width:1.6];

i                                           = 0;
nrow                                        = 4;
ncol                                        = 3;

for nt = 1:length(time_list)
    
    x1              = find(round(time_axis,2) == round(time_list(nt),2));
    x2              = find(round(time_axis,2) == round(time_list(nt)+time_width,2));
    
    mtrx_data       = squeeze(mean(pow(:,:,x1:x2,:),3));
    
    mean_data       = squeeze(nanmean(mtrx_data,1));
    bounds      	= squeeze(nanstd(mtrx_data, [], 1));
    bounds_sem     	= bounds ./ sqrt(size(mtrx_data,1));
    
    list_color      = 'brk';
    
    i                                   = i + 1;
    subplot(nrow,ncol,i)
    hold on;
    
    for nback = 1:3
        boundedline(time_axis, mean_data(nback,:), bounds_sem(nback,:),['-' list_color(nback)],'alpha'); % alpha makes bounds transparent
    end
    
end

