clear ; clc ;

load ../data/yctot/plv4R.mat ;

for ii = 1:length(chn_list)
    
    dotdot = strfind(chn_list{ii},'.');
    
    chan1_list(ii) = str2num(chn_list{ii}(1:dotdot-1));
    chan2_list(ii) = str2num(chn_list{ii}(dotdot+1:end));
    
end

clear ii dotdot

time_list = {'','actv'};
chan_list = coh_measures{1,1}.label ;
freq_list = round(coh_measures{1,1}.freq);

fout = '../txt/plv4R.txt';
fid  = fopen(fout,'W+');

fprintf(fid,'%5s\t%5s\t%5s\t%5s\t%5s\n','SUB','TIME','PAIR','FREQ','PLV');

for ix_t   = 2
    
    for frq = 1:length(coh_measures{1,1}.freq)
        
        for c_c = 1:length(chan1_list)
            
            for sb = 1:size(coh_measures,1)
                
                suj = ['yc' num2str(sb)];
                c1  = chan_list{chan1_list(c_c)};
                c2  = chan_list{chan2_list(c_c)};
                f   = [num2str(freq_list(frq)) 'Hz'];
                plv = coh_measures{sb,ix_t}.plvspctrm(chan1_list(c_c),chan2_list(c_c),frq);
                fprintf(fid,'%5s\t%5s\t%5s\t%5s\t%.4f\n',suj,time_list{ix_t},[c1 '.' c2],f,plv);
                
                clear suj c1 c2 f plv
                
            end
            
        end
        
    end
    
end

fclose(fid);
