clear ; clc ;

ix_f = 0 ;

for ext_freq = {'8t10Hz'} % {'8t10Hz','12t14Hz'};
    
    ix_f = ix_f + 1;
    
    load ../data/template/source_struct_template_MNIpos.mat
    indx_tot = h_createIndexfieldtrip(source); clear source ;
    
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
        
        for roi = 1:length(unique(indx_tot(:,2)))
        
            for cnd = 1:2
                
                indx = indx_tot(indx_tot(:,2)==roi,1);
                
                avg         = nanmean(sourceAppend{cnd}(indx,:),1)';
                
                [rho,p]     = corr(avg,rt_all{sb} , 'type', 'Spearman');
                
                isig        = find(p>0.05 & ~isnan(p));
                
                rho(isig)   = 0 ;
                
                rhoF        = .5.*log((1+rho)./(1-rho));
                
                %                 nrepl       = size(sourceAppend{cnd},2);
                %                 tstatF      = rhoF*(sqrt(nrepl-2))./sqrt((1-rhoF.^2));
                %                 tstat       = rho*(sqrt(nrepl-2))./sqrt((1-rho.^2));
                
                source_avg{sb,ix_f,roi,cnd} = rhoF ;
                
            end
            
        end
        
    end
    
end

atlas = ft_read_atlas('../fieldtrip-20151124/template/atlas/aal/ROI_MNI_V4.nii'); clc ;
clear summary ; ix = 0 ; cnd_freq = {'low','high'};

for f = 1:size(source_avg,2)
    
    for n = 1:size(source_avg,3)
        
        X = [source_avg{:,f,n,2}];
        Y = [source_avg{:,f,n,1}];
        
        t = X(isnan(X));
        
        if isempty(t)
            
            [h,p] = ttest(X',Y','alpha',0.05,'tail','both');
            
            if p < 0.05
                
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