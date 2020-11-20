clear ; clc ;

for sb = 1:14
    
    cnd_list = {'RCnD','LCnD','NCnD','VCnD'};
    
    for cnd = 1:length(cnd_list)
        
        suj_list = [1:4 8:17];
        
        suj = ['yc' num2str(suj_list(sb))];
        
        ext_essai   = 'postConn';
        fname_in    = ['../data/' suj '/pe/' suj '.' cnd_list{cnd} '.' ext_essai '.TimeCourse.mat'];
        fprintf('Loading %50s\n',fname_in);
        load(fname_in);
        
        frontal = virtsens ; clear virtsens ;
        
        cfg         = [];
        cfg.channel = [1:6 19 25 26];
        frontal    = ft_selectdata(cfg,frontal);
        
        
        for prt = 1:3
            
            suj_list = [1:4 8:17];
            
            suj = ['yc' num2str(suj_list(sb))];
            
            ext_essai   = 'Motor';
            fname_in    = ['../data/' suj '/pe/' suj '.pt' num2str(prt) '.' cnd_list{cnd} '.' ext_essai '.TimeCourse.mat'];
            fprintf('Loading %50s\n',fname_in);
            load(fname_in);
            
            data{prt} = virtsens ;
            
            clear virtsens
            
        end
        
        virtsens = ft_appenddata([],data{:}) ; clear data ;
        virtsens = ft_appenddata([],virtsens,frontal);
        
        
        ix_t = 0 ;
        
        for t_point = [-0.6 0.1 0.6]
            
            ix_t = ix_t + 1;
            
            cfg                 = [];
            cfg.toilim          = [t_point t_point+0.5];
            poi                 = ft_redefinetrial(cfg, virtsens);
            
            cfg                 = [];
            cfg.output          = 'fourier';
            cfg.method          = 'mtmfft';
            cfg.foilim          = [5 15];
            cfg.tapsmofrq       = 2;
            cfg.keeptrials      = 'yes';
            freq                = ft_freqanalysis(cfg, poi);
            
            cfg                                 = [];
            cfg.method                          = 'plv';
            coh_measures{sb,cnd,ix_t,1}         = ft_connectivityanalysis(cfg, freq);
            x                                   = coh_measures{sb,cnd,ix_t,1}.plvspctrm;
            coh_measures{sb,cnd,ix_t,1}.plvspctrm = .5.*log((1+x)./(x));
            coh_measures{sb,cnd,ix_t,1}         = rmfield(coh_measures{sb,cnd,ix_t,1},'cfg');
            
            %             cfg.method                          = 'coh';
            %             cfg.complex                         = 'absimag';
            %             coh_measures{sb,cnd,ix_t,2}         = ft_connectivityanalysis(cfg, freq);
            %             coh_measures{sb,cnd,ix_t,2}         = rmfield(coh_measures{sb,cnd,ix_t,2},'cfg');
            
            clear poi freq
            
        end
        
        clear virtsens
        
    end
    
end

clearvars -except coh_measures

% ttest

ii = 0 ;

for chan1 = 1:length(coh_measures{1,1,1}.label)
    for chan2 = 1:length(coh_measures{1,1}.label)
        if chan1 ~= chan2
            ii = ii + 1;
            tmp = [chan1 chan2];
            tmp = sort(tmp);
            chn_list{ii} =[num2str(tmp(1)) '.' num2str(tmp(2))];
            clear tmp
        end
    end
end

chn_list = unique(chn_list);

chan1_list = [];
chan2_list = [];


for ii = 1:length(chn_list)
    
    dotdot = strfind(chn_list{ii},'.');
    
    chan1_list(end+1) = str2num(chn_list{ii}(1:dotdot-1));
    chan2_list(end+1) = str2num(chn_list{ii}(dotdot+1:end));
    
end

clearvars -except coh_measures chn_list chan*

ntest_tot = 0 ;

for ix_coh = 1:2
    for ix_t   = 2:3
        for frq = 1:length(coh_measures{1,1,1}.freq)
            for c_c = 1:length(chan1_list)
                ntest_tot = ntest_tot + 1;
            end
        end
    end
end

clearvars -except coh_measures chn_list chan* ntest_tot

ntest = 0 ;
p_bag = 0 ;

for ix_coh = 1:2
    
    for ix_t   = 2:3
        
        tmp = coh_measures{1,1,ix_coh};
        
        tres{ix_coh,ix_t-1} =  tmp;
        
        if ix_coh==1
            tres{ix_coh,ix_t-1}.plvspctrm = repmat(100,size(tmp.plvspctrm,1),size(tmp.plvspctrm,2),size(tmp.plvspctrm,3));
        else
            tres{ix_coh,ix_t-1}.cohspctrm = repmat(100,size(tmp.cohspctrm,1),size(tmp.cohspctrm,2),size(tmp.cohspctrm,3));
        end
        
        for frq = 1:length(coh_measures{1,1,1}.freq)
            
            for c_c = 1:length(chan1_list)
                
                for sb = 1:size(coh_measures,1)
                    
                    if ix_coh > 1
                        x(sb) = coh_measures{sb,ix_t,ix_coh}.cohspctrm(chan1_list(c_c),chan2_list(c_c),frq) ;
                        y(sb) = coh_measures{sb,1,ix_coh}.cohspctrm(chan1_list(c_c),chan2_list(c_c),frq) ;
                    else
                        x(sb) = coh_measures{sb,ix_t,ix_coh}.plvspctrm(chan1_list(c_c),chan2_list(c_c),frq) ;
                        y(sb) = coh_measures{sb,1,ix_coh}.plvspctrm(chan1_list(c_c),chan2_list(c_c),frq) ;
                    end
                    
                end
                
                %                 [h,p] = ttest(x,y);
                
                p           = permutation_test([x' y'],1000);
                
                direction = (nanmean(x) - nanmean(y));
                
                if direction < 0
                    p = p * -1 ;
                end
                
                ntest       = ntest + 1;
                
                p_bag(ntest) = p ;
                
                fprintf('Computing test %6d out of %6d\n',ntest,ntest_tot);
                
                if ix_coh==1
                    tres{ix_coh,ix_t-1}.plvspctrm(chan1_list(c_c),chan2_list(c_c),frq) = p ;
                else
                    tres{ix_coh,ix_t-1}.cohspctrm(chan1_list(c_c),chan2_list(c_c),frq) = p ;
                end
                
                
            end
            
        end
        
    end
    
end

clearvars -except tres coh_measures

% meas_list = {'plv','coherence','coherency'};
% time_list = {'early','late'};
% chan_list = tres{1,1}.label ;
% freq_list = round(tres{1,1}.freq);
%
% ix_s = 0 ;
%
% for ix_coh = 1:3
%     for ix_t = 1:2
%
%         for frq = 1:length(tres{1,1,1}.freq)
%
%             for chan1 = 1:length(tres{1,1,1}.label)
%
%                 for chan2 = 1:length(tres{1,1}.label)
%
%                     if ix_coh >1
%                         p           = tres{ix_coh,ix_t}.cohspctrm(chan1,chan2,frq);
%                         abs_p       = abs(p);
%                     else
%                         p         = tres{ix_coh,ix_t}.plvspctrm(chan1,chan2,frq);
%                         abs_p       = abs(p);
%                     end
%
%                     if abs_p < 0.0011 && abs_p > 0
%
%                         ix_s = ix_s + 1;
%
%                         Summary(ix_s).measure   = meas_list{ix_coh};
%                         Summary(ix_s).freq      = freq_list(frq);
%                         Summary(ix_s).time      = time_list(ix_t);
%                         Summary(ix_s).chan1     = chan_list{chan1};
%                         Summary(ix_s).chan2     = chan_list{chan2};
%                         Summary(ix_s).p         = abs_p ;
%
%                         if p < 1
%                             Summary(ix_s).direction = '+ve';
%                         else
%                             Summary(ix_s).direction = '-ve';
%                         end
%
%                     end
%
%                 end
%             end
%         end
%     end
% end
%
% clearvars -except tres coh_measures Summary