clear ; clc ;

for sb = 1:14
    
    for cnd_freq = {'13t15'};
        
        for cnd_filt = {'pcc.Fixed'};
            
            suj_list = [1:4 8:17];
            suj      = ['yc' num2str(suj_list(sb))];
            
            for pt = 1:3
                
                fname_filt_in = [suj '.pt' num2str(pt) '.CnD.4KT.' cnd_freq{:} 'Hz.commonFilter.' cnd_filt{:}];
                fprintf('Loading %50s \n',fname_filt_in);
                load(['../data/' suj '/filter/' fname_filt_in '.mat'])
                
                filt_carr{pt} = com_filter ; clear com_filter
                
            end
            
            for n = 1:length(filt_carr{1})
                cnct            = cat(3,filt_carr{1}{n},filt_carr{2}{n},filt_carr{3}{n});
                com_filter{n,1} = mean(cnct,3);
                clear cnct
            end
            
            clear n filt_carr
            
            fprintf('Saving.. \n');
            
            fname_filt_out = [suj '.CnD.4KT.' cnd_freq{:} 'Hz.commonFilter.' cnd_filt{:} 'Avg'];
            
            save(['../data/' suj '/filter/' fname_filt_out '.mat'],'com_filter')
            
            clear com_filter
            
        end
        
    end
    
end