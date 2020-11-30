%fonction d'attenuation (cf Psychoacoustique, Botte? Fig 1.2 p17)
xatt=[200 500 1000 2000 5000];
xatt=log10(xatt);
yatt=[-10 -3 0 2 1];
patt=polyfit(xatt, yatt, 2);
Ai=10^(polyval(patt,log10(1000)));


%Pour une freq donnée:
AC=polyval(patt,log10(freq));
Att=Ai*10^(-AC/20);    %il faut multiplier l'amplitude A par Att