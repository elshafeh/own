%function r_ANOVA_TF(event,conds,fwin,blwin,smooth)
function r_ANOVA_TF(event,conds,smooth,ext)

% exemple: r_ANOVA_TF('cue',{'NCnD' 'VCnD'},50,'.freq7-11.lb')

list_mig    = {'mg1' 'mg2' 'mg3' 'mg4' 'mg5' 'mg6' 'mg7' 'mg8' 'mg9' ...
    'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg16' 'mg17' 'mg18' 'mg19'};
list_ctl    = {'uc6' 'uc10' 'yc17' 'yc19' 'uc8' 'uc7' 'uc9' 'yc12' 'yc6' ...
    'uc1' 'uc4' 'uc5' 'yc5' 'yc20' 'yc9' 'yc21' 'yc16' 'yc18' 'yc4'};

% for c = 1:length(conds)
%     cond = conds{1,c};
%     r_TFtimeprofile_rms(event,cond,fwin,blwin,list_ctl,list_mig);
% end
% 
% ext     = ['.freq' num2str(fwin(1)) '-' num2str(fwin(2)) '.lb'];
% ext_gfp = [ext '.gfp'];

tab = {list_ctl;list_mig};

r_ANOVA_erp(event,conds,tab,ext,smooth)
% r_ANOVA_erp(event,conds,tab,ext_gfp,smooth)

    function r_ANOVA_erp(event,cond,tab,ext,smooth)
        
        addpath('/dycog/Aurelie/DATA/mat_prog/stat/rm-ANOVA-1within1betweenFactors');
        addpath('/dycog/Aurelie/DATA/mat_prog/ELAN/erp');
        
        Ncond    = length(cond);
        donnees  = {[];[]};
        
        dirout = '/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/avg_mig/tf/stats/';
        mkdir(dirout);
        
        disp('Calcul en cours...')
        
        for grp=1:2    %ctl ou mig
            
            for i=1:length(tab{grp}) %on passe tous les sujets
                
                for j=1:Ncond %on passe les conditions
                    
                    filenamePRE = ['../data/' tab{grp}{i} '/tf/' event '/' tab{grp}{i} '.pat22.' cond{1,j} ext ]; %sans l'extension .p
                    r_PrepAtt_epsmooth(filenamePRE, smooth) %lissage
                    
                    filename    = [filenamePRE '.s' num2str(smooth) '.p'];
                    
                    [ENTETE, XE, DONNEES, UTIL]=readpem(filename);
                    eval('donnees{grp}(i,j,:,:)=DONNEES;');
                    
                end
                
            end
            
        end
        
        %%%%% Computing Anova for each sample
        % F_group = [];
        % F_cond = [];
        % F_group_by_cond = [];
        P_group         = zeros(UTIL.nbvoies,UTIL.nbech);
        P_cond          = zeros(UTIL.nbvoies,UTIL.nbech);
        P_group_by_cond = zeros(UTIL.nbvoies,UTIL.nbech);
        
        for v=1:UTIL.nbvoies
            
            for ech=1:UTIL.nbech
                
                [p, stats] = anova_rm({donnees{1}(:,:,ech,v) donnees{2}(:,:,ech,v)}, 'OFF');
                %         F_group(ech,v)=cell2mat(stats(3,5));
                %         F_cond(ech,v)=cell2mat(stats(2,5));
                %         F_group_by_cond(ech,v)=cell2mat(stats(4,5));
                P_group(ech,v)=cell2mat(stats(3,6));
                P_cond(ech,v)=cell2mat(stats(2,6));
                P_group_by_cond(ech,v)=cell2mat(stats(4,6));
                
            end
            
        end
        
        
        %%%%% Writing output .p files
        
        newext = [ '.' strjoin(cond,'-') ext '.rmanova.p' ];
        
        % nameFb  = [ dirout 'F_group' newext ];
        % nameFw  = [ dirout 'F_' condname newext ];
        % nameFbw = [ dirout 'F_group_by_' condname newext ];
        % writepem(ENTETE, XE, F_group, nameFb);
        % writepem(ENTETE, XE, F_cond, nameFw);
        % writepem(ENTETE, XE, F_group_by_cond, nameFbw);
        
        namePb  = [ dirout 'P_group' newext ];
        namePw  = [ dirout 'P_factor' newext ];
        namePbw = [ dirout 'P_group_by_factor' newext ];
        writepem(ENTETE, XE, P_group, namePb);
        writepem(ENTETE, XE, P_cond, namePw);
        writepem(ENTETE, XE, P_group_by_cond, namePbw);
        
        system(['rm ' filename])
        
        disp('Calcul terminé.');
        
        function r_PrepAtt_epsmooth(epfileIN, smooth) %sans .p
            
            epfileOUT   = [epfileIN '.s' num2str(smooth)];
            system(['rm ' epfileOUT '.p'])
            
            FicName     = ['batch.epsmooth'];
            fid         = fopen(FicName,'w+');
            fprintf(fid,'#!/bin/bash\n');
            fprintf(fid,'\n');
            fprintf(fid,'epsmooth<<!\n');
            fprintf(fid,'%d\n',smooth);
            fprintf(fid,'%d\n',-500);
            fprintf(fid,'%s\n',epfileIN);
            fprintf(fid,'%s\n',epfileOUT);
            fprintf(fid,'\n');
            fprintf(fid,'!\n');
            fclose(fid);
            
            system(['chmod 777 ' FicName]);
            system(['bash ' FicName]);
            
            system('rm batch.epsmooth');
            
        end
        
    end

end
