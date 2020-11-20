function h_timingcheck(dsFileName)

figure;
events          = ft_read_event(dsFileName);
name_list       = {'cue1grat','cue2grat','gratmask'}; 

trigList{1}     = [11 12 13];
trigList{2}     = [111   112   113   114 121   122   123   124];

trigList{3}     = [11 12 13]+10;
trigList{4}     = [111   112   113   114 121   122   123   124]+100;

trigList{5}     = [111   112   113   114 121   122   123   124 211   212   213   214 221   222   223   224];
trigList{6}     = 200;

ix              = 0;

for find1 = [1 3 5]
    
    ix                              = ix +1 ;
    
    find2                           = find1+1;
    ntrial                          = 0;
    
    timingList                      = [];
    
    for n = 1:length(events)
        
        if strcmp(events(n).type,'UPPT001')
            
            % look for first cue
            trghunt                     = find(trigList{find1}==events(n).value);
            
            if ~isempty(trghunt)
                
                ntrial                  = ntrial+1;
                
                flg1                    = 0;
                hnt1                    = 1;
                
                timingList(ntrial,1)    = events(n).sample;
                
                while flg1 == 0
                    
                    if n+hnt1 <= length(events)
                        if strcmp(events(n+hnt1).type,'UPPT001')
                            
                            % look for target
                            trghunt     = find(trigList{find2}==events(n+hnt1).value);
                            
                            if isempty(trghunt)
                                hnt1    = hnt1+1;
                            else
                                timingList(ntrial,2)    = events(n+hnt1).sample;
                                timingList(ntrial,3)    = ((timingList(ntrial,2)-timingList(ntrial,1))*1000)/1200;
                                flg1                    = 1;
                            end
                        else
                            hnt1        = hnt1+1;
                        end
                    end
                end
                %                 end
            end
        end
    end
    
    plot_vct                                = timingList(:,3); % (timingList(:,3)/1000);
    avg_nb                                  = round(median(plot_vct),4);
    
    subplot(2,2,ix)
    plot(plot_vct);
    title([name_list{ix} ' avg = ' num2str(avg_nb)]);
    xlim([0 length(plot_vct)]);
    
    ylim([avg_nb-10 avg_nb+10]);

    grid on
    
    clear plot_vct;
    
end