clear ; clc ; close all ;

load ../data/yctot/ArsenalGavg.mat

tm_list  = -0.7:0.1:1.2;

chn_list = {'Occ','HG','STG'};
frq_list = {'low','high'};

for f = 1
    
    for b_chn = 2:3
        
        figure;
        
        ix_t = 0 ;
        
        for t = 13:16;
            
            ix_t = ix_t + 1;
            
            chn_fac = [1 2; 3 4; 5 6];
            
            for cnd = 1:3
                
                for bc = 1:2
                    
                    Y = [];
                    
                    for sb = 1:14
                     
                        avg = squeeze(source_avg{sb,cnd,chn_fac(b_chn,bc)}(f,t));
                        
                        clear ix
                        
                        Y   =   [Y; nanmean(nanmean(avg))];
                    end
                    
                    dataME(bc,cnd) = nanmean(Y);
                    dataST(bc,cnd) = nanstd(Y);
                    dataSE(bc,cnd) = dataST(bc,cnd) / sqrt(14);
                    
                end
            end
            
            subplot(1,4,ix_t)
            hold on
            
            cmap = 'brg';
            
            for bi = 1:3
                %                 errorbar(dataME(bi,:),dataSE(bi,:),cmap(bi));
                errorbar(dataME(:,bi),dataSE(:,bi),cmap(bi));
                ylim([-0.3 0]);
            end
            
            legend({'RCnD','LCnD','NCnD'});
            %             legend({'LCx','RCx'});
            title([num2str((tm_list(t)*1000)) ' ' chn_list{b_chn} ' ' frq_list{f}])
            set(gca,'Xtick',0:1:3)
            %             set(gca,'Xtick',0:1:4)
            set(gca,'Xtick',0:4,'XTickLabel', {'','LCx','RCx'})
            %             set(gca,'Xtick',0:4,'XTickLabel', {'','RCnD','LCnD','NCnD'})
            
            clear dataME dataSE
            
        end
    end
end