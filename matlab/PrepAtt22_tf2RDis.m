clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

lst_group       = {'old','young'};

fOUT            = '../documents/4R/NEwDisAgeCOtnrastAuditory60t100_50mSteps_sepCue_e20.txt';
fid             = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\n','GROUP','SUB','CUE','CHAN','FREQ','TIME','POW');

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        lst_dis = {'DIS','fDIS'};
        lst_cue = {'R','L','N'};
        
        for ncue = 1:length(lst_cue)
            
            for cnd_dis = 1:2
                
                suj                 = suj_list{sb};
                fname_in            = ['../data/' suj '/field/' suj '.' lst_cue{ncue} lst_dis{cnd_dis} '.AgeCommonROI.40t120Hz.m200p600msCov.waveletPOW.40t119Hz.m1000p1000.KeepTrials.MinEvoked.mat'];
                fprintf('Loading %s\n',fname_in);
                
                load(fname_in)
                
                if isfield(freq,'check_trialinfo')
                    freq = rmfield(freq,'check_trialinfo');
                end
                
                freq           = ft_freqdescriptives([],freq);
                freq           = h_transform_freq(freq,{[1 2],[3 4]},{'audL','audR'});
                
                tmp{cnd_dis}   = freq; clear freq
                
            end
            
            cfg                             = [];
            cfg.parameter                   = 'powspctrm';
            cfg.operation                   = 'x1-x2';
            freq                            = ft_math(cfg,tmp{1},tmp{2});
            
            clear tmp ;
            
            for nchan = 1:length(freq.label)
                
                frq_win  = 40;
                frq_list = 60;
                
                tim_wind = 0.05;
                tim_list = -0.1:tim_wind:0.35;
                
                for nfreq = 1:length(frq_list)
                    for ntime = 1:length(tim_list)
                        
                        name_chan     = freq.label{nchan};

                        ls_time     = [num2str(tim_list(ntime)*1000) 'ms'];
                        ls_freq     = [num2str(frq_list(nfreq)) 'Hz'];
                        
                        x1          = find(round(freq.time,2)== round(tim_list(ntime),2));
                        x2          = find(round(freq.time,2)== round(tim_list(ntime)+tim_wind,2));
                        
                        y1          = find(round(freq.freq)== round(frq_list(nfreq)));
                        y2          = find(round(freq.freq)== round(frq_list(nfreq)+frq_win));
                        
                        if isempty(x1) || isempty(x2) || isempty(y1) || isempty(y2)
                            error('ahhhh')
                        else
                            
                            pow      = mean(freq.powspctrm(nchan,y1:y2,x1:x2),3);
                            pow      = squeeze(mean(pow,2));
                            
                            pow      = pow/10e20;
                            
                            if size(pow,1) > 1 || size(pow,2) > 1
                                error('oohhhhhhh')
                            else
                                
                                fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%.2f\n',lst_group{ngroup},['sub' num2str(sb)],[lst_cue{ncue} 'Cue'],name_chan,ls_freq,ls_time,pow);
                                
                            end
                        end
                    end
                end
            end
        end
    end
end

fclose(fid);