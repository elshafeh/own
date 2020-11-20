clear;clc;
addpath('../toolbox/sigstar-master/');

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:14 % length(suj_list)
    
    subjectName                     = suj_list{nsuj};
    
    frequency_list                  = {'theta' 'alpha' 'beta' 'gamma'};
    decoding_list                   = {'pre.ori.vs.spa' 'retro.ori.vs.spa'};
    
    for nfreq = 1:length(frequency_list)
        
        freq                        = [];
        freq.powspctrm            	= [];
        
        for ndeco = 1:length(decoding_list)
            fname                       = ['F:/bil/decode/' subjectName '.1stcue.lock.' frequency_list{nfreq} ...
                '.centered.decodingcue.' decoding_list{ndeco}  '.correct.timegen.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            %             scores(scores<0.5)      = 0.5;
            freq.powspctrm(ndeco,:,:)  	= scores; clear scores; % h_timegen_cut(scores);
        end
        
        freq.label               	= decoding_list;
        freq.time                	= time_axis;
        freq.freq                	= time_axis;
        freq.dimord             	= 'chan_freq_time';
        
        alldata{nsuj,nfreq}         = freq; clear freq;
        
    end
    
    %     alldata{nsuj,5}                 = alldata{nsuj,1};
    %     tmp                             = alldata{nsuj,5}.powspctrm;
    %     tmp(~isnan(tmp))                = 0.5;
    %     alldata{nsuj,5}.powspctrm       = tmp; clear tmp;
    %     frequency_list                  = {'theta' 'alpha' 'beta' 'gamma' 'chance'};
    
end

keep alldata *_list

