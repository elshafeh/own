function r_PrepAtt22_anova_ERP(data,event,cond,ext,window)

%%%Réalise une ANOVA sur chaque point du .p après un lissage

if strcmp(data,'eeg')    
    grp1 = {'mg1' 'mg2' 'mg3' 'mg4' 'mg5' 'mg6' 'mg7' 'mg8' 'mg9' ...
        'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg16' 'mg17' 'mg18' 'mg19'};
    grp2 = {'uc6' 'uc10' 'yc17' 'yc19' 'uc8' 'uc7' 'uc9' 'yc12' 'yc6' ...
        'uc1' 'uc4' 'uc5' 'yc5' 'yc20' 'yc21' 'yc16' 'yc18' 'yc4'};    
elseif strcmp(data,'meg')
    grp1 = {'mg1' 'mg2' 'mg3' 'mg4' 'mg5' 'mg6' 'mg7' 'mg8' 'mg9' ...
        'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg16' 'mg17' 'mg18' 'mg19'};    
    grp2 = {'uc6' 'uc10' 'yc17' 'yc19' 'uc8' 'uc7' 'uc9' 'yc12' 'yc6' ...
        'uc1' 'uc4' 'uc5' 'yc5' 'yc20' 'yc9' 'yc21' 'yc16' 'yc18' 'yc4'};    %%pour MEG
end

tab = {grp1;grp2};

% event = 'target';
% data     = 'meg';
% ext      = '.lb.gfp';
% cond     = {'NnDT' 'VnDT'};
Ncond    = length(cond);
donnees  = {[];[]};
% window   = 15; %facteur de lissage (15 pour DIS et target, 50 pour cue)

addpath('/dycog/Aurelie/DATA/mat_prog/stat/rm-ANOVA-1within1betweenFactors');
addpath('/dycog/Aurelie/DATA/mat_prog/ELAN/erp');

dirout = ['/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/avg_mig/erp/' data '/stats/'];
mkdir(dirout);

disp('Calcul en cours...')

for grp=1:2;    %ctl ou mig
    
    for i=1:length(tab{grp}); %on passe tous les sujets
        
        for j=1:Ncond; %on passe les conditions
            
            eval(['filenamePRE = ''' '../data/' tab{grp}{i} '/erp/' data '/' event ...
                '/' tab{grp}{i} '.pat22.' cond{1,j} ext ''';']); %sans l'extension .p
            
            if window ~= 0
                
                r_PrepAtt_epsmooth(filenamePRE, window) %lissage
                eval(['filename = ''' '../data/' tab{grp}{i} '/erp/' data '/' event ...
                    '/' tab{grp}{i} '.pat22.' cond{1,j} ext '.s' num2str(window) '.p'';']);
                
            else
                
                filename = [filenamePRE '.p'];
                
            end
            
            [ENTETE, XE, DONNEES, UTIL]=readpem(filename);
            eval(['donnees{grp}(i,j,:,:)=DONNEES;']);
            
        end
        
    end
    
end

%%%%% Computing Anova for each sample
% F_group = [];
% F_cond = [];
% F_group_by_cond = [];
P_group = [];
P_cond = [];
P_group_by_cond = [];

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

newext = [ '.' strjoin(cond,'-') ext '.s' num2str(window) '.rmanova.p' ];

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

disp('Calcul terminé.');


end



