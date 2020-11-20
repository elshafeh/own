clear ; clc ;

eloc = {
    '18 90.0 108.0 Fp1'
    '19 90.0 72.0 Fp2'
    '13 90.0 144.0 F7'
    '14 63.1 136.9 F3'
    '29 51.7 116.3 F1'
    '15 45.0 90.0 Fz'
    '30 51.7 63.7 F2'
    '16 63.1 43.1 F4'
    '17 90.0 36.0 F8'
    '75 90.0 162.0 FT7'
    '81 70.4 158.3 FC5'
    '44 52.1 155.8 FC3'
    '40 31.5 136.9 FC1'
    '37 22.5 90.0 FCz'
    '41 31.5 43.1 FC2'
    '45 52.1 24.2 FC4'
    '82 70.4 21.7 FC6'
    '76 90.0 18.0 FT8'
    '157 90.0 180.0 T7'
    '24 67.5 180.0 C5'
    '9 45.0 180.0 C3'
    '25 22.5 180.0 C1'
    '10 0.0 0.0 Cz'
    '26 22.5 0.0 C2'
    '11 45.0 0.0 C4'
    '27 67.5 0.0 C6'
    '158 90.0 0.0 T8'
    '115 120.0 200.0 TP9'
    '68 90.0 198.0 TP7'
    '79 70.4 202.1 CP5'
    '42 31.5 223.1 CP1'
    '36 22.5 270.0 CPz'
    '43 31.5 316.9 CP2'
    '80 70.4 337.9 CP6'
    '69 90.0 342.0 TP8'
    '116 120.0 340.0 TP10'
    '155 90.0 216.0 P7'
    '20 76.5 219.3 P5'
    '4 63.1 223.1 P3'
    '21 51.7 243.7 P1'
    '5 45.0 270.0 Pz'
    '22 51.7 296.3 P2'
    '6 63.1 316.9 P4'
    '23 76.5 320.7 P6'
    '156 90.0 324.0 P8'
    '83 80.0 231.7 PO3'
    '35 67.5 270.0 POz'
    '84 80.0 308.3 PO4'
    '117 120.0 235.0 PO9'
    '1 90.0 252.0 O1'
    '34 90.0 270.0 Oz'
    '2 90.0 288.0 O2'
    '118 120.0 305.0 PO10'
    '56 112.5 270.0 Iz'};

edit_eloc = [];

for i = 1:length(eloc)
    
    tmp = strsplit(eloc{i},' ');
    edit_eloc(i).number     = str2double(tmp{1});
    edit_eloc(i).theta      = str2double(tmp{2});
    edit_eloc(i).phi        = str2double(tmp{3});
    edit_eloc(i).name       = tmp{4};
    
    clear tmp
    
end

clear i ; eloc = edit_eloc ; clear edit_eloc ; eloc = struct2table(eloc);

sens.label      = eloc.name;
theta           = eloc.theta;
phi             = eloc.phi;
radians         = @(x) pi*x/180;

warning('assuming a head radius of 90 mm');

x = 90*cos(radians(phi)).*sin(radians(theta));
y = 90*sin(radians(theta)).*sin(radians(phi));
z = 90*cos(radians(theta));

sens.unit       = 'cm';
sens.elecpos    = [x y z];
sens.chanpos    = [x y z];

clearvars -except sens ;

save('elan_sens.mat','sens');

cfg         = [];
cfg.elec    = sens;
lay         = ft_prepare_layout(cfg);

save('elan_lay.mat','lay');

cfg         = [];
cfg.layout  = 'elan_lay.mat';
ft_layoutplot(cfg);

% fOUT = '../txt/new_lay.txt';
% fid  = fopen(fOUT,'W+');
% 
% for i = 1:size(eloc,1)
%     
%     fprintf(fid,'%5s\t%.4f\t%.4f\n',eloc.name{i},eloc.theta(i),eloc.phi(i)); 
% end
% 
% fclose(fid);
% load /Users/heshamelshafei/Desktop/biosemi64.mat;
% tmp = lay ;
% lay.pos             = [eloc.phi eloc.theta ];
% lay.width(65:end)   = [];
% lay.height(65:end)  = [];
% lay.label           = eloc.name;
% lay = rmfield(lay,'cfg');
% lay = rmfield(lay,'outline');
% lay = rmfield(lay,'mask');
% save('elan_lay.mat','lay')
% cfg=[];
% cfg.layout = 'elan_lay.mat';
% ft_layoutplot(cfg);