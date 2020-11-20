function [cnd_freq,cnd_time] = prepare_cnd_freq_time(ext_freq,ext_time)

cnd_freq    = [];
cnd_time    = [];

for n = 1:length(ext_freq)
    
    x1 = strfind(ext_freq{n},'t');
    x2 = strfind(ext_freq{n},'H');
    f1 = str2double(ext_freq{n}(1:x1-1));
    f2 = str2double(ext_freq{n}(x1+1:x2-1));
    cnd_freq = [cnd_freq mean([f1 f2])];
    clear x1 x2 f1 f2
    
end

for n = 1:length(ext_time)
    
    ch = strfind(ext_time{n},'m');
    
    if ~isempty(ch)
        tot         = strfind(ext_time{n},'m');
    else
        tot         = strfind(ext_time{n},'p');
    end
    
    x1          = tot(1);
    x2          = tot(2);
    t1          = str2double(ext_time{n}(x1+1:x2-1));
    t2          = str2double(ext_time{n}(x2+1:end));
    
    if ~isempty(ch)
        cnd_time    = [cnd_time -mean([t1 t2])/1000];
    else
        cnd_time    = [cnd_time mean([t1 t2])/1000];
    end
    
end