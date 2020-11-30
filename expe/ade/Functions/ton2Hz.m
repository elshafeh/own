% sub-fonction for creating pure tones
function f=ton2Hz(F0,ton)

a   =2^(ton/12);
f   =a*F0;


