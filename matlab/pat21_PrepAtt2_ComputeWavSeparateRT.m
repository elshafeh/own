clear ; clc ;

suj_list = [1:4 8:17];

for a = 1:14
    
    sub_carr = [];
    
    suj                     = ['yc' num2str(suj_list(a))];
    behav_in_recoded        = load(['../pos/' suj '.pat2.fin.pos']);
    behav_in_recoded        = behav_in_recoded(behav_in_recoded(:,3) == 0,:);
    
    for n = 1:length(behav_in_recoded)
        
        if  floor(behav_in_recoded(n,2)/1000)==1
            
            code    =   behav_in_recoded(n,2)-1000;
            CUE     =   floor(code/100);
            DIS     =   floor((code-100*CUE)/10);
            
            if DIS == 0 && CUE ~= 0
                
                fcue=1; p=1;
                
                while fcue==1 && n+p <=length(behav_in_recoded)
                    if floor(behav_in_recoded(n+p,2)/1000)~=1
                        p=p+1;
                    else
                        fcue=2;
                    end
                end
                
                p=p-1;
                
                trl=behav_in_recoded(n:n+p,:);
                
                cuetmp  = find(floor(trl(:,2)/1000)==1);
                tartmp  = find(floor(trl(:,2)/1000)==3);
                reptmp  = find(floor(trl(:,2)/1000)==9);
                RT      = (trl(reptmp(1),1)-trl(tartmp,1)) * 5/3;
                
                sub_carr =  [sub_carr; trl(cuetmp(1),1)-(600*4)  RT];
                
            end
            
        end
        
    end
    
    mdn_rt = median(sub_carr(:,2));
    
    allsuj_rt{a,1} = sub_carr;
    allsuj_rt{a,2} = mdn_rt;
    
    clearvars -except a suj_list allsuj_rt
    
end

lmt = median([allsuj_rt{:,2}]);

for a = 1:14
    
    if allsuj_rt{a,2} < lmt
        
        allsuj_rt{a,3} = 1;
    else
        allsuj_rt{a,3} = 2;
        
    end
end

clear a suj_list lmt

% clear a suj_list
%
% for a = 1:14
%
%     if allsuj{a,2} < median([allsuj{:,2}])
%         allsuj{a,3} = 1;
%     elseif allsuj{a,2} > median([allsuj{:,2}])
%         allsuj{a,3} = 2;
%     end
% end
%
% clear a
%
% save('../data/yctot/median_SubClassify.mat')

% % for a = 1:length(suj_list)
% %
% %     for b =1:3
% %
% %         suj = ['yc' num2str(suj_list(a))] ;
% %         fname_in = [suj '.pt' num2str(b) '.VCnD'];
% %         fprintf('\nLoading %50s\n',fname_in);
% %         load(['../data/' suj '/elan/' fname_in '.mat'])
% %         data{b} = data_elan;
% %         clear data_elan
% %
% %     end
% %
% %     clear b
% %     data_f = ft_appenddata([],data{:,:});
% %     clear data
% %
% %     for b = 1:2
% %
% %         trl_list = find(allsuj_sampleinfo{a,1}(:,2) == b);
% %
% %         cfg                 = [];
% %         cfg.toi             = -4:0.05:4;
% %         cfg.method          = 'wavelet';
% %         cfg.output          = 'pow';
% %         cfg.foi             =  5:1:18;
% %         cfg.trials          = trl_list;
% %         cfg.width           =  7 ;
% %         cfg.gwidth          =  4 ;
% %         allsujfreq{a,b}     = ft_freqanalysis(cfg,data_f);
% %
% %         clear cfg trl_list
% %
% %     end
% %
% %     clear data_f b
% %
% % end
%
% clearvars -except allsujfreq
%
% % load ../data/yctot/median_perSub_inf_sInfo.mat
% % load ../data/yctot/median_perSub_inf_rt.mat
% %
% % for a = 1:14
% %
% %     allsuj_sampleinfo{a,1}(:,2) = 0;
% %
% %     for n = 1:length(allsuj_sampleinfo{a,1})
% %
% %         idx = find(allsuj{a,1}(:,1) == allsuj_sampleinfo{a,1}(n,1));
% %         allsuj_sampleinfo{a,1}(n,2) = allsuj{a,1}(idx,3);
% %
% %         clear idx
% %
% %     end
% %
% %     clear n
% %
% % end
%
% % clear a
%
% % save('../data/yctot/median_perSub_inf_combo.mat')
%
%
% % suj_list = [1:4 8:17];
%
% % for a = 1:length(suj_list)
% %
% %     allsuj_sampleinfo{a,1} = [];
% %     suj                     = ['yc' num2str(suj_list(a))];
% %
% %     for b = 1:3
% %
% %         suj = ['yc' num2str(suj_list(a))] ;
% %
% %         fname_in = [suj '.pt' num2str(b) '.VCnD'];
% %         fprintf('\nLoading %50s\n',fname_in);
% %         load(['../data/' suj '/elan/' fname_in '.mat'])
% %
% %         allsuj_sampleinfo{a,1} = [allsuj_sampleinfo{a,1}; data_elan.sampleinfo(:,1)];
% %
% %         clear data_elan fname_in
% %
% %     end
% %
% %     clear suj
% %
% % % end
% %
% % % clear a suj_list

% for a = 1:14
%     
%     sub_carr = [];
%     
%     suj                     = ['yc' num2str(suj_list(a))];
%     behav_in_recoded        = load(['../pos/' suj '.pat2.fin.pos']);
%     behav_in_recoded        = behav_in_recoded(behav_in_recoded(:,3) == 0,:);
%     
%     for n = 1:length(behav_in_recoded)
%         
%         if  floor(behav_in_recoded(n,2)/1000)==1
%             
%             code    =   behav_in_recoded(n,2)-1000;
%             CUE     =   floor(code/100);
%             DIS     =   floor((code-100*CUE)/10);
%             
%             if DIS == 0
%                 
%                 fcue=1; p=1;
%                 
%                 while fcue==1 && n+p <=length(behav_in_recoded)
%                     if floor(behav_in_recoded(n+p,2)/1000)~=1
%                         p=p+1;
%                     else
%                         fcue=2;
%                     end
%                 end
%                 
%                 p=p-1;
%                 
%                 trl=behav_in_recoded(n:n+p,:);
%                 
%                 cuetmp  = find(floor(trl(:,2)/1000)==1);
%                 tartmp  = find(floor(trl(:,2)/1000)==3);
%                 reptmp  = find(floor(trl(:,2)/1000)==9);
%                 RT      = (trl(reptmp(1),1)-trl(tartmp,1)) * 5/3;
%                 
%                 sub_carr =  [sub_carr; trl(cuetmp(1),1)-(600*4)  RT 0];
%                 
%             end
%             
%         end
%         
%     end
%     
%     mdn_rt = median(sub_carr(:,2));
%     
%     %     sub_carr(sub_carr(:,2) < mdn_rt,3) = 1;
%     %     sub_carr(sub_carr(:,2) > mdn_rt,3) = 2;
%     %
%     %     allsuj{a,1} = sub_carr;
%     allsuj_rt{a,1} = mdn_rt;
%     
%     clearvars -except a suj_list allsuj_rt
%     
% end

% % clear a suj_list
% %
% % save('../data/yctot/median_perSub_inf_rt.mat')
%
% % load('../data/yctot/allsuj_sampleinfo_rt_summary.mat')
% %
% % ntrl_chk = zeros(14,2);
% %
% % for a = 1:14
% %
% %     for b = 1:2
% %
% %         trl_list = find(allsuj_sampleinfo{a,1}(:,2) == b);
% %         ntrl_chk(a,b) = length(trl_list);
% %         clear trl_list
% %     end
% %
% %     clear b
% %
% % end
%
% % for a = 1:length(suj_list)
% %
% %         for b =1:3
% %
% %             suj = ['yc' num2str(suj_list(a))] ;
% %
% %             fname_in = [suj '.pt' num2str(b) '.CnD'];
% %             fprintf('\nLoading %50s\n',fname_in);
% %             load(['../data/' suj '/elan/' fname_in '.mat'])
% %
% %             data{b} = data_elan;
% %
% %             clear data_elan
% %
% %         end
% %
% %         clear b
% %
% %         data_f = ft_appenddata([],data{:,:});
% %
% %         clear data
% %
% %         for b = 1:2
% %
% %             trl_list = find(allsuj_sampleinfo{a,1}(:,2) == b);
% %
% %             cfg                 = [];
% %             cfg.toi             = -4:0.05:4;
% %             cfg.method          = 'wavelet';
% %             cfg.output          = 'pow';
% %             cfg.foi             =  5:1:18;
% %             cfg.trials          = trl_list;
% %             cfg.width           =  7 ;
% %             cfg.gwidth          =  4 ;
% %             allsujfreq{a,b}     = ft_freqanalysis(cfg,data_f);
% %
% %             clear cfg trl_list
% %
% %         end
% %
% %         clear data_f b
% %
% % end
%
% % load('../data/yctot/allsuj_rt_summary.mat')
% % load('../data/yctot/allsuj_sampleinfo_summary.mat')
% %
% % allsuj{4,1}(529:end,:)  = [];
% % allsuj{4,2}             = median(allsuj{4,1}(:,2));
% % allsuj{4,1}(:,3)        = 0;
% %
% % allsuj{4,1}(allsuj{4,1}(:,2) < allsuj{4,2},3) = 1;
% % allsuj{4,1}(allsuj{4,1}(:,2) > allsuj{4,2},3) = 2;
% %
% % for a = 1:14
% %
% %     allsuj_sampleinfo{a,1}(:,2) = 0;
% %
% %     for n = 1:length(allsuj_sampleinfo{a,1})
% %
% %         idx = find(allsuj{a,1}(:,1) == allsuj_sampleinfo{a,1}(n,1));
% %         allsuj_sampleinfo{a,1}(n,2) = allsuj{a,1}(idx,3);
% %
% %         clear idx
% %
% %     end
% %
% %     clear n
% %
% % end
%
% % suj_list = [1:4 8:17];
%
% % for a = 1:length(suj_list)
% %
% %     allsuj_sampleinfo{a,1} = [];
% %
% %     suj                     = ['yc' num2str(suj_list(a))];
% %
% %     for b = 1:3
% %
% %         suj = ['yc' num2str(suj_list(a))] ;
% %
% %         fname_in = [suj '.pt' num2str(b) '.CnD'];
% %         fprintf('\nLoading %50s\n',fname_in);
% %         load(['../data/' suj '/elan/' fname_in '.mat'])
% %
% %         allsuj_sampleinfo{a,1} = [allsuj_sampleinfo{a,1}; data_elan.sampleinfo(:,1)];
% %
% %         clear data_elan
% %
% %     end
% %
% %     clear suj
% %
% % end
% %
% % for a = 4
% %
% %     sub_carr = [];
% %
% %     suj                     = ['yc' num2str(suj_list(a))];
% %     behav_in_recoded        = load(['/mnt/autofs/Aurelie/DATA/MEG/PAT_MEG/pat.meeg/data/' suj '/pos/' suj '.pat2.fin.pos']);
% %     behav_in_recoded        = behav_in_recoded(behav_in_recoded(:,3) == 0,:);
% %
% %     for n = 1:length(behav_in_recoded)
% %
% %         if  floor(behav_in_recoded(n,2)/1000)==1
% %
% %             code    =   behav_in_recoded(n,2)-1000;
% %             CUE     =   floor(code/100);
% %             DIS     =   floor((code-100*CUE)/10);
% %
% %             if DIS == 0
% %
% %                 fcue=1; p=1;
% %
% %                 while fcue==1 && n+p <=length(behav_in_recoded)
% %                     if floor(behav_in_recoded(n+p,2)/1000)~=1
% %                         p=p+1;
% %                     else
% %                         fcue=2;
% %                     end
% %                 end
% %
% %                 p=p-1;
% %
% %                 trl=behav_in_recoded(n:n+p,:);
% %
% %                 cuetmp  = find(floor(trl(:,2)/1000)==1);
% %                 tartmp  = find(floor(trl(:,2)/1000)==3);
% %                 reptmp  = find(floor(trl(:,2)/1000)==9);
% %                 RT      = (trl(reptmp(1),1)-trl(tartmp,1)) * 5/3;
% %
% %                 sub_carr =  [sub_carr; trl(cuetmp(1),1)-(600*4)  RT 0];
% %
% %             end
% %
% %         end
% %
% %     end
% %
% %     mdn_rt = median(sub_carr(:,2));
% %
% %     sub_carr(sub_carr(:,2) < mdn_rt,3) = 1;
% %     sub_carr(sub_carr(:,2) > mdn_rt,3) = 2;
% %
% %     allsuj{a,1} = sub_carr;
% %     allsuj{a,2} = mdn_rt;
% %
% %     clearvars -except a suj_list allsuj
% %
% % end