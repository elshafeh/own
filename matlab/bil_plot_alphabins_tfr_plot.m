clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

list_chan               = [];

for nsuj = 1:length(suj_list)
    
    subjectName         = suj_list{nsuj};
    
    if isunix
        subject_folder  = ['/project/3015079.01/data/' subjectName];
    else
        subject_folder  = ['P:/3015079.01/data/' subjectName];
    end
    
    for nbin = 1:5
        fname_out        	= ['I:/hesham/bil/tf/' subjectName '.cuelock.mtmconvolPOW.m2p7s.20msStep.1t100Hz.1HzStep.AvgTrials.preCue1alphasorted.bin' num2str(nbin) '.mat'];
        fprintf('loading %s\n',fname_out);
        load(fname_out);
        alldata{nsuj,nbin}  = freq_comb; clear freq_comb;
    end
    
    fname                   = [subject_folder '/erf/' subjectName '.gratinglock.demean.erfComb.max20chan.p0p200ms.postOnset.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    list_chan               = [list_chan;max_chan];
    
end

keep list_chan alldata;

for nbin = 1:size(alldata,2)
    gavg{nbin}  = ft_freqgrandaverage([],alldata{:,nbin});
end

nrow            = 5;
ncol        	= 3;
i               = 0;

list_freq   	= [6 48; 10 48; 54 100];
list_zlim       = [0 3e-27; 0 1e-27;5e-29 9e-29];

for nbin = 1:size(alldata,2)
for nfreq = 1:size(list_freq,1)
        
        cfg                  	= [];
        cfg.layout            	= 'CTF275_helmet.mat'; %'CTF275.lay';
        cfg.marker            	= 'off';
        cfg.comment           	= 'no';
        cfg.colorbar           	= 'yes';
        cfg.colormap          	= brewermap(256, '*RdBu');
        cfg.zlim              	= list_zlim(nfreq,:); %  'maxabs'; % 
        cfg.xlim                = [-0.7 6];
        cfg.ylim                = list_freq(nfreq,:);
        
        i = i + 1;
        subplot(nrow,ncol,i)
        ft_singleplotTFR(cfg,gavg{nbin});
        vline([0 1.5 3 4.5 5.5]);
        xticks([0 1.5 3 4.5 5.5])
        xticklabels({'1st Cue' '1st Gab' '2nd Cue' '2nd Gab' 'Mean RT'});
        title('');
        
        %         i = i + 1;
        %         subplot(nrow,ncol,i)
        %         cfg.colorbar           	= 'no';
        %         cfg.channel             = unique(list_chan);
        %         ft_topoplotTFR(cfg,gavg{nbin});
        
    end
end