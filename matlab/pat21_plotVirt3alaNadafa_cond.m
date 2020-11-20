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

chn = 'maxLO' ; chn = find(strcmp(template.label,chn));
f   = 8:15 ; 

for i=1:length(f)
    f(i) = find(template.freq == f(i));
end

for i = 1:length(f)
    
    to_plot = squeeze(mean(source_avg,1));
    to_plot = squeeze(to_plot(1:3,chn,f(i),:));
    
    subplot(3,3,i);
    
    hold on ;
    
    rectangle('Position',[0.6 -0.5 0.4 abs(-0.5)+abs(0.7)],'FaceColor',[0.7 0.7 0.7]);
    
    plot(template.time,to_plot(1,:),'b');
    plot(template.time,to_plot(2,:),'r');
    plot(template.time,to_plot(3,:),'g');
    
    legend({'RCue','LCue','NCue'})
    xlim([-0.6 2]);
    ylim([-0.5 0.7]);
    vline(0,'--k');
    vline(1.2,'--k');
    title([template.label{chn} ' ' num2str(template.freq(f(i))) 'Hz'])
    
end

% toboxplot = squeeze(mean(source_avg(:,1:3,chn,f(i),30:33),5));
% boxplot(toboxplot,{'RCue','LCue','NCue'});
% ylim([-0.5 0.7]);