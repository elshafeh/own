function corr2plot = h_plotCorrStat(stat,p_lim)

nw_stat                 = stat ;
nw_stat.mask            = nw_stat.prob < p_lim ;