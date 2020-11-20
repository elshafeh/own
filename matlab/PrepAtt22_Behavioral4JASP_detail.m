clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

patient_list;
suj_group{1}                = fp_list_all;
suj_group{2}                = cn_list_all;

list_group                  = {'patient','control'};

fOUT                        = '../documents/4R/patientBehav4Jasp_plannedBehav.txt';
fid                         = fopen(fOUT,'W+');

fprintf(fid,'%s\t%s\t%s\t%s\t%s\n','SUB','GROUP','CuEffect','ArEffect','CapEffect');

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        
        fprintf('Handling %s\n',suj);
        
        [Vmed_rt,~,~,~,~,~,~,~]         =  h_behav_eval(suj,[1 2],0,1:4);
        [Nmed_rt,~,~,~,~,~,~,~]         =  h_behav_eval(suj,0,0,1:4);
        
        [D0med_rt,~,~,~,~,~,~,~]        =  h_behav_eval(suj,0:2,0,1:4);
        [D1med_rt,~,~,~,~,~,~,~]        =  h_behav_eval(suj,0:2,1,1:4);
        [D2med_rt,~,~,~,~,~,~,~]        =  h_behav_eval(suj,0:2,2,1:4);
        
        rt_buck{1}                      =  Nmed_rt - Vmed_rt;
        rt_buck{2}                      =  D0med_rt - D1med_rt;
        rt_buck{3}                      =  D2med_rt - D1med_rt;
        
        fprintf(fid,'%s\t%s',suj,list_group{ngroup});
        
        for ndetail = 1:length(rt_buck)
            
            fprintf(fid,'\t');
            fprintf(fid,'%.2f',rt_buck{ndetail});
            
        end
        
        fprintf(fid,'\n');
        
    end
end

fclose(fid);