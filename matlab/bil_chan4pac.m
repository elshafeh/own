clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName         	= suj_list{nsuj};
    
    fname                   = ['P:/3015079.01/data/' subjectName '/erf/' subjectName '.gratinglock.demean.erfComb.max20chan.p0p200ms.postOnset.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    fname                   = ['I:\hesham\bil\head\' subjectName '.datainfo.mat'];
    fprintf('loading: %s\n',fname);
    load(fname);
    
    pac_chan                = [];
    
    for nchan = 1:length(max_chan)
        pac_chan           	= [pac_chan find(strcmp(datainfo.label,max_chan{nchan}))];
    end
    
    pac_chan                = pac_chan - 1;
    fname                   = ['F:\bil\pac\' subjectName '.pac.chan.mat'];
    save(fname,'pac_chan');
    
    keep nsuj suj_list
    
end