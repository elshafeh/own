clear ; clc ;

fin_ext   = 'PaperExtConvol';
fname = ['../data/yctot/' fin_ext '.mat'];

load(fname); clear ext ;

% Baseline Correct & Choose %

for sb = 1:size(allsuj,1)
    
    for cnd = 1:size(allsuj,2)
        
        tmp = allsuj{sb,cnd}(:,:,:) ;
        
        bt1 = find(round(template.time,2) == -0.6);
        bt2 = find(round(template.time,2) == -0.2);
        
        bsl = mean(tmp(:,:,bt1:bt2),3);
        bsl = repmat(bsl,1,1,size(tmp,3));
        
        tmp = (tmp-bsl)./ bsl ;
        
        clear bsl bt1 bt2
        
        t1 = find(round(template.time,2) == -0.6);
        t2 = find(round(template.time,2) == 2);
        
        new_template.time = template.time(t1:t2);
        
        f1 = find(round(template.freq) == 7);
        f2 = find(round(template.freq) == 15);
        
        source_avg(sb,cnd,:,:,:) = tmp(:,f1:f2,t1:t2) ;
        
        new_template.freq = round(template.freq(f1:f2));
        
        clear t1 t2 f1 f2
        
        new_template.label = template.label;
        
        clear tmp
        
    end
end

template = new_template ; clearvars -except source_avg template;

tot_chn_list = [1 3 5 7 9; 2 4 6 8 10];

i = 0 ; 

for hemi = 1:2
    
    for frq_bnd = [2 4 6]
        
        i = i + 1 ;
        
        to_plot = squeeze(source_avg(:,5,:,frq_bnd:frq_bnd+2,:));
        to_plot = squeeze(mean(to_plot,1));
        to_plot = squeeze(mean(to_plot,2));
        to_plot = to_plot(tot_chn_list(hemi,:),:);
        
        subplot(2,3,i)
        
        plot(template.time,to_plot)
        legend(template.label(tot_chn_list(hemi,:)))
        xlim([-0.6 2]);
        ylim([-0.5 0.5]);
        vline(0,'--k');
        vline(1.2,'--k');
        hline(0,'--k');
        title([num2str(template.freq(frq_bnd)) 't' num2str(template.freq(frq_bnd+2)) 'Hz'])
        
        clear to_plot
        
    end
    
end