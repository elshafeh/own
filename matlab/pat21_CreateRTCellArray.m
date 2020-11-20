clear ; clc ;

suj_list = [1:4 8:17];

for sb = 1:14
    
    suj = ['yc' num2str(suj_list(sb))] ;
    
    posIN = load(['../pos/' suj '.pat2.fin.pos']);
    
    posIN        =   posIN(posIN(:,3)==0,:);
    posIN        =   posIN(floor(posIN(:,2)/1000)~=6,1:2);
    posIN(:,3)   =   posIN(:,2) - ((floor(posIN(:,2)/1000))*1000);
    posIN(:,4)   =   floor(posIN(:,3)/100);
    posIN(:,5)   =   floor((posIN(:,3)-100*posIN(:,4))/10);
    posIN        =   posIN(posIN(:,5) ==0,:);
    
    rt_suj = [];
    
    for pt = 1:3
        
        rt_pt = [];
        
        fname_in = [suj '.pt' num2str(pt) '.CnD'];
        fprintf('Loading %50s\n',fname_in);
        load(['../data/' suj '/elan/' fname_in '.mat'])
        
        for n = 1:length(data_elan.sampleinfo)
           
            flag_trl = data_elan.sampleinfo(n,1) + 600*4;
            flag_pos = find(posIN(:,1)==flag_trl);
            
            tar_pos = flag_pos+1;
            rep_pos = flag_pos+2;
            
            if isempty(flag_pos) || floor(posIN(tar_pos,2)/1000) ~= 3 || floor(posIN(rep_pos,2)/1000)~= 9
                fprintf('Error with %s part %d trial %3d\n',suj,pt,n);
            else
                rt_trial = posIN(rep_pos,1) - posIN(tar_pos,1) ;
                rt_trial = rt_trial * 5/3 ;
                rt_pt = [rt_pt;rt_trial];
                
                clear rt_trial flag_trl flag_pos
                
            end
            
        end
        
        rt_suj = [rt_suj;rt_pt];
        
    end
    
    rt_all{sb} = rt_suj ;
    
    clear rt_suj
    
end