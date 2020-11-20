% Convert tres into matrix

clear ; clc ; close all ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    list_cond = {'RCnD','LCnD','NCnD'};
    suj = ['yc' num2str(suj_list(sb))] ;
    
    for cnd = 1:length(list_cond)
        
        for prt = 1:3
            
            fname_in = [suj '.pt' num2str(prt) '.' list_cond{cnd} '.tfResolved.5t15Hz.m700p2000ms.mat'];
            fprintf('Loading %50s \n',fname_in);
            load(['../data/' suj '/source/' fname_in])
            
            %         lm1 = find(round(tResolvedAvg.time,2) == -0.6);
            %         lm2 = find(round(tResolvedAvg.time,2) == -0.2);
            %
            %         bsl = mean(tResolvedAvg.pow(:,:,lm1:lm2),3);
            %
            %         load ../data/template/source_struct_template_MNIpos.mat
            %
            %         for t = 1:20
            %             tResolvedAvg.pow(:,:,t) = (tResolvedAvg.pow(:,:,t) - bsl) ./ bsl ;
            %         end
            
            carr{prt} = tResolvedAvg.pow;
            
            clear tResolvedAvg
            
        end
        
        source_avg{sb,cnd} = mean(cat(4,carr{:}),4);
        
        clear carr;
        
    end
    
end

clearvars -except source_avg ; clc ;

load ../data/yctot/index/PostCon&MotorIndx.mat    ;

roi_list = unique(indx_tot(:,2));

for sb = 1:14
    
    for cnd = 1:size(source_avg,2)
        
        for chn = 1:length(roi_list)
            
            ix  = find(indx_tot(:,2)==roi_list(chn));
            ix  = indx_tot(ix,1);
            avg = squeeze(nanmean(squeeze(source_avg{sb,cnd}(ix,:,:)),1));
            new_source_avg(sb,cnd,chn,:,:) = avg;
            
            clear avg ix;
            
        end
        
    end
    
end

clearvars -except new_source_avg; source_avg = new_source_avg ; clear new_source_avg

save('../data/yctot/TfRes4Anova.mat');