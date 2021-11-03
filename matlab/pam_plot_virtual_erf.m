clear;

for nsuj = 2:21
    
    sujname           	= ['yc' num2str(nsuj)];
    
    fname              	= ['~/Dropbox/project_me/data/pam/virt/' sujname '.CnD.virtualelectrode.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    avg               	= ft_timelockanalysis([],data);
    
    avg.avg             = abs(avg.avg);
    
    ix1                 = nearest(avg.time,-0.1);
    ix2                 = nearest(avg.time,0);
    bsl                 = mean(avg.avg(:,ix1:ix2),2);
    act                 = avg.avg;
    
    avg.avg             = act - bsl;
    
    alldata{nsuj-1,1}  	= avg; clear avg;
    
end

keep alldata

%%

clc;

list_type                       = {'atlas' 'loc'};
list_title                      = {'atlas based' 'localizer based'};

for ntype = [1 2]
    
    subplot(2,1,ntype) % subplot(1,2,ntype) % 
    hold on
    
    list_mod                    = {'vis' 'aud' 'mot'};
    list_color                	= 'brg';

    for nmod = [1 2 3]
        
        mtrx_data               = [];
        
        for nsuj = 1:size(alldata,1)
            flg_chan            = find(contains(alldata{nsuj}.label,[list_mod{nmod} ' ' list_type{ntype}]));
            mtrx_data(nsuj,:)  	= mean((alldata{nsuj}.avg(flg_chan,:)),1);
        end
        
        time_axis               = alldata{1}.time;
        
        % Use the standard deviation over trials as error bounds:
        mean_data               = nanmean(mtrx_data,1);
        bounds                  = nanstd(mtrx_data, [], 1);
        bounds_sem              = bounds ./ sqrt(size(mtrx_data,1));
        
        boundedline(time_axis, mean_data, bounds_sem,['-' list_color(nmod)],'alpha'); % alpha makes bounds transparent
        
    end
    
    xlim([-0.1 2]);
    
    y_lim                       = [-1e10 20e10];
    
    ylim(y_lim);
    yticks(y_lim);
    
    xticks([0 0.2 0.4 0.6 0.8 1 1.2 1.4 1.6 1.8 2]);
    xticklabels({'vis cue' '0.2' '0.4' '0.6' '0.8' '1' 'aud target' '1.4' '1.6' '1.8' '2'});
    
    vline([0 1.2],'--k');
    hline(0,'--k');
    
    legend({list_mod{1} '' list_mod{2} '' list_mod{3}});
    
    title(list_title{ntype});
    
    set(gca,'FontSize',16)
    
end