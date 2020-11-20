clear ; clc ; close all ;

load ../data/yctot/ArsenalGavg.mat

tm_list  = -0.7:0.1:1.2;

chn_list = {'Occ','HG','STG'};
frq_list = {'low','high'};

for f = 1
    for b_chn = 2:3
        
        figure;
        
        chn_fac = [1 2; 3 4; 5 6];
        
        for cnd = 1:3
            
            subplot(3,1,cnd);
            
            for bc = 1:2
                
                Y = [];
                
                for sb = 1:14
                    avg = source_avg{sb,cnd,chn_fac(b_chn,bc)}(f,:);
                    Y   =   [Y; avg];
                end
                
                dataME(bc,cnd,:) = nanmean(Y,1);
                
            end
            
            hold on
            
            cmap = 'br';
            
            cnds = 'RLN';
            
            for bi = 1:2
                X = tm_list;
                Y = squeeze(dataME(bi,cnd,:));
                plot(X,Y,cmap(bi));
                xlim([-0.7 1.2]);
                ylim([-0.3 0.1]);
                title([cnds(cnd) 'CnD']);
            end
            
        end
        
    end
end