for sb = 1:21
    
    suj         = ['yc' num2str(sb)];
    lst_cnd     = {'NLCnD','NRCnD','LCnD','RCnD'};
    
    
    fname_old   = ['../data/new_rama_data/' suj '.*.NewRama3Cov.*PAC.mat'];
    fname_new   = ['/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/field/.'];
    
    system(['cp ' fname_old ' ' fname_new]);
    
end