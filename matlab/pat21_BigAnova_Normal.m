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
        
        new_template.freq = template.freq(f1:f2);
        
        clear t1 t2 f1 f2
        
        new_template.label = template.label;
        
        clear tmp
        
    end
end

template = new_template ; clearvars -except source_avg template fin_ext;

time_list = [-0.6 -0.4 -0.2 0:0.1:0.9];

fOUT = ['../txt/' fin_ext '.m' num2str(abs(time_list(1)*1000)) '.p' num2str(abs(time_list(end)*1000)) '.txt'] ; clear t_* ;
fid  = fopen(fOUT,'W+');

fprintf(fid,'%4s\t%4s\t%7s\t%5s\t%5s\t%5s\n','SUB','COND','CHAN','FREQ','TIME','AVG');

for sb = 1:size(source_avg,1)
    
    for cnd = 1:3
        
        for chn = 1:10
            
            for f = 1:size(source_avg,4)
                
                for t = 1:length(time_list)
                    
                    x = find(round(template.time,2) == round(time_list(t),2));
                    y = find(round(template.time,2) == round(time_list(t)+0.1,2));
                    
                    avg = mean(source_avg(sb,cnd,chn,f,x:y),5);
                    
                    frq_out = [num2str(round(template.freq(f))) 'Hz'];
                    
                    if time_list(t) == 0
                        tme_out = 'zero';
                    elseif time_list(t) < 0
                        tme_out = ['m' num2str(abs(time_list(t)*1000))];
                    else
                        tme_out = ['p' num2str(abs(time_list(t)*1000))];
                    end
                    
                    chn_out = template.label(chn);
                    chn_out = chn_out{:};
                    
                    suj_out = ['yc' num2str(sb)];
                    
                    cnd_list = {'RCue','LCue','NCue'};
                    
                    cnd_out = cnd_list{cnd};
                    
                    fprintf(fid,'%4s\t%4s\t%7s\t%5s\t%5s\t%.4f\n',suj_out,cnd_out,chn_out,frq_out,tme_out,avg);
                    
                end
                
            end
            
        end
        
    end
    
end

fclose(fid);