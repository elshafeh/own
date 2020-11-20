clear ; clc ; close all;

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

for ngroup = 1:2
    
    suj_list = suj_group{ngroup};
    
    all_evnts = [];
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        ngrp                = 1;
        
        
        load(['../data/' suj '/res/' suj '_final_ds_list.mat']);
        
        for nbloc = 1:size(final_ds_list,1)
            
            fprintf('Handling %s\n',[suj ' b' num2str(nbloc)])
            
            pos_single                = load(['../data/' suj '/pos/' final_ds_list{nbloc,1} '.code.pos']);
            pos_single                = PrepAtt22_funk_pos_prepare(pos_single,sb,nbloc,ngrp);
            pos_single                = PrepAtt22_funk_pos_recode(pos_single);
            ncue                      = 0 ;
            
            for n = 1:length(pos_single)
                
                if  floor(pos_single(n,3)/1000)==1
                    
                    ncue = ncue + 1;
                    
                    if ncue > 1
                        
                        
                        wcue    = pos_single(n,4);
                        lm1     = wcue - 1200;
                        lm2     = wcue + 1200;
                        
                        trlbox      = pos_single(pos_single(:,4) >= lm1 & pos_single(:,4) <= lm2,4);
                        
                        sub_before  = trlbox(trlbox<wcue);
                        sub_after   = trlbox(trlbox>wcue);
                        
                        if ~isempty(sub_before)
                            for hiho = 1:length(sub_before)
                                stmp       = sub_before(hiho) - wcue;
                                stmp       = stmp * 5/3;
                                all_evnts = [all_evnts ; stmp floor(pos_single(pos_single(:,4)==sub_before(hiho),3)/1000)];
                                clear stmp
                            end
                        end
                        
                        clear hiho sub_before sub_after trlbox
                        
                        %                         if ~isempty(sub_after)
                        %                             for hiho = 1:length(sub_after)
                        %                                 stmp       = sub_after(hiho) - wcue;
                        %                                 stmp       = stmp * 5/3;
                        %                                 all_evnts = [all_evnts ; stmp];
                        %                                 clear stmp
                        %                             end
                        %                         end
                        
                    end
                    
                end
            end
            
            clear pos_single
            
        end
    end
    
    clearvars -except ngroup suj_group all_evnts

    subplot(2,1,ngroup);
    histogram(all_evnts(:,1),'BinWidth',10);ylim([0 10]);
    
end