% creates a mask for pseudo-random sequence of n_bits bits

function mask = create_lfsr_mask(n_bits)

% old_mask = zeros(n_bits,1);
% switch(n_bits)
%     case {2,3,4,6,7,15}
%         old_mask([1 2]) = [1 1];
%     case {5,11}
%         old_mask([1 3]) = [1 1];
%     case {8}
%         old_mask([1 3 4 5]) = [1;1;1;1];
%     case {9}
%         old_mask([1 5]) = [1;1];
%     case {10,17}
%         old_mask([1 4]) = [1;1];
%     case {12}
%         old_mask([1 2 3 9]) = [1;1;1;1];
%     case {13,19}
%         old_mask([1 2 3 6]) = [1;1;1;1];
%     case {14}
%         old_mask([1 2 3 13]) = [1;1;1;1];
%     case {16}
%         old_mask([1 2 3 4 6]) = [1;1;1;1;1];
%     case {18}
%         old_mask([1 8]) = [1;1];
%     otherwise
%         error('Mask not defined for this sequence length');
% end
% old_mask

if n_bits>168
    fprintf(1,'Mask not defined for this sequence length');
    return;
end

mask = zeros(n_bits,1);

tab_polynomials{2} = [1,2];
tab_polynomials{3} = [2,3];
tab_polynomials{4} = [3,4];
tab_polynomials{5} = [3,5];
tab_polynomials{6} = [5,6];
tab_polynomials{7} = [6,7];
tab_polynomials{8} = [4,5,6,8];
tab_polynomials{9} = [5,9];
tab_polynomials{10} = [7,10];
tab_polynomials{11} = [9,11];
tab_polynomials{12} = [1,4,6,12];
tab_polynomials{13} = [1,3,4,13];
tab_polynomials{14} = [1,3,5,14];
tab_polynomials{15} = [14,15];
tab_polynomials{16} = [4,13,15,16];
tab_polynomials{17} = [14,17];
tab_polynomials{18} = [11,18];
tab_polynomials{19} = [1,2,6,19];
tab_polynomials{20} = [20,17];
tab_polynomials{21} = [19,21];
tab_polynomials{22} = [21,22];
tab_polynomials{23} = [18,23];
tab_polynomials{24} = [17,22,23,24];
tab_polynomials{25} = [22,25];
tab_polynomials{26} = [1,2,6,26];
tab_polynomials{27} = [1,2,5,27];
tab_polynomials{28} = [25,28];
tab_polynomials{29} = [27,29];
tab_polynomials{30} = [1,4,6,30];
tab_polynomials{31} = [28,31];
tab_polynomials{32} = [1,2,22,32];
tab_polynomials{33} = [30,22];
tab_polynomials{34} = [1,2,27,34];
tab_polynomials{35} = [33,35];
tab_polynomials{36} = [25,36];
tab_polynomials{37} = [1,2,3,4,5,37];
tab_polynomials{38} = [1,5,6,38];
tab_polynomials{39} = [35,39];
tab_polynomials{40} = [19,21,38,40];
tab_polynomials{41} = [38,41];
tab_polynomials{42} = [19,20,41,42];
tab_polynomials{43} = [37,38,42,43];
tab_polynomials{44} = [17,18,43,44];
tab_polynomials{45} = [41,42,44,45];
tab_polynomials{46} = [25,26,45,46];
tab_polynomials{47} = [42,47];
tab_polynomials{48} = [20,21,47,48];
tab_polynomials{49} = [40,49];
tab_polynomials{50} = [23,24,49,50];
tab_polynomials{51} = [35,36,50,51];
tab_polynomials{52} = [49,52];
tab_polynomials{53} = [37,38,52,53];
tab_polynomials{54} = [17,17,53,54];
tab_polynomials{55} = [31,55];
tab_polynomials{56} = [34,35,55,56];
tab_polynomials{57} = [50,57];
tab_polynomials{58} = [39,58];
tab_polynomials{59} = [37,38,58,59];
tab_polynomials{60} = [59,60];
tab_polynomials{61} = [45,46,60,61];
tab_polynomials{62} = [5,6,61,62];
tab_polynomials{63} = [62,63];
tab_polynomials{64} = [60,61,63,64];
tab_polynomials{65} = [47,65];
tab_polynomials{66} = [56,57,65,66];
tab_polynomials{67} = [57,58,66,67];
tab_polynomials{68} = [59,68];
tab_polynomials{69} = [40,42,67,69];
tab_polynomials{70} = [54,55,69,60];
tab_polynomials{71} = [65,71];
tab_polynomials{72} = [19,25,66,72];
tab_polynomials{73} = [48,73];
tab_polynomials{74} = [58,59,73,74];
tab_polynomials{75} = [64,65,74,75];
tab_polynomials{76} = [40,41,75,76];
tab_polynomials{77} = [46,47,76,77];
tab_polynomials{78} = [58,59,77,78];
tab_polynomials{79} = [70,79];
tab_polynomials{80} = [42,43,79,80];
tab_polynomials{81} = [77,81];
tab_polynomials{82} = [44,47,79,82];
tab_polynomials{83} = [37,38,82,83];
tab_polynomials{84} = [71,84];
tab_polynomials{85} = [57,58,84,85];
tab_polynomials{86} = [73,74,85,86];
tab_polynomials{87} = [74,87];
tab_polynomials{88} = [16,17,87,88];
tab_polynomials{89} = [51,89];
tab_polynomials{90} = [71,72,89,90];
tab_polynomials{91} = [7,8,90,91];
tab_polynomials{92} = [79,80,91,92];
tab_polynomials{93} = [91,93];
tab_polynomials{94} = [73,94];
tab_polynomials{95} = [84,95];
tab_polynomials{96} = [47,49,94,96];
tab_polynomials{97} = [91,97];
tab_polynomials{98} = [87,98];
tab_polynomials{99} = [52,54,97,99];
tab_polynomials{100} = [63,100];
tab_polynomials{101} = [94,95,100,101];
tab_polynomials{102} = [35,36,101,102];
tab_polynomials{103} = [94,103];
tab_polynomials{104} = [93,94,103,104];
tab_polynomials{105} = [89,105];
tab_polynomials{106} = [91,106];
tab_polynomials{107} = [42,44,105,107];
tab_polynomials{108} = [77,108];
tab_polynomials{109} = [102,103,108,109];
tab_polynomials{110} = [97,98,109,110];
tab_polynomials{111} = [101,111];
tab_polynomials{112} = [67,69,110,112];
tab_polynomials{113} = [104,113];
tab_polynomials{114} = [32,33,113,114];
tab_polynomials{115} = [100,101,114,115];
tab_polynomials{116} = [45,446,115,116];
tab_polynomials{117} = [97,99,115,1178];
tab_polynomials{118} = [85,118];
tab_polynomials{119} = [111,119];
tab_polynomials{120} = [2,9,113,120];
tab_polynomials{121} = [103,121];
tab_polynomials{122} = [62,63,121,122];
tab_polynomials{123} = [121,123];
tab_polynomials{124} = [87,24];
tab_polynomials{125} = [17,18,124,125];
tab_polynomials{126} = [89,90,125,126];
tab_polynomials{127} = [126,127];
tab_polynomials{128} = [99,101,126,128];
tab_polynomials{129} = [124,129];
tab_polynomials{130} = [127,130];
tab_polynomials{131} = [83,84,130,131];
tab_polynomials{132} = [103,132];
tab_polynomials{133} = [81,82,132,133];
tab_polynomials{134} = [77,134];
tab_polynomials{135} = [124,135];
tab_polynomials{136} = [10,11,135,136];
tab_polynomials{137} = [116,137];
tab_polynomials{138} = [130,131,137,138];
tab_polynomials{139} = [131,134,136,139];
tab_polynomials{140} = [11,140];
tab_polynomials{141} = [109,110,140,141];
tab_polynomials{142} = [121,142];
tab_polynomials{143} = [122,123,142,143];
tab_polynomials{144} = [74,75,143,144];
tab_polynomials{145} = [93,145];
tab_polynomials{146} = [86,87,145,146];
tab_polynomials{147} = [109,110,146,147];
tab_polynomials{148} = [121,148];
tab_polynomials{149} = [30,40,148,149];
tab_polynomials{150} = [97,150];
tab_polynomials{151} = [148,151];
tab_polynomials{152} = [86,87,151,152];
tab_polynomials{153} = [152,153];
tab_polynomials{154} = [25,27,152,154];
tab_polynomials{155} = [123,124,154,155];
tab_polynomials{156} = [40,41,155,156];
tab_polynomials{157} = [130,131,156,157];
tab_polynomials{158} = [131,132,157,158];
tab_polynomials{159} = [128,159];
tab_polynomials{160} = [141,142,159,160];
tab_polynomials{161} = [143,161];
tab_polynomials{162} = [74,75,161,162];
tab_polynomials{163} = [103,104,162,163];
tab_polynomials{164} = [150,151,163,164];
tab_polynomials{165} = [134,135,164,165];
tab_polynomials{166} = [127,128,165,166];
tab_polynomials{167} = [161,167];
tab_polynomials{168} = [151,153,166,168];
    
mask(n_bits + 1 - tab_polynomials{n_bits}) = 1;


