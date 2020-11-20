clear ; clc ;

for cnd_freq = 1:3
    
    ext_freq = {'7t11Hz','11t15Hz','7t15Hz'};
    
    for sb = 1:14
        
        suj_list = [1:4 8:17];
        
        suj = ['yc' num2str(suj_list(sb))];
        
        frq_ext  = '7t15Hz';
        
        sourceAppend{1} = [];   % before
        sourceAppend{2} = [];   % after
        sourceAppend{3} = [] ;  % non-corrected
        
        tmp{1} = [];
        tmp{2} = [];
        
        for prt = 1:3
            for cnd_time = 1:2
                
                list_time   = {{'m600m200','p700p1100'},{'m600m200','p700p1100'},{'m600m400','p900p1100'}} ;
                filt_ext    = 'SingleTrial.NewDpss';
                
                fname = dir(['../data/source/' suj '.pt' num2str(prt) ...
                    '.CnD.' frq_ext '.' list_time{cnd_freq}{cnd_time} ...
                    '.' filt_ext '.mat']);
                
                fname = fname.name;
                
                fprintf('Loading %50s\n',fname);
                
                load(['../data/source/' fname]);
                
                source_carr{cnd_time} = source ;
                
                tmp{cnd_time} = [tmp{cnd_time} source] ;
                
                if cnd_time == 2
                    sourceAppend{3} = [sourceAppend{3} source];
                end
                
                clear source ;
                
            end
            
            sourceAppend{1} = [sourceAppend{1} (source_carr{2}-source_carr{1})./source_carr{1}];
            
            clear source_carr
            
        end
        
        sourceAppend{2} = (tmp{2} - tmp{1}) ./ tmp{1} ;
        
        clear tmp
        
        for cnd_bsl = 1:3
            
            load ../data/yctot/rt/rt_CnD_adapt.mat
            
            fprintf('Calculating Correlation\n');
            
            [rho,p]                             = corr(sourceAppend{cnd_bsl}',rt_all{sb} , 'type', 'Spearman');
            rhoF                                = .5.*log((1+rho)./(1-rho));
            
            source_avg{sb,cnd_bsl,1}.pow                   = rhoF;             % act
            source_avg{sb,cnd_bsl,2}.pow(length(rho),1)    = 0;                % bsl
            
            clear rho rhoF
            
            fprintf('Done\n');
            
            load ../data/template/source_struct_template_MNIpos.mat
            
            for cnd_rho = 1:2
                source_avg{sb,cnd_bsl,cnd_rho}.pos    = source.pos;
                source_avg{sb,cnd_bsl,cnd_rho}.dim    = source.dim;
            end
            
            clear source
            
        end
        
        clear sourceAppend
        
    end
end