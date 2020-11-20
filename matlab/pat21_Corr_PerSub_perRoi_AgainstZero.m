clear ; clc ;

ix_f = 0 ;

for ext_freq = {'8t10Hz','12t14Hz'};
    
    ix_f = ix_f + 1;
    
    load ../data/template/source_struct_template_MNIpos.mat
    indx_tot = h_createIndexfieldtrip(source); clear source ;
    
    %     load ../../../PAT_MEG/Fieldtripping/data/yctot/ArsenalIndex.mat;
    
    for sb = 1:14
        
        suj_list = [1:4 8:17];
        
        suj = ['yc' num2str(suj_list(sb))];
        
        sourceAppend{1} = [];
        sourceAppend{2} = [];
        
        list_time = {'m600m200','p600p1000'};
        
        for prt = 1:3
            
            for cnd = 1:2
                
                fname = dir(['../../../PAT_MEG/Fieldtripping/data/' suj '/source/' suj '*.pt' num2str(prt) ...
                    '*.CnD.KT.*' ext_freq{:} '*' list_time{cnd} ...
                    '.bsl.5mm.source.mat']);
                
                fname = fname.name;
                fprintf('Loading %50s\n',fname);
                load(['../../../PAT_MEG/Fieldtripping/data/' suj '/source/'  fname]);
                
                sourceAppend{cnd} = [ sourceAppend{cnd} source]; clear source ;
                
            end
            
            clear relchange sourc_carr
            
        end
        
        load ../data/yctot/rt_CnD_adapt.mat
        
        fprintf('Calculating Correlation\n');
        
        roi_lst = unique(indx_tot(:,2)) ;
        
        for roi = 1:length(roi_lst)
        
            for cnd = 1:2
                
                indx = indx_tot(indx_tot(:,2)==roi_lst(roi),1);
                
                avg         = nanmean(sourceAppend{cnd}(indx,:),1)';
                
                [rho,p]     = corr(avg,rt_all{sb} , 'type', 'Spearman');
                
                isig        = find(p>0.05 & ~isnan(p));
                rho(isig)   = 0 ;
                
                rhoF        = .5.*log((1+rho)./(1-rho));
                
                source_avg(sb,ix_f,roi,cnd) = rhoF ;
                
            end
            
        end
        
    end
    
end

new_source_avg = source_avg;

for f = 1:size(new_source_avg,2)
    for cnd = 1:size(new_source_avg,4)
        for roi = 1:size(new_source_avg,3)
            
            x = new_source_avg(:,f,roi,cnd);
            y = zeros(14,1);
            
            [h,p] = ttest(x,y,'alpha',0.05);
            
            if p > 0.05
                new_source_avg(:,f,roi,cnd) = 0 ;
            end
            
        end
    end
end

atlas = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii'); clc ;
clear summary ; ix = 0 ; cnd_freq = {'low','high'};

for f = 1:size(new_source_avg,2)
    
    for n = 1:size(new_source_avg,3)
        
        X = new_source_avg(:,f,n,2);
        Y = new_source_avg(:,f,n,1);
        
        t = X(isnan(X));
        
        if isempty(t)
            
            [h,p] = ttest(X',Y','alpha',0.05);
            
            if p < 1
                ix = ix + 1;
                
                summary(ix).roi     = atlas.tissuelabel{n};
                summary(ix).freq    = cnd_freq{f};
                summary(ix).rhoMEA  = mean(X)-mean(Y);
                summary(ix).rhoMED  = median(X)-median(Y);
                summary(ix).p       = p;
                
            end
            
        end
        
    end
end

summary = struct2table(summary);