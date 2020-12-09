function [hdr,events] = taco_fun_checktiming(dsFileName)

figure;
events          = ft_read_event(dsFileName);
hdr             = ft_read_header(dsFileName,'headerformat','ctf_old');

name_list       = {'cue1samp1' 'samp1samp2' 'samp2cue2' 'cue2probe' 'probe2map' 'localizerISI'}; 

trigList{1}     = [111   112   121   122];
trigList{2}     = [11    12];

trigList{3}     = trigList{2};
trigList{4}     = [21    22];

trigList{5}     = trigList{4};
trigList{6}     = [211   212   221   222];

trigList{7}     = trigList{6};
trigList{8}     = [31    32];

trigList{9}     = trigList{8};
trigList{10}  	= 77;

ix              = 0;

for find1 = [1 3 5 7 9]
    
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
                                timingList(ntrial,3)    = ((timingList(ntrial,2)-timingList(ntrial,1))*1000)/hdr.Fs;
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
    
    subplot(3,2,ix)
    plot(plot_vct);
    title([name_list{ix} ' avg = ' num2str(avg_nb)]);
    
    bloc_length = 32;
    nb_block    = 8;
    for nbloc = bloc_length:bloc_length:(nb_block-1)*bloc_length
        vline(nbloc,'--r');
    end
    
    xlim([0 length(plot_vct)]);
    grid on
    
    if find1 ~= 7
        ylim([avg_nb-10 avg_nb+10]);
    end
    clear plot_vct;
    
end

ix                      = ix +1;
loca_triggers           = [71 72 73 74 75];
loca_samples            = [];

for n = 1:length(events)
    if strcmp(events(n).type,'UPPT001')
        if ismember(events(n).value,loca_triggers)
           loca_samples = [loca_samples;events(n).sample];
        end
    end
end

plot_vct                = diff(loca_samples) ./ hdr.Fs;
avg_nb              	= round(median(plot_vct),4);
subplot(3,2,ix)
plot(plot_vct);
ylim([avg_nb-0.2 avg_nb+0.2]);
title([name_list{ix} ' avg = ' num2str(avg_nb)]);

% gca                    = figure('Position', get(0, 'Screensize'));
% F                       = getframe(gca);
% imwrite(F.cdata, 'Foos.png', 'png');