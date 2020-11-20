clear ; clc ;dleiftrip_addpath;

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    for cndcnd = 1:2
        
        ext_cnd         = {{'DIS1','DIS2','DIS3'},{'fDIS1','fDIS2','fDIS3'}};
        
        mega_ext_cnd    = {'DIS','fDIS'};
        
        for prt = 1:3
            
            for cnd = 1:3
                
                suj = ['yc' num2str(suj_list(sb))] ;
                
                fname_in = [suj '.pt' num2str(prt) '.' ext_cnd{cndcnd}{cnd}];
                
                fprintf('\nLoading %50s\n',fname_in);
                load(['../data/' suj '/elan/' fname_in '.mat'])
                
                data{cnd} = data_elan ;
                
                clear data_elan
                
            end
            
            data_elan = ft_appenddata([],data{:,:});
            
            fname_out = [suj '.pt' num2str(prt) '.' mega_ext_cnd{cndcnd} '.mat'];
            
            fprintf('\nSaving %50s\n',fname_out);
            
            save(['../data/' suj '/elan/' fname_out],'data_elan','-v7.3')
            
            clear data_elan
            
        end
        
    end
    
end