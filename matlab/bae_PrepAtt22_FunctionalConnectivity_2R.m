clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);
suj_list            = suj_group{1};

clearvars -except *suj_list ;

for sb = 1:length(suj_list)
    
    suj                 = suj_list{sb};
    cond_main           = 'CnD';
    list_ix_cond        = {'R','L','NR','NL'};
    
    for ntest = 1:length(list_ix_cond)
        
        fname_in               = ['../data/' suj '/field/' suj '.' list_ix_cond{ntest} cond_main '.7t15Hz.m800p1200ms.Aud2All.plv.mat'];
        fprintf('\nLoading %50s \n\n',fname_in);
        load(fname_in)
        
        list_ix_bsl     = {'noBSL','absBSL','relBSL'};
        
        for nbsl = 1:3
            
            if nbsl ==1
                
                new_plv=freq_plv;
                
            else
                
                cfg                         = [];
                cfg.baseline                = [-0.6 -0.2];
                
                if nbsl == 2
                    cfg.baselinetype            = 'absolute';
                else
                    cfg.baselinetype            = 'relchange';
                end
                
                new_plv                    = ft_freqbaseline(cfg,freq_plv);
            end
            
            i = 0 ;
            
            for nchan = 1:length(new_plv.label)
                
                if strcmp(new_plv.label{nchan}(1:4),'audR') || nchan == 1
                    
                    i = i + 1 ;
                    allsuj_GA{sb,ntest,i,nbsl}            = new_plv;
                    allsuj_GA{sb,ntest,i,nbsl}.powspctrm  = new_plv.powspctrm(nchan,:,:);
                    allsuj_GA{sb,ntest,i,nbsl}.label      = {[new_plv.label{nchan} ' ' list_ix_bsl{nbsl}]};
                    
                end
            end
            
            clear new_plv
            
        end
    end
end

clearvars -except allsuj_* ; clc ;

for nbsl = 1:size(allsuj_GA,4)
    
    list_ix_bsl     = {'noBSL','absBSL','relBSL'};
    
    fOUT            = ['../documents/4R/Allyoung.RamaVirtual.AudRPLV.' list_ix_bsl{nbsl} '.txt'];
    fid             = fopen(fOUT,'W+');
    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\n','SUB','CUE','CHAN','FREQ','TIME','PLV','CUE_CAT');
    
    for sb = 1:size(allsuj_GA,1)
        for ncue = 1:size(allsuj_GA,2)
            
            for nchan = 1:size(allsuj_GA,3)
                
                frq_list = [7 7; 8 8; 9 9; 10 10; 11 11];
                tim_wind = 0.1;
                tim_list = 0.6:tim_wind:1;
                
                for nfreq = 1:size(frq_list,1)
                    for ntime = 1:length(tim_list)
                        
                        flg      = allsuj_GA{sb,ncue,nchan,nbsl};
                        
                        ls_cue   = {'R','L','R','L'};
                        ls_chan  = flg.label{:};
                        
                        wh_space = strfind(ls_chan,' ');
                        
                        ls_chan(wh_space) = '_';
                        
                        ls_time  = [num2str(tim_list(ntime)*1000) 'ms'];
                        ls_freq  = [num2str(mean(frq_list(nfreq,:))) 'Hz'];
                        
                        x1       = find(round(flg.time,2)== round(tim_list(ntime),2));
                        x2       = find(round(flg.time,2)== round(tim_list(ntime)+tim_wind,2));
                        
                        y1       = find(round(flg.freq)== round(frq_list(nfreq,1)));
                        y2       = find(round(flg.freq)== round(frq_list(nfreq,2)));
                        
                        if isempty(x1) || isempty(x2) || isempty(y1) || isempty(y2)
                            error('ahhhh')
                        else
                            pow      = mean(flg.powspctrm(1,y1:y2,x1:x2),3);
                            pow      = squeeze(mean(pow,2));
                            
                            if size(pow,1) > 1 || size(pow,2) > 1
                                error('oohhhhhhh')
                            else
                                
                                if ncue > 2
                                    cue_cat = 'uninformative';
                                else
                                    cue_cat = 'informative';
                                end
                                
                                fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%.2f\t%s\n',['yc' num2str(sb)],ls_cue{ncue},ls_chan,ls_freq,ls_time,pow,cue_cat);
                                
                                clear ls_*
                                
                            end
                        end
                        
                    end
                end
                
            end
        end
    end
    
    fclose(fid);
    
end

clearvars -except allsuj_* ; clc ;