clear ; clc ;

brain_topo  = readtable('~/Desktop/orig/PAT_perf_RT.txt');
brain_topo  = brain_topo(:,2:17);
list_cond   = brain_topo.Properties.VariableNames;

fOUT                        = '../documents/4R/brain_topo_performance.txt';
fid                         = fopen(fOUT,'W+');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','SUB','cond_cue','cond_dis','cond_tar','MedianRT');

for sb = 1:size(brain_topo,1)
    for ncond = 1:size(brain_topo,2)
        
        cond_name   = strsplit(list_cond{ncond},'_');
        
        if length(cond_name) > 2
            cond_cue    = cond_name{2};
            cond_dis    = cond_name{1};
        else
            cond_cue    = cond_name{1}(5:end);
            cond_dis    = cond_name{1}(1:4);
        end
        
        if strcmp(cond_dis,'NoDIS')
            cond_dis = 'DIS0';
        end
        
        cond_tar    = cond_name{end};    
        
        fprintf(fid,'%s\t%s\t%s\t%s\t%.3f\n',['suj' num2str(sb)],cond_cue,cond_dis,cond_tar,table2array(brain_topo(sb,ncond)));
        
    end
end

fclose(fid);