data         = 'eeg';
cond         = 'CnD';
window       = 0;
ext          = '.lb';
event        = 'cue'

iCNV_lat_s   = [600:900]; %ms
iCNV_lat     = floor((iCNV_lat_s + 4000)*3/5); %conversion en échantillon
lCNV_lat_s   = [900:1200]; %ms
lCNV_lat     = floor((lCNV_lat_s + 4000)*3/5); %conversion en échantillon

slope_lat_s  = [600:650;1150:1200];
slope_lat     = floor((slope_lat_s + 4000)*3/5);

%%%Réalise une ANOVA sur chaque point du .p après un lissage

if strcmp(data,'eeg')
    grp1 = {'mg1' 'mg2' 'mg3' 'mg4' 'mg5' 'mg6' 'mg7' 'mg8' 'mg9' ...
        'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg16' 'mg17' 'mg18' 'mg19'};
    grp2 = {'uc6' 'uc10' 'yc17' 'yc19' 'uc8' 'uc7' 'uc9' 'yc12' 'yc6' ...
        'uc1' 'uc4' 'uc5' 'yc5' 'yc20' 'yc21' 'yc16' 'yc18' 'yc4'};
    elec = [10 15 40 41]; %Cz, FC1, FC2, Fz
elseif strcmp(data,'meg')
    grp1 = {'mg1' 'mg2' 'mg3' 'mg4' 'mg5' 'mg6' 'mg7' 'mg8' 'mg9' ...
        'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg16' 'mg17' 'mg18' 'mg19'};
    grp2 = {'uc6' 'uc10' 'yc17' 'yc19' 'uc8' 'uc7' 'uc9' 'yc12' 'yc6' ...
        'uc1' 'uc4' 'uc5' 'yc5' 'yc20' 'yc9' 'yc21' 'yc16' 'yc18' 'yc4'};    %%pour MEG
end

tab = {grp1;grp2};

addpath('/dycog/Aurelie/DATA/mat_prog/ELAN/erp');

dirout = ['/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/avg_mig/erp/' data '/stats/'];
mkdir(dirout);

disp('Calcul en cours...')

iCNV  = zeros(length(grp1)+length(grp2),20);
lCNV  = zeros(length(grp1)+length(grp2),20);
slope = zeros(length(grp1)+length(grp2),10);

sb = 0;

for grp=1:2    %ctl ou mig
    
    for suj=1:length(tab{grp}) %on passe tous les sujets
        
        bh = 0;
        sb = sb+1;
        
        for bloc = 1:10
            
            for half = 1:2
                
                bh = bh+1;
                
                eval(['filenamePRE = ''' '../data/' tab{grp}{suj} '/erp/' data '/' event ...
                    '/' tab{grp}{suj} '.pat22.' cond '.b' num2str(bloc) 'half' num2str(half) ext ''';']); %sans l'extension .p
                
                if window ~= 0
                    
                    r_PrepAtt_epsmooth(filenamePRE, window) %lissage
                    eval(['filename = ''' '../data/' tab{grp}{suj} '/erp/' data '/' event ...
                        '/' tab{grp}{suj} '.pat22.' cond '.b' num2str(bloc) 'half' num2str(half) ext '.s' num2str(window) '.p'';']);
                    
                else
                    
                    filename = [filenamePRE '.p'];
                    
                end
                
                [ENTETE, XE, DONNEES, UTIL]=readpem(filename); %on extrait les données
                
                elec_order = (find(sum(UTIL.elec == elec, 2)==1)).'; %trouve à quoi correspondent les électrodes voulues dans la structure
                
                iCNV(sb,bh)  = round(mean(mean(DONNEES(iCNV_lat,elec_order))),2); %moyenne sur fenetre de temps et moyenne d'électrode
                lCNV(sb,bh)  = round(mean(mean(DONNEES(lCNV_lat,elec_order))),2);
                                                                              
                slope(sb,bh) = round(mean(mean(DONNEES(slope_lat(2,:),elec_order)))-mean(mean(DONNEES(slope_lat(1,:),elec_order)))/(mean(slope_lat_s(2,:)-mean(slope_lat_s(1,:)))));
                
                
            end
            
        end
        
    end
    
end


subj_list         = repmat([grp1,grp2].',[20,1]);
subj_table        = array2table(subj_list,'VariableNames',{'Subject'});

grp_list          = repmat([repmat({'mig'},[length(grp1),1]);repmat({'ctl'},[length(grp2),1])],[20,1]);
grp_table         = array2table(grp_list,'VariableNames',{'Group'});

bloc_list         = repelem([1:10],2*(length(grp1)+length(grp2))).';
bloc_table        = array2table(bloc_list,'VariableNames',{'Block'});

half_list         = repmat(repelem([1 2],length(grp1)+length(grp2)).',[10,1]);
half_table        = array2table(half_list,'VariableNames',{'Half'});

iCNV_table        = array2table(reshape(iCNV,[],1),'VariableNames',{'iCNV'});
lCNV_table        = array2table(reshape(lCNV,[],1),'VariableNames',{'lCNV'});
slope_table       = array2table(reshape(slope,[],1),'VariableNames',{'Slope_CNV'});

table             = [subj_table grp_table bloc_table half_table iCNV_table lCNV_table slope_table];

writetable(table,['../data/avg_mig/erp/' data '/habituation_CNV.csv'])









