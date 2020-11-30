#Presentation Script for determining thresholds

#HEADER
scenario = "Detection_threshold_P";
response_logging = log_all;
#write_codes = true;
response_matching = simple_matching;
active_buttons = 2;
button_codes = 5, 6;
target_button_codes = 7, 8;
#pulse_width = 3;
default_monitor_sounds = false;
default_trial_duration = 510;
default_trial_type = fixed;

#SDL
begin;

#load in sounds made in matlab
#start pitch 1 (513 Hz)
wavefile{filename = "A_0_dn.wav";}A_p;
wavefile{filename = "A_1_up.wav";}A_u_0p1;
wavefile{filename = "A_1_dn.wav";}A_d_0p1;
wavefile{filename = "A_2_up.wav";}A_u_0p2;
wavefile{filename = "A_2_dn.wav";}A_d_0p2;
wavefile{filename = "A_3_up.wav";}A_u_0p3;
wavefile{filename = "A_3_dn.wav";}A_d_0p3;
wavefile{filename = "A_4_up.wav";}A_u_0p4;
wavefile{filename = "A_4_dn.wav";}A_d_0p4;
wavefile{filename = "A_5_up.wav";}A_u_0p5;
wavefile{filename = "A_5_dn.wav";}A_d_0p5;
wavefile{filename = "A_6_up.wav";}A_u_0p6;
wavefile{filename = "A_6_dn.wav";}A_d_0p6;
wavefile{filename = "A_7_up.wav";}A_u_0p7;
wavefile{filename = "A_7_dn.wav";}A_d_0p7;
wavefile{filename = "A_8_up.wav";}A_u_0p8;
wavefile{filename = "A_8_dn.wav";}A_d_0p8;
wavefile{filename = "A_9_up.wav";}A_u_0p9;
wavefile{filename = "A_9_dn.wav";}A_d_0p9;
wavefile{filename = "A_10_up.wav";}A_u_1p0;
wavefile{filename = "A_10_dn.wav";}A_d_1p0;
wavefile{filename = "A_11_up.wav";}A_u_1p1;
wavefile{filename = "A_11_dn.wav";}A_d_1p1;
wavefile{filename = "A_12_up.wav";}A_u_1p2;
wavefile{filename = "A_12_dn.wav";}A_d_1p2;
wavefile{filename = "A_13_up.wav";}A_u_1p3;
wavefile{filename = "A_13_dn.wav";}A_d_1p3;
wavefile{filename = "A_14_up.wav";}A_u_1p4;
wavefile{filename = "A_14_dn.wav";}A_d_1p4;
wavefile{filename = "A_15_up.wav";}A_u_1p5;
wavefile{filename = "A_15_dn.wav";}A_d_1p5;
wavefile{filename = "A_16_up.wav";}A_u_1p6;
wavefile{filename = "A_16_dn.wav";}A_d_1p6;
wavefile{filename = "A_17_up.wav";}A_u_1p7;
wavefile{filename = "A_17_dn.wav";}A_d_1p7;
wavefile{filename = "A_18_up.wav";}A_u_1p8;
wavefile{filename = "A_18_dn.wav";}A_d_1p8;
wavefile{filename = "A_19_up.wav";}A_u_1p9;
wavefile{filename = "A_19_dn.wav";}A_d_1p9;
wavefile{filename = "A_20_up.wav";}A_u_2p0;
wavefile{filename = "A_20_dn.wav";}A_d_2p0;
wavefile{filename = "A_21_up.wav";}A_u_2p1;
wavefile{filename = "A_21_dn.wav";}A_d_2p1;
wavefile{filename = "A_22_up.wav";}A_u_2p2;
wavefile{filename = "A_22_dn.wav";}A_d_2p2;
wavefile{filename = "A_23_up.wav";}A_u_2p3;
wavefile{filename = "A_23_dn.wav";}A_d_2p3;
wavefile{filename = "A_24_up.wav";}A_u_2p4;
wavefile{filename = "A_24_dn.wav";}A_d_2p4;
wavefile{filename = "A_25_up.wav";}A_u_2p5;
wavefile{filename = "A_25_dn.wav";}A_d_2p5;
wavefile{filename = "A_26_up.wav";}A_u_2p6;
wavefile{filename = "A_26_dn.wav";}A_d_2p6;
wavefile{filename = "A_27_up.wav";}A_u_2p7;
wavefile{filename = "A_27_dn.wav";}A_d_2p7;
wavefile{filename = "A_28_up.wav";}A_u_2p8;
wavefile{filename = "A_28_dn.wav";}A_d_2p8;
wavefile{filename = "A_29_up.wav";}A_u_2p9;
wavefile{filename = "A_29_dn.wav";}A_d_2p9;
wavefile{filename = "A_30_up.wav";}A_u_3p0;
wavefile{filename = "A_30_dn.wav";}A_d_3p0;
wavefile{filename = "A_31_up.wav";}A_u_3p1;
wavefile{filename = "A_31_dn.wav";}A_d_3p1;
wavefile{filename = "A_32_up.wav";}A_u_3p2;
wavefile{filename = "A_32_dn.wav";}A_d_3p2;
wavefile{filename = "A_33_up.wav";}A_u_3p3;
wavefile{filename = "A_33_dn.wav";}A_d_3p3;
wavefile{filename = "A_34_up.wav";}A_u_3p4;
wavefile{filename = "A_34_dn.wav";}A_d_3p4;
wavefile{filename = "A_35_up.wav";}A_u_3p5;
wavefile{filename = "A_35_dn.wav";}A_d_3p5;
wavefile{filename = "A_36_up.wav";}A_u_3p6;
wavefile{filename = "A_36_dn.wav";}A_d_3p6;
wavefile{filename = "A_37_up.wav";}A_u_3p7;
wavefile{filename = "A_37_dn.wav";}A_d_3p7;
wavefile{filename = "A_38_up.wav";}A_u_3p8;
wavefile{filename = "A_38_dn.wav";}A_d_3p8;
wavefile{filename = "A_39_up.wav";}A_u_3p9;
wavefile{filename = "A_39_dn.wav";}A_d_3p9;
wavefile{filename = "A_40_up.wav";}A_u_4p0;
wavefile{filename = "A_40_dn.wav";}A_d_4p0;
wavefile{filename = "A_41_up.wav";}A_u_4p1;
wavefile{filename = "A_41_dn.wav";}A_d_4p1;
wavefile{filename = "A_42_up.wav";}A_u_4p2;
wavefile{filename = "A_42_dn.wav";}A_d_4p2;
wavefile{filename = "A_43_up.wav";}A_u_4p3;
wavefile{filename = "A_43_dn.wav";}A_d_4p3;
wavefile{filename = "A_44_up.wav";}A_u_4p4;
wavefile{filename = "A_44_dn.wav";}A_d_4p4;
wavefile{filename = "A_45_up.wav";}A_u_4p5;
wavefile{filename = "A_45_dn.wav";}A_d_4p5;
wavefile{filename = "A_46_up.wav";}A_u_4p6;
wavefile{filename = "A_46_dn.wav";}A_d_4p6;
wavefile{filename = "A_47_up.wav";}A_u_4p7;
wavefile{filename = "A_47_dn.wav";}A_d_4p7;
wavefile{filename = "A_48_up.wav";}A_u_4p8;
wavefile{filename = "A_48_dn.wav";}A_d_4p8;
wavefile{filename = "A_49_up.wav";}A_u_4p9;
wavefile{filename = "A_49_dn.wav";}A_d_4p9;
wavefile{filename = "A_50_up.wav";}A_u_5p0;
wavefile{filename = "A_50_dn.wav";}A_d_5p0;
wavefile{filename = "A_51_up.wav";}A_u_5p1;
wavefile{filename = "A_51_dn.wav";}A_d_5p1;
wavefile{filename = "A_52_up.wav";}A_u_5p2;
wavefile{filename = "A_52_dn.wav";}A_d_5p2;
wavefile{filename = "A_53_up.wav";}A_u_5p3;
wavefile{filename = "A_53_dn.wav";}A_d_5p3;
wavefile{filename = "A_54_up.wav";}A_u_5p4;
wavefile{filename = "A_54_dn.wav";}A_d_5p4;
wavefile{filename = "A_55_up.wav";}A_u_5p5;
wavefile{filename = "A_55_dn.wav";}A_d_5p5;
wavefile{filename = "A_56_up.wav";}A_u_5p6;
wavefile{filename = "A_56_dn.wav";}A_d_5p6;
wavefile{filename = "A_57_up.wav";}A_u_5p7;
wavefile{filename = "A_57_dn.wav";}A_d_5p7;
wavefile{filename = "A_58_up.wav";}A_u_5p8;
wavefile{filename = "A_58_dn.wav";}A_d_5p8;
wavefile{filename = "A_59_up.wav";}A_u_5p9;
wavefile{filename = "A_59_dn.wav";}A_d_5p9;
wavefile{filename = "A_60_up.wav";}A_u_6p0;
wavefile{filename = "A_60_dn.wav";}A_d_6p0;
wavefile{filename = "A_61_up.wav";}A_u_6p1;
wavefile{filename = "A_61_dn.wav";}A_d_6p1;
wavefile{filename = "A_62_up.wav";}A_u_6p2;
wavefile{filename = "A_62_dn.wav";}A_d_6p2;
wavefile{filename = "A_63_up.wav";}A_u_6p3;
wavefile{filename = "A_63_dn.wav";}A_d_6p3;
wavefile{filename = "A_64_up.wav";}A_u_6p4;
wavefile{filename = "A_64_dn.wav";}A_d_6p4;
wavefile{filename = "A_65_up.wav";}A_u_6p5;
wavefile{filename = "A_65_dn.wav";}A_d_6p5;
wavefile{filename = "A_66_up.wav";}A_u_6p6;
wavefile{filename = "A_66_dn.wav";}A_d_6p6;
wavefile{filename = "A_67_up.wav";}A_u_6p7;
wavefile{filename = "A_67_dn.wav";}A_d_6p7;
wavefile{filename = "A_68_up.wav";}A_u_6p8;
wavefile{filename = "A_68_dn.wav";}A_d_6p8;
wavefile{filename = "A_69_up.wav";}A_u_6p9;
wavefile{filename = "A_69_dn.wav";}A_d_6p9;
wavefile{filename = "A_70_up.wav";}A_u_7p0;
wavefile{filename = "A_70_dn.wav";}A_d_7p0;
wavefile{filename = "A_71_up.wav";}A_u_7p1;
wavefile{filename = "A_71_dn.wav";}A_d_7p1;
wavefile{filename = "A_72_up.wav";}A_u_7p2;
wavefile{filename = "A_72_dn.wav";}A_d_7p2;
wavefile{filename = "A_73_up.wav";}A_u_7p3;
wavefile{filename = "A_73_dn.wav";}A_d_7p3;
wavefile{filename = "A_74_up.wav";}A_u_7p4;
wavefile{filename = "A_74_dn.wav";}A_d_7p4;
wavefile{filename = "A_75_up.wav";}A_u_7p5;
wavefile{filename = "A_75_dn.wav";}A_d_7p5;
wavefile{filename = "A_76_up.wav";}A_u_7p6;
wavefile{filename = "A_76_dn.wav";}A_d_7p6;
wavefile{filename = "A_77_up.wav";}A_u_7p7;
wavefile{filename = "A_77_dn.wav";}A_d_7p7;
wavefile{filename = "A_78_up.wav";}A_u_7p8;
wavefile{filename = "A_78_dn.wav";}A_d_7p8;
wavefile{filename = "A_79_up.wav";}A_u_7p9;
wavefile{filename = "A_79_dn.wav";}A_d_7p9;
wavefile{filename = "A_80_up.wav";}A_u_8p0;
wavefile{filename = "A_80_dn.wav";}A_d_8p0;
wavefile{filename = "A_81_up.wav";}A_u_8p1;
wavefile{filename = "A_81_dn.wav";}A_d_8p1;
wavefile{filename = "A_82_up.wav";}A_u_8p2;
wavefile{filename = "A_82_dn.wav";}A_d_8p2;
wavefile{filename = "A_83_up.wav";}A_u_8p3;
wavefile{filename = "A_83_dn.wav";}A_d_8p3;
wavefile{filename = "A_84_up.wav";}A_u_8p4;
wavefile{filename = "A_84_dn.wav";}A_d_8p4;
wavefile{filename = "A_85_up.wav";}A_u_8p5;
wavefile{filename = "A_85_dn.wav";}A_d_8p5;
wavefile{filename = "A_86_up.wav";}A_u_8p6;
wavefile{filename = "A_86_dn.wav";}A_d_8p6;
wavefile{filename = "A_87_up.wav";}A_u_8p7;
wavefile{filename = "A_87_dn.wav";}A_d_8p7;
wavefile{filename = "A_88_up.wav";}A_u_8p8;
wavefile{filename = "A_88_dn.wav";}A_d_8p8;
wavefile{filename = "A_89_up.wav";}A_u_8p9;
wavefile{filename = "A_89_dn.wav";}A_d_8p9;
wavefile{filename = "A_90_up.wav";}A_u_9p0;
wavefile{filename = "A_90_dn.wav";}A_d_9p0;
wavefile{filename = "A_91_up.wav";}A_u_9p1;
wavefile{filename = "A_91_dn.wav";}A_d_9p1;
wavefile{filename = "A_92_up.wav";}A_u_9p2;
wavefile{filename = "A_92_dn.wav";}A_d_9p2;
wavefile{filename = "A_93_up.wav";}A_u_9p3;
wavefile{filename = "A_93_dn.wav";}A_d_9p3;
wavefile{filename = "A_94_up.wav";}A_u_9p4;
wavefile{filename = "A_94_dn.wav";}A_d_9p4;
wavefile{filename = "A_95_up.wav";}A_u_9p5;
wavefile{filename = "A_95_dn.wav";}A_d_9p5;
wavefile{filename = "A_96_up.wav";}A_u_9p6;
wavefile{filename = "A_96_dn.wav";}A_d_9p6;
wavefile{filename = "A_97_up.wav";}A_u_9p7;
wavefile{filename = "A_97_dn.wav";}A_d_9p7;
wavefile{filename = "A_98_up.wav";}A_u_9p8;
wavefile{filename = "A_98_dn.wav";}A_d_9p8;
wavefile{filename = "A_99_up.wav";}A_u_9p9;
wavefile{filename = "A_99_dn.wav";}A_d_9p9;
wavefile{filename = "A_100_up.wav";}A_u_10p0;
wavefile{filename = "A_100_dn.wav";}A_d_10p0;
wavefile{filename = "A_101_up.wav";}A_u_10p1;
wavefile{filename = "A_101_dn.wav";}A_d_10p1;
wavefile{filename = "A_102_up.wav";}A_u_10p2;
wavefile{filename = "A_102_dn.wav";}A_d_10p2;
wavefile{filename = "A_103_up.wav";}A_u_10p3;
wavefile{filename = "A_103_dn.wav";}A_d_10p3;
wavefile{filename = "A_104_up.wav";}A_u_10p4;
wavefile{filename = "A_104_dn.wav";}A_d_10p4;
wavefile{filename = "A_105_up.wav";}A_u_10p5;
wavefile{filename = "A_105_dn.wav";}A_d_10p5;
wavefile{filename = "A_106_up.wav";}A_u_10p6;
wavefile{filename = "A_106_dn.wav";}A_d_10p6;
wavefile{filename = "A_107_up.wav";}A_u_10p7;
wavefile{filename = "A_107_dn.wav";}A_d_10p7;
wavefile{filename = "A_108_up.wav";}A_u_10p8;
wavefile{filename = "A_108_dn.wav";}A_d_10p8;
wavefile{filename = "A_109_up.wav";}A_u_10p9;
wavefile{filename = "A_109_dn.wav";}A_d_10p9;
wavefile{filename = "A_110_up.wav";}A_u_11p0;
wavefile{filename = "A_110_dn.wav";}A_d_11p0;
wavefile{filename = "A_111_up.wav";}A_u_11p1;
wavefile{filename = "A_111_dn.wav";}A_d_11p1;
wavefile{filename = "A_112_up.wav";}A_u_11p2;
wavefile{filename = "A_112_dn.wav";}A_d_11p2;
wavefile{filename = "A_113_up.wav";}A_u_11p3;
wavefile{filename = "A_113_dn.wav";}A_d_11p3;
wavefile{filename = "A_114_up.wav";}A_u_11p4;
wavefile{filename = "A_114_dn.wav";}A_d_11p4;
wavefile{filename = "A_115_up.wav";}A_u_11p5;
wavefile{filename = "A_115_dn.wav";}A_d_11p5;
wavefile{filename = "A_116_up.wav";}A_u_11p6;
wavefile{filename = "A_116_dn.wav";}A_d_11p6;
wavefile{filename = "A_117_up.wav";}A_u_11p7;
wavefile{filename = "A_117_dn.wav";}A_d_11p7;
wavefile{filename = "A_118_up.wav";}A_u_11p8;
wavefile{filename = "A_118_dn.wav";}A_d_11p8;
wavefile{filename = "A_119_up.wav";}A_u_11p9;
wavefile{filename = "A_119_dn.wav";}A_d_11p9;
wavefile{filename = "A_120_up.wav";}A_u_12p0;
wavefile{filename = "A_120_dn.wav";}A_d_12p0;
wavefile{filename = "A_121_up.wav";}A_u_12p1;
wavefile{filename = "A_121_dn.wav";}A_d_12p1;
wavefile{filename = "A_122_up.wav";}A_u_12p2;
wavefile{filename = "A_122_dn.wav";}A_d_12p2;
wavefile{filename = "A_123_up.wav";}A_u_12p3;
wavefile{filename = "A_123_dn.wav";}A_d_12p3;
wavefile{filename = "A_124_up.wav";}A_u_12p4;
wavefile{filename = "A_124_dn.wav";}A_d_12p4;
wavefile{filename = "A_125_up.wav";}A_u_12p5;
wavefile{filename = "A_125_dn.wav";}A_d_12p5;
wavefile{filename = "A_126_up.wav";}A_u_12p6;
wavefile{filename = "A_126_dn.wav";}A_d_12p6;
wavefile{filename = "A_127_up.wav";}A_u_12p7;
wavefile{filename = "A_127_dn.wav";}A_d_12p7;
wavefile{filename = "A_128_up.wav";}A_u_12p8;
wavefile{filename = "A_128_dn.wav";}A_d_12p8;
wavefile{filename = "A_129_up.wav";}A_u_12p9;
wavefile{filename = "A_129_dn.wav";}A_d_12p9;
wavefile{filename = "A_130_up.wav";}A_u_13p0;
wavefile{filename = "A_130_dn.wav";}A_d_13p0;
wavefile{filename = "A_131_up.wav";}A_u_13p1;
wavefile{filename = "A_131_dn.wav";}A_d_13p1;
wavefile{filename = "A_132_up.wav";}A_u_13p2;
wavefile{filename = "A_132_dn.wav";}A_d_13p2;
wavefile{filename = "A_133_up.wav";}A_u_13p3;
wavefile{filename = "A_133_dn.wav";}A_d_13p3;
wavefile{filename = "A_134_up.wav";}A_u_13p4;
wavefile{filename = "A_134_dn.wav";}A_d_13p4;
wavefile{filename = "A_135_up.wav";}A_u_13p5;
wavefile{filename = "A_135_dn.wav";}A_d_13p5;
wavefile{filename = "A_136_up.wav";}A_u_13p6;
wavefile{filename = "A_136_dn.wav";}A_d_13p6;
wavefile{filename = "A_137_up.wav";}A_u_13p7;
wavefile{filename = "A_137_dn.wav";}A_d_13p7;
wavefile{filename = "A_138_up.wav";}A_u_13p8;
wavefile{filename = "A_138_dn.wav";}A_d_13p8;
wavefile{filename = "A_139_up.wav";}A_u_13p9;
wavefile{filename = "A_139_dn.wav";}A_d_13p9;
wavefile{filename = "A_140_up.wav";}A_u_14p0;
wavefile{filename = "A_140_dn.wav";}A_d_14p0;
wavefile{filename = "A_141_up.wav";}A_u_14p1;
wavefile{filename = "A_141_dn.wav";}A_d_14p1;
wavefile{filename = "A_142_up.wav";}A_u_14p2;
wavefile{filename = "A_142_dn.wav";}A_d_14p2;
wavefile{filename = "A_143_up.wav";}A_u_14p3;
wavefile{filename = "A_143_dn.wav";}A_d_14p3;
wavefile{filename = "A_144_up.wav";}A_u_14p4;
wavefile{filename = "A_144_dn.wav";}A_d_14p4;
wavefile{filename = "A_145_up.wav";}A_u_14p5;
wavefile{filename = "A_145_dn.wav";}A_d_14p5;
wavefile{filename = "A_146_up.wav";}A_u_14p6;
wavefile{filename = "A_146_dn.wav";}A_d_14p6;
wavefile{filename = "A_147_up.wav";}A_u_14p7;
wavefile{filename = "A_147_dn.wav";}A_d_14p7;
wavefile{filename = "A_148_up.wav";}A_u_14p8;
wavefile{filename = "A_148_dn.wav";}A_d_14p8;
wavefile{filename = "A_149_up.wav";}A_u_14p9;
wavefile{filename = "A_149_dn.wav";}A_d_14p9;
wavefile{filename = "A_150_up.wav";}A_u_15p0;
wavefile{filename = "A_150_dn.wav";}A_d_15p0;
wavefile{filename = "A_151_up.wav";}A_u_15p1;
wavefile{filename = "A_151_dn.wav";}A_d_15p1;
wavefile{filename = "A_152_up.wav";}A_u_15p2;
wavefile{filename = "A_152_dn.wav";}A_d_15p2;
wavefile{filename = "A_153_up.wav";}A_u_15p3;
wavefile{filename = "A_153_dn.wav";}A_d_15p3;
wavefile{filename = "A_154_up.wav";}A_u_15p4;
wavefile{filename = "A_154_dn.wav";}A_d_15p4;
wavefile{filename = "A_155_up.wav";}A_u_15p5;
wavefile{filename = "A_155_dn.wav";}A_d_15p5;
wavefile{filename = "A_156_up.wav";}A_u_15p6;
wavefile{filename = "A_156_dn.wav";}A_d_15p6;
wavefile{filename = "A_157_up.wav";}A_u_15p7;
wavefile{filename = "A_157_dn.wav";}A_d_15p7;
wavefile{filename = "A_158_up.wav";}A_u_15p8;
wavefile{filename = "A_158_dn.wav";}A_d_15p8;
wavefile{filename = "A_159_up.wav";}A_u_15p9;
wavefile{filename = "A_159_dn.wav";}A_d_15p9;
wavefile{filename = "A_160_up.wav";}A_u_16p0;
wavefile{filename = "A_160_dn.wav";}A_d_16p0;
wavefile{filename = "A_161_up.wav";}A_u_16p1;
wavefile{filename = "A_161_dn.wav";}A_d_16p1;
wavefile{filename = "A_162_up.wav";}A_u_16p2;
wavefile{filename = "A_162_dn.wav";}A_d_16p2;
wavefile{filename = "A_163_up.wav";}A_u_16p3;
wavefile{filename = "A_163_dn.wav";}A_d_16p3;
wavefile{filename = "A_164_up.wav";}A_u_16p4;
wavefile{filename = "A_164_dn.wav";}A_d_16p4;
wavefile{filename = "A_165_up.wav";}A_u_16p5;
wavefile{filename = "A_165_dn.wav";}A_d_16p5;
wavefile{filename = "A_166_up.wav";}A_u_16p6;
wavefile{filename = "A_166_dn.wav";}A_d_16p6;
wavefile{filename = "A_167_up.wav";}A_u_16p7;
wavefile{filename = "A_167_dn.wav";}A_d_16p7;
wavefile{filename = "A_168_up.wav";}A_u_16p8;
wavefile{filename = "A_168_dn.wav";}A_d_16p8;
wavefile{filename = "A_169_up.wav";}A_u_16p9;
wavefile{filename = "A_169_dn.wav";}A_d_16p9;
wavefile{filename = "A_170_up.wav";}A_u_17p0;
wavefile{filename = "A_170_dn.wav";}A_d_17p0;
wavefile{filename = "A_171_up.wav";}A_u_17p1;
wavefile{filename = "A_171_dn.wav";}A_d_17p1;
wavefile{filename = "A_172_up.wav";}A_u_17p2;
wavefile{filename = "A_172_dn.wav";}A_d_17p2;
wavefile{filename = "A_173_up.wav";}A_u_17p3;
wavefile{filename = "A_173_dn.wav";}A_d_17p3;
wavefile{filename = "A_174_up.wav";}A_u_17p4;
wavefile{filename = "A_174_dn.wav";}A_d_17p4;
wavefile{filename = "A_175_up.wav";}A_u_17p5;
wavefile{filename = "A_175_dn.wav";}A_d_17p5;
wavefile{filename = "A_176_up.wav";}A_u_17p6;
wavefile{filename = "A_176_dn.wav";}A_d_17p6;
wavefile{filename = "A_177_up.wav";}A_u_17p7;
wavefile{filename = "A_177_dn.wav";}A_d_17p7;
wavefile{filename = "A_178_up.wav";}A_u_17p8;
wavefile{filename = "A_178_dn.wav";}A_d_17p8;
wavefile{filename = "A_179_up.wav";}A_u_17p9;
wavefile{filename = "A_179_dn.wav";}A_d_17p9;
wavefile{filename = "A_180_up.wav";}A_u_18p0;
wavefile{filename = "A_180_dn.wav";}A_d_18p0;

#STANDARD trials 
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "0_1";
		port_code = 50;}A_0_1;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 2;
		code = "0_2";
		port_code = 50;}A_0_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_0p1;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "0.1_1";
		port_code = 50;}A_0p1_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_0p1;};
		time = 1000;
		target_button = 2;
		code = "0.1_2";
		port_code = 60;}A_0p1_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_0p2;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "0.2_1";
		port_code = 50;}A_0p2_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_0p2;};
		time = 1000;
		target_button = 2;
		code = "0.2_2";
		port_code = 60;}A_0p2_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_0p3;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "0.3_1";
		port_code = 50;}A_0p3_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_0p3;};
		time = 1000;
		target_button = 2;
		code = "0.3_2";
		port_code = 60;}A_0p3_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_0p4;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "0.4_1";
		port_code = 50;}A_0p4_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_0p4;};
		time = 1000;
		target_button = 2;
		code = "0.4_2";
		port_code = 60;}A_0p4_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_0p5;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "0.5_1";
		port_code = 50;}A_0p5_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_0p5;};
		time = 1000;
		target_button = 2;
		code = "0.5_2";
		port_code = 60;}A_0p5_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_0p6;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "0.6_1";
		port_code = 50;}A_0p6_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_0p6;};
		time = 1000;
		target_button = 2;
		code = "0.6_2";
		port_code = 60;}A_0p6_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_0p7;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "0.7_1";
		port_code = 50;}A_0p7_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_0p7;};
		time = 1000;
		target_button = 2;
		code = "0.7_2";
		port_code = 60;}A_0p7_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_0p8;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "0.8_1";
		port_code = 50;}A_0p8_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_0p8;};
		time = 1000;
		target_button = 2;
		code = "0.8_2";
		port_code = 60;}A_0p8_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_0p9;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "0.9_1";
		port_code = 50;}A_0p9_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_0p9;};
		time = 1000;
		target_button = 2;
		code = "0.9_2";
		port_code = 60;}A_0p9_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_1p0;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "1.0_1";
		port_code = 50;}A_1p0_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_1p0;};
		time = 1000;
		target_button = 2;
		code = "1.0_2";
		port_code = 60;}A_1p0_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_1p1;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "1.1_1";
		port_code = 50;}A_1p1_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_1p1;};
		time = 1000;
		target_button = 2;
		code = "1.1_2";
		port_code = 60;}A_1p1_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_1p2;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "1.2_1";
		port_code = 50;}A_1p2_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_1p2;};
		time = 1000;
		target_button = 2;
		code = "1.2_2";
		port_code = 60;}A_1p2_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_1p3;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "1.3_1";
		port_code = 50;}A_1p3_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_1p3;};
		time = 1000;
		target_button = 2;
		code = "1.3_2";
		port_code = 60;}A_1p3_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_1p4;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "1.4_1";
		port_code = 50;}A_1p4_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_1p4;};
		time = 1000;
		target_button = 2;
		code = "1.4_2";
		port_code = 60;}A_1p4_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_1p5;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "1.5_1";
		port_code = 50;}A_1p5_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_1p5;};
		time = 1000;
		target_button = 2;
		code = "1.5_2";
		port_code = 60;}A_1p5_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_1p6;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "1.6_1";
		port_code = 50;}A_1p6_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_1p6;};
		time = 1000;
		target_button = 2;
		code = "1.6_2";
		port_code = 60;}A_1p6_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_1p7;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "1.7_1";
		port_code = 50;}A_1p7_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_1p7;};
		time = 1000;
		target_button = 2;
		code = "1.7_2";
		port_code = 60;}A_1p7_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_1p8;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "1.8_1";
		port_code = 50;}A_1p8_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_1p8;};
		time = 1000;
		target_button = 2;
		code = "1.8_2";
		port_code = 60;}A_1p8_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_1p9;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "1.9_1";
		port_code = 50;}A_1p9_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_1p9;};
		time = 1000;
		target_button = 2;
		code = "1.9_2";
		port_code = 60;}A_1p9_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_2p0;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "2.0_1";
		port_code = 50;}A_2p0_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_2p0;};
		time = 1000;
		target_button = 2;
		code = "2.0_2";
		port_code = 60;}A_2p0_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_2p1;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "2.1_1";
		port_code = 50;}A_2p1_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_2p1;};
		time = 1000;
		target_button = 2;
		code = "2.1_2";
		port_code = 60;}A_2p1_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_2p2;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "2.2_1";
		port_code = 50;}A_2p2_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_2p2;};
		time = 1000;
		target_button = 2;
		code = "2.2_2";
		port_code = 60;}A_2p2_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_2p3;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "2.3_1";
		port_code = 50;}A_2p3_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_2p3;};
		time = 1000;
		target_button = 2;
		code = "2.3_2";
		port_code = 60;}A_2p3_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_2p4;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "2.4_1";
		port_code = 50;}A_2p4_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_2p4;};
		time = 1000;
		target_button = 2;
		code = "2.4_2";
		port_code = 60;}A_2p4_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_2p5;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "2.5_1";
		port_code = 50;}A_2p5_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_2p5;};
		time = 1000;
		target_button = 2;
		code = "2.5_2";
		port_code = 60;}A_2p5_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_2p6;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "2.6_1";
		port_code = 50;}A_2p6_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_2p6;};
		time = 1000;
		target_button = 2;
		code = "2.6_2";
		port_code = 60;}A_2p6_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_2p7;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "2.7_1";
		port_code = 50;}A_2p7_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_2p7;};
		time = 1000;
		target_button = 2;
		code = "2.7_2";
		port_code = 60;}A_2p7_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_2p8;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "2.8_1";
		port_code = 50;}A_2p8_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_2p8;};
		time = 1000;
		target_button = 2;
		code = "2.8_2";
		port_code = 60;}A_2p8_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_2p9;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "2.9_1";
		port_code = 50;}A_2p9_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_2p9;};
		time = 1000;
		target_button = 2;
		code = "2.9_2";
		port_code = 60;}A_2p9_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_3p0;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "3.0_1";
		port_code = 50;}A_3p0_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_3p0;};
		time = 1000;
		target_button = 2;
		code = "3.0_2";
		port_code = 60;}A_3p0_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_3p1;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "3.1_1";
		port_code = 50;}A_3p1_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_3p1;};
		time = 1000;
		target_button = 2;
		code = "3.1_2";
		port_code = 60;}A_3p1_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_3p2;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "3.2_1";
		port_code = 50;}A_3p2_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_3p2;};
		time = 1000;
		target_button = 2;
		code = "3.2_2";
		port_code = 60;}A_3p2_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_3p3;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "3.3_1";
		port_code = 50;}A_3p3_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_3p3;};
		time = 1000;
		target_button = 2;
		code = "3.3_2";
		port_code = 60;}A_3p3_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_3p4;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "3.4_1";
		port_code = 50;}A_3p4_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_3p4;};
		time = 1000;
		target_button = 2;
		code = "3.4_2";
		port_code = 60;}A_3p4_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_3p5;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "3.5_1";
		port_code = 50;}A_3p5_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_3p5;};
		time = 1000;
		target_button = 2;
		code = "3.5_2";
		port_code = 60;}A_3p5_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_3p6;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "3.6_1";
		port_code = 50;}A_3p6_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_3p6;};
		time = 1000;
		target_button = 2;
		code = "3.6_2";
		port_code = 60;}A_3p6_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_3p7;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "3.7_1";
		port_code = 50;}A_3p7_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_3p7;};
		time = 1000;
		target_button = 2;
		code = "3.7_2";
		port_code = 60;}A_3p7_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_3p8;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "3.8_1";
		port_code = 50;}A_3p8_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_3p8;};
		time = 1000;
		target_button = 2;
		code = "3.8_2";
		port_code = 60;}A_3p8_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_3p9;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "3.9_1";
		port_code = 50;}A_3p9_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_3p9;};
		time = 1000;
		target_button = 2;
		code = "3.9_2";
		port_code = 60;}A_3p9_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_4p0;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "4.0_1";
		port_code = 50;}A_4p0_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_4p0;};
		time = 1000;
		target_button = 2;
		code = "4.0_2";
		port_code = 60;}A_4p0_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_4p1;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "4.1_1";
		port_code = 50;}A_4p1_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_4p1;};
		time = 1000;
		target_button = 2;
		code = "4.1_2";
		port_code = 60;}A_4p1_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_4p2;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "4.2_1";
		port_code = 50;}A_4p2_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_4p2;};
		time = 1000;
		target_button = 2;
		code = "4.2_2";
		port_code = 60;}A_4p2_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_4p3;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "4.3_1";
		port_code = 50;}A_4p3_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_4p3;};
		time = 1000;
		target_button = 2;
		code = "4.3_2";
		port_code = 60;}A_4p3_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_4p4;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "4.4_1";
		port_code = 50;}A_4p4_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_4p4;};
		time = 1000;
		target_button = 2;
		code = "4.4_2";
		port_code = 60;}A_4p4_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_4p5;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "4.5_1";
		port_code = 50;}A_4p5_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_4p5;};
		time = 1000;
		target_button = 2;
		code = "4.5_2";
		port_code = 60;}A_4p5_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_4p6;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "4.6_1";
		port_code = 50;}A_4p6_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_4p6;};
		time = 1000;
		target_button = 2;
		code = "4.6_2";
		port_code = 60;}A_4p6_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_4p7;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "4.7_1";
		port_code = 50;}A_4p7_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_4p7;};
		time = 1000;
		target_button = 2;
		code = "4.7_2";
		port_code = 60;}A_4p7_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_4p8;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "4.8_1";
		port_code = 50;}A_4p8_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_4p8;};
		time = 1000;
		target_button = 2;
		code = "4.8_2";
		port_code = 60;}A_4p8_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_4p9;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "4.9_1";
		port_code = 50;}A_4p9_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_4p9;};
		time = 1000;
		target_button = 2;
		code = "4.9_2";
		port_code = 60;}A_4p9_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_5p0;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "5.0_1";
		port_code = 50;}A_5p0_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_5p0;};
		time = 1000;
		target_button = 2;
		code = "5.0_2";
		port_code = 60;}A_5p0_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_5p1;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "5.1_1";
		port_code = 50;}A_5p1_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_5p1;};
		time = 1000;
		target_button = 2;
		code = "5.1_2";
		port_code = 60;}A_5p1_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_5p2;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "5.2_1";
		port_code = 50;}A_5p2_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_5p2;};
		time = 1000;
		target_button = 2;
		code = "5.2_2";
		port_code = 60;}A_5p2_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_5p3;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "5.3_1";
		port_code = 50;}A_5p3_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_5p3;};
		time = 1000;
		target_button = 2;
		code = "5.3_2";
		port_code = 60;}A_5p3_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_5p4;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "5.4_1";
		port_code = 50;}A_5p4_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_5p4;};
		time = 1000;
		target_button = 2;
		code = "5.4_2";
		port_code = 60;}A_5p4_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_5p5;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "5.5_1";
		port_code = 50;}A_5p5_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_5p5;};
		time = 1000;
		target_button = 2;
		code = "5.5_2";
		port_code = 60;}A_5p5_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_5p6;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "5.6_1";
		port_code = 50;}A_5p6_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_5p6;};
		time = 1000;
		target_button = 2;
		code = "5.6_2";
		port_code = 60;}A_5p6_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_5p7;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "5.7_1";
		port_code = 50;}A_5p7_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_5p7;};
		time = 1000;
		target_button = 2;
		code = "5.7_2";
		port_code = 60;}A_5p7_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_5p8;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "5.8_1";
		port_code = 50;}A_5p8_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_5p8;};
		time = 1000;
		target_button = 2;
		code = "5.8_2";
		port_code = 60;}A_5p8_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_5p9;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "5.9_1";
		port_code = 50;}A_5p9_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_5p9;};
		time = 1000;
		target_button = 2;
		code = "5.9_2";
		port_code = 60;}A_5p9_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_6p0;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "6.0_1";
		port_code = 50;}A_6p0_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_6p0;};
		time = 1000;
		target_button = 2;
		code = "6.0_2";
		port_code = 60;}A_6p0_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_6p1;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "6.1_1";
		port_code = 50;}A_6p1_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_6p1;};
		time = 1000;
		target_button = 2;
		code = "6.1_2";
		port_code = 60;}A_6p1_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_6p2;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "6.2_1";
		port_code = 50;}A_6p2_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_6p2;};
		time = 1000;
		target_button = 2;
		code = "6.2_2";
		port_code = 60;}A_6p2_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_6p3;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "6.3_1";
		port_code = 50;}A_6p3_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_6p3;};
		time = 1000;
		target_button = 2;
		code = "6.3_2";
		port_code = 60;}A_6p3_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_6p4;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "6.4_1";
		port_code = 50;}A_6p4_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_6p4;};
		time = 1000;
		target_button = 2;
		code = "6.4_2";
		port_code = 60;}A_6p4_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_6p5;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "6.5_1";
		port_code = 50;}A_6p5_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_6p5;};
		time = 1000;
		target_button = 2;
		code = "6.5_2";
		port_code = 60;}A_6p5_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_6p6;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "6.6_1";
		port_code = 50;}A_6p6_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_6p6;};
		time = 1000;
		target_button = 2;
		code = "6.6_2";
		port_code = 60;}A_6p6_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_6p7;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "6.7_1";
		port_code = 50;}A_6p7_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_6p7;};
		time = 1000;
		target_button = 2;
		code = "6.7_2";
		port_code = 60;}A_6p7_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_6p8;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "6.8_1";
		port_code = 50;}A_6p8_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_6p8;};
		time = 1000;
		target_button = 2;
		code = "6.8_2";
		port_code = 60;}A_6p8_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_6p9;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "6.9_1";
		port_code = 50;}A_6p9_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_6p9;};
		time = 1000;
		target_button = 2;
		code = "6.9_2";
		port_code = 60;}A_6p9_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_7p0;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "7.0_1";
		port_code = 50;}A_7p0_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_7p0;};
		time = 1000;
		target_button = 2;
		code = "7.0_2";
		port_code = 60;}A_7p0_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_7p1;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "7.1_1";
		port_code = 50;}A_7p1_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_7p1;};
		time = 1000;
		target_button = 2;
		code = "7.1_2";
		port_code = 60;}A_7p1_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_7p2;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "7.2_1";
		port_code = 50;}A_7p2_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_7p2;};
		time = 1000;
		target_button = 2;
		code = "7.2_2";
		port_code = 60;}A_7p2_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_7p3;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "7.3_1";
		port_code = 50;}A_7p3_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_7p3;};
		time = 1000;
		target_button = 2;
		code = "7.3_2";
		port_code = 60;}A_7p3_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_7p4;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "7.4_1";
		port_code = 50;}A_7p4_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_7p4;};
		time = 1000;
		target_button = 2;
		code = "7.4_2";
		port_code = 60;}A_7p4_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_7p5;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "7.5_1";
		port_code = 50;}A_7p5_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_7p5;};
		time = 1000;
		target_button = 2;
		code = "7.5_2";
		port_code = 60;}A_7p5_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_7p6;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "7.6_1";
		port_code = 50;}A_7p6_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_7p6;};
		time = 1000;
		target_button = 2;
		code = "7.6_2";
		port_code = 60;}A_7p6_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_7p7;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "7.7_1";
		port_code = 50;}A_7p7_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_7p7;};
		time = 1000;
		target_button = 2;
		code = "7.7_2";
		port_code = 60;}A_7p7_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_7p8;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "7.8_1";
		port_code = 50;}A_7p8_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_7p8;};
		time = 1000;
		target_button = 2;
		code = "7.8_2";
		port_code = 60;}A_7p8_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_7p9;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "7.9_1";
		port_code = 50;}A_7p9_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_7p9;};
		time = 1000;
		target_button = 2;
		code = "7.9_2";
		port_code = 60;}A_7p9_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_8p0;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "8.0_1";
		port_code = 50;}A_8p0_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_8p0;};
		time = 1000;
		target_button = 2;
		code = "8.0_2";
		port_code = 60;}A_8p0_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_8p1;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "8.1_1";
		port_code = 50;}A_8p1_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_8p1;};
		time = 1000;
		target_button = 2;
		code = "8.1_2";
		port_code = 60;}A_8p1_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_8p2;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "8.2_1";
		port_code = 50;}A_8p2_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_8p2;};
		time = 1000;
		target_button = 2;
		code = "8.2_2";
		port_code = 60;}A_8p2_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_8p3;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "8.3_1";
		port_code = 50;}A_8p3_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_8p3;};
		time = 1000;
		target_button = 2;
		code = "8.3_2";
		port_code = 60;}A_8p3_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_8p4;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "8.4_1";
		port_code = 50;}A_8p4_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_8p4;};
		time = 1000;
		target_button = 2;
		code = "8.4_2";
		port_code = 60;}A_8p4_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_8p5;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "8.5_1";
		port_code = 50;}A_8p5_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_8p5;};
		time = 1000;
		target_button = 2;
		code = "8.5_2";
		port_code = 60;}A_8p5_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_8p6;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "8.6_1";
		port_code = 50;}A_8p6_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_8p6;};
		time = 1000;
		target_button = 2;
		code = "8.6_2";
		port_code = 60;}A_8p6_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_8p7;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "8.7_1";
		port_code = 50;}A_8p7_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_8p7;};
		time = 1000;
		target_button = 2;
		code = "8.7_2";
		port_code = 60;}A_8p7_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_8p8;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "8.8_1";
		port_code = 50;}A_8p8_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_8p8;};
		time = 1000;
		target_button = 2;
		code = "8.8_2";
		port_code = 60;}A_8p8_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_8p9;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "8.9_1";
		port_code = 50;}A_8p9_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_8p9;};
		time = 1000;
		target_button = 2;
		code = "8.9_2";
		port_code = 60;}A_8p9_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_9p0;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "9.0_1";
		port_code = 50;}A_9p0_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_9p0;};
		time = 1000;
		target_button = 2;
		code = "9.0_2";
		port_code = 60;}A_9p0_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_9p1;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "9.1_1";
		port_code = 50;}A_9p1_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_9p1;};
		time = 1000;
		target_button = 2;
		code = "9.1_2";
		port_code = 60;}A_9p1_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_9p2;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "9.2_1";
		port_code = 50;}A_9p2_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_9p2;};
		time = 1000;
		target_button = 2;
		code = "9.2_2";
		port_code = 60;}A_9p2_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_9p3;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "9.3_1";
		port_code = 50;}A_9p3_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_9p3;};
		time = 1000;
		target_button = 2;
		code = "9.3_2";
		port_code = 60;}A_9p3_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_9p4;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "9.4_1";
		port_code = 50;}A_9p4_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_9p4;};
		time = 1000;
		target_button = 2;
		code = "9.4_2";
		port_code = 60;}A_9p4_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_9p5;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "9.5_1";
		port_code = 50;}A_9p5_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_9p5;};
		time = 1000;
		target_button = 2;
		code = "9.5_2";
		port_code = 60;}A_9p5_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_9p6;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "9.6_1";
		port_code = 50;}A_9p6_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_9p6;};
		time = 1000;
		target_button = 2;
		code = "9.6_2";
		port_code = 60;}A_9p6_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_9p7;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "9.7_1";
		port_code = 50;}A_9p7_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_9p7;};
		time = 1000;
		target_button = 2;
		code = "9.7_2";
		port_code = 60;}A_9p7_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_9p8;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "9.8_1";
		port_code = 50;}A_9p8_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_9p8;};
		time = 1000;
		target_button = 2;
		code = "9.8_2";
		port_code = 60;}A_9p8_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_9p9;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "9.9_1";
		port_code = 50;}A_9p9_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_9p9;};
		time = 1000;
		target_button = 2;
		code = "9.9_2";
		port_code = 60;}A_9p9_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_10p0;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "10.0_1";
		port_code = 50;}A_10p0_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_10p0;};
		time = 1000;
		target_button = 2;
		code = "10.0_2";
		port_code = 60;}A_10p0_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_10p1;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "10.1_1";
		port_code = 50;}A_10p1_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_10p1;};
		time = 1000;
		target_button = 2;
		code = "10.1_2";
		port_code = 60;}A_10p1_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_10p2;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "10.2_1";
		port_code = 50;}A_10p2_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_10p2;};
		time = 1000;
		target_button = 2;
		code = "10.2_2";
		port_code = 60;}A_10p2_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_10p3;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "10.3_1";
		port_code = 50;}A_10p3_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_10p3;};
		time = 1000;
		target_button = 2;
		code = "10.3_2";
		port_code = 60;}A_10p3_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_10p4;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "10.4_1";
		port_code = 50;}A_10p4_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_10p4;};
		time = 1000;
		target_button = 2;
		code = "10.4_2";
		port_code = 60;}A_10p4_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_10p5;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "10.5_1";
		port_code = 50;}A_10p5_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_10p5;};
		time = 1000;
		target_button = 2;
		code = "10.5_2";
		port_code = 60;}A_10p5_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_10p6;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "10.6_1";
		port_code = 50;}A_10p6_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_10p6;};
		time = 1000;
		target_button = 2;
		code = "10.6_2";
		port_code = 60;}A_10p6_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_10p7;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "10.7_1";
		port_code = 50;}A_10p7_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_10p7;};
		time = 1000;
		target_button = 2;
		code = "10.7_2";
		port_code = 60;}A_10p7_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_10p8;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "10.8_1";
		port_code = 50;}A_10p8_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_10p8;};
		time = 1000;
		target_button = 2;
		code = "10.8_2";
		port_code = 60;}A_10p8_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_10p9;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "10.9_1";
		port_code = 50;}A_10p9_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_10p9;};
		time = 1000;
		target_button = 2;
		code = "10.9_2";
		port_code = 60;}A_10p9_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_11p0;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "11.0_1";
		port_code = 50;}A_11p0_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_11p0;};
		time = 1000;
		target_button = 2;
		code = "11.0_2";
		port_code = 60;}A_11p0_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_11p1;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "11.1_1";
		port_code = 50;}A_11p1_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_11p1;};
		time = 1000;
		target_button = 2;
		code = "11.1_2";
		port_code = 60;}A_11p1_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_11p2;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "11.2_1";
		port_code = 50;}A_11p2_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_11p2;};
		time = 1000;
		target_button = 2;
		code = "11.2_2";
		port_code = 60;}A_11p2_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_11p3;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "11.3_1";
		port_code = 50;}A_11p3_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_11p3;};
		time = 1000;
		target_button = 2;
		code = "11.3_2";
		port_code = 60;}A_11p3_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_11p4;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "11.4_1";
		port_code = 50;}A_11p4_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_11p4;};
		time = 1000;
		target_button = 2;
		code = "11.4_2";
		port_code = 60;}A_11p4_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_11p5;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "11.5_1";
		port_code = 50;}A_11p5_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_11p5;};
		time = 1000;
		target_button = 2;
		code = "11.5_2";
		port_code = 60;}A_11p5_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_11p6;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "11.6_1";
		port_code = 50;}A_11p6_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_11p6;};
		time = 1000;
		target_button = 2;
		code = "11.6_2";
		port_code = 60;}A_11p6_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_11p7;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "11.7_1";
		port_code = 50;}A_11p7_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_11p7;};
		time = 1000;
		target_button = 2;
		code = "11.7_2";
		port_code = 60;}A_11p7_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_11p8;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "11.8_1";
		port_code = 50;}A_11p8_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_11p8;};
		time = 1000;
		target_button = 2;
		code = "11.8_2";
		port_code = 60;}A_11p8_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_11p9;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "11.9_1";
		port_code = 50;}A_11p9_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_11p9;};
		time = 1000;
		target_button = 2;
		code = "11.9_2";
		port_code = 60;}A_11p9_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_12p0;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "12.0_1";
		port_code = 50;}A_12p0_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_12p0;};
		time = 1000;
		target_button = 2;
		code = "12.0_2";
		port_code = 60;}A_12p0_2;


trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_12p1;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "12.1_1";
		port_code = 50;}A_12p1_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_12p1;};
		time = 1000;
		target_button = 2;
		code = "12.1_2";
		port_code = 60;}A_12p1_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_12p2;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "12.2_1";
		port_code = 50;}A_12p2_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_12p2;};
		time = 1000;
		target_button = 2;
		code = "12.2_2";
		port_code = 60;}A_12p2_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_12p3;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "12.3_1";
		port_code = 50;}A_12p3_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_12p3;};
		time = 1000;
		target_button = 2;
		code = "12.3_2";
		port_code = 60;}A_12p3_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_12p4;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "12.4_1";
		port_code = 50;}A_12p4_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_12p4;};
		time = 1000;
		target_button = 2;
		code = "12.4_2";
		port_code = 60;}A_12p4_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_12p5;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "12.5_1";
		port_code = 50;}A_12p5_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_12p5;};
		time = 1000;
		target_button = 2;
		code = "12.5_2";
		port_code = 60;}A_12p5_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_12p6;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "12.6_1";
		port_code = 50;}A_12p6_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_12p6;};
		time = 1000;
		target_button = 2;
		code = "12.6_2";
		port_code = 60;}A_12p6_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_12p7;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "12.7_1";
		port_code = 50;}A_12p7_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_12p7;};
		time = 1000;
		target_button = 2;
		code = "12.7_2";
		port_code = 60;}A_12p7_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_12p8;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "12.8_1";
		port_code = 50;}A_12p8_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_12p8;};
		time = 1000;
		target_button = 2;
		code = "12.8_2";
		port_code = 60;}A_12p8_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_12p9;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "12.9_1";
		port_code = 50;}A_12p9_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_12p9;};
		time = 1000;
		target_button = 2;
		code = "12.9_2";
		port_code = 60;}A_12p9_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_13p0;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "13.0_1";
		port_code = 50;}A_13p0_1;
		

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_13p0;};
		time = 1000;
		target_button = 2;
		code = "13.0_2";
		port_code = 60;}A_13p0_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_13p1;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "13.1_1";
		port_code = 50;}A_13p1_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_13p1;};
		time = 1000;
		target_button = 2;
		code = "13.1_2";
		port_code = 60;}A_13p1_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_13p2;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "13.2_1";
		port_code = 50;}A_13p2_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_13p2;};
		time = 1000;
		target_button = 2;
		code = "13.2_2";
		port_code = 60;}A_13p2_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_13p3;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "13.3_1";
		port_code = 50;}A_13p3_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_13p3;};
		time = 1000;
		target_button = 2;
		code = "13.3_2";
		port_code = 60;}A_13p3_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_13p4;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "13.4_1";
		port_code = 50;}A_13p4_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_13p4;};
		time = 1000;
		target_button = 2;
		code = "13.4_2";
		port_code = 60;}A_13p4_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_13p5;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "13.5_1";
		port_code = 50;}A_13p5_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_13p5;};
		time = 1000;
		target_button = 2;
		code = "13.5_2";
		port_code = 60;}A_13p5_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_13p6;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "13.6_1";
		port_code = 50;}A_13p6_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_13p6;};
		time = 1000;
		target_button = 2;
		code = "13.6_2";
		port_code = 60;}A_13p6_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_13p7;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "13.7_1";
		port_code = 50;}A_13p7_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_13p7;};
		time = 1000;
		target_button = 2;
		code = "13.7_2";
		port_code = 60;}A_13p7_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_13p8;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "13.8_1";
		port_code = 50;}A_13p8_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_13p8;};
		time = 1000;
		target_button = 2;
		code = "13.8_2";
		port_code = 60;}A_13p8_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_13p9;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "13.9_1";
		port_code = 50;}A_13p9_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_13p9;};
		time = 1000;
		target_button = 2;
		code = "13.9_2";
		port_code = 60;}A_13p9_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_14p0;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "14.0_1";
		port_code = 50;}A_14p0_1;
		

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_14p0;};
		time = 1000;
		target_button = 2;
		code = "14.0_2";
		port_code = 60;}A_14p0_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_14p1;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "14.1_1";
		port_code = 50;}A_14p1_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_14p1;};
		time = 1000;
		target_button = 2;
		code = "14.1_2";
		port_code = 60;}A_14p1_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_14p2;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "14.2_1";
		port_code = 50;}A_14p2_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_14p2;};
		time = 1000;
		target_button = 2;
		code = "14.2_2";
		port_code = 60;}A_14p2_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_14p3;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "14.3_1";
		port_code = 50;}A_14p3_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_14p3;};
		time = 1000;
		target_button = 2;
		code = "14.3_2";
		port_code = 60;}A_14p3_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_14p4;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "14.4_1";
		port_code = 50;}A_14p4_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_14p4;};
		time = 1000;
		target_button = 2;
		code = "14.4_2";
		port_code = 60;}A_14p4_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_14p5;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "14.5_1";
		port_code = 50;}A_14p5_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_14p5;};
		time = 1000;
		target_button = 2;
		code = "14.5_2";
		port_code = 60;}A_14p5_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_14p6;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "14.6_1";
		port_code = 50;}A_14p6_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_14p6;};
		time = 1000;
		target_button = 2;
		code = "14.6_2";
		port_code = 60;}A_14p6_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_14p7;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "14.7_1";
		port_code = 50;}A_14p7_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_14p7;};
		time = 1000;
		target_button = 2;
		code = "14.7_2";
		port_code = 60;}A_14p7_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_14p8;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "14.8_1";
		port_code = 50;}A_14p8_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_14p8;};
		time = 1000;
		target_button = 2;
		code = "14.8_2";
		port_code = 60;}A_14p8_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_14p9;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "14.9_1";
		port_code = 50;}A_14p9_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_14p9;};
		time = 1000;
		target_button = 2;
		code = "14.9_2";
		port_code = 60;}A_14p9_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_15p0;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "15.0_1";
		port_code = 50;}A_15p0_1;
		

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_15p0;};
		time = 1000;
		target_button = 2;
		code = "15.0_2";
		port_code = 60;}A_15p0_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_15p1;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "15.1_1";
		port_code = 50;}A_15p1_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_15p1;};
		time = 1000;
		target_button = 2;
		code = "15.1_2";
		port_code = 60;}A_15p1_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_15p2;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "15.2_1";
		port_code = 50;}A_15p2_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_15p2;};
		time = 1000;
		target_button = 2;
		code = "15.2_2";
		port_code = 60;}A_15p2_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_15p3;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "15.3_1";
		port_code = 50;}A_15p3_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_15p3;};
		time = 1000;
		target_button = 2;
		code = "15.3_2";
		port_code = 60;}A_15p3_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_15p4;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "15.4_1";
		port_code = 50;}A_15p4_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_15p4;};
		time = 1000;
		target_button = 2;
		code = "15.4_2";
		port_code = 60;}A_15p4_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_15p5;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "15.5_1";
		port_code = 50;}A_15p5_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_15p5;};
		time = 1000;
		target_button = 2;
		code = "15.5_2";
		port_code = 60;}A_15p5_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_15p6;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "15.6_1";
		port_code = 50;}A_15p6_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_15p6;};
		time = 1000;
		target_button = 2;
		code = "15.6_2";
		port_code = 60;}A_15p6_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_15p7;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "15.7_1";
		port_code = 50;}A_15p7_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_15p7;};
		time = 1000;
		target_button = 2;
		code = "15.7_2";
		port_code = 60;}A_15p7_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_15p8;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "15.8_1";
		port_code = 50;}A_15p8_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_15p8;};
		time = 1000;
		target_button = 2;
		code = "15.8_2";
		port_code = 60;}A_15p8_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_15p9;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "15.9_1";
		port_code = 50;}A_15p9_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_15p9;};
		time = 1000;
		target_button = 2;
		code = "15.9_2";
		port_code = 60;}A_15p9_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_16p0;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "16.0_1";
		port_code = 50;}A_16p0_1;
		

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_16p0;};
		time = 1000;
		target_button = 2;
		code = "16.0_2";
		port_code = 60;}A_16p0_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_16p1;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "16.1_1";
		port_code = 50;}A_16p1_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_16p1;};
		time = 1000;
		target_button = 2;
		code = "16.1_2";
		port_code = 60;}A_16p1_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_16p2;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "16.2_1";
		port_code = 50;}A_16p2_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_16p2;};
		time = 1000;
		target_button = 2;
		code = "16.2_2";
		port_code = 60;}A_16p2_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_16p3;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "16.3_1";
		port_code = 50;}A_16p3_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_16p3;};
		time = 1000;
		target_button = 2;
		code = "16.3_2";
		port_code = 60;}A_16p3_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_16p4;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "16.4_1";
		port_code = 50;}A_16p4_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_16p4;};
		time = 1000;
		target_button = 2;
		code = "16.4_2";
		port_code = 60;}A_16p4_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_16p5;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "16.5_1";
		port_code = 50;}A_16p5_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_16p5;};
		time = 1000;
		target_button = 2;
		code = "16.5_2";
		port_code = 60;}A_16p5_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_16p6;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "16.6_1";
		port_code = 50;}A_16p6_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_16p6;};
		time = 1000;
		target_button = 2;
		code = "16.6_2";
		port_code = 60;}A_16p6_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_16p7;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "16.7_1";
		port_code = 50;}A_16p7_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_16p7;};
		time = 1000;
		target_button = 2;
		code = "16.7_2";
		port_code = 60;}A_16p7_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_16p8;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "16.8_1";
		port_code = 50;}A_16p8_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_16p8;};
		time = 1000;
		target_button = 2;
		code = "16.8_2";
		port_code = 60;}A_16p8_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_16p9;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "16.9_1";
		port_code = 50;}A_16p9_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_16p9;};
		time = 1000;
		target_button = 2;
		code = "16.9_2";
		port_code = 60;}A_16p9_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_17p0;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "17.0_1";
		port_code = 50;}A_17p0_1;
		

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_17p0;};
		time = 1000;
		target_button = 2;
		code = "17.0_2";
		port_code = 60;}A_17p0_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_17p1;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "17.1_1";
		port_code = 50;}A_17p1_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_17p1;};
		time = 1000;
		target_button = 2;
		code = "17.1_2";
		port_code = 60;}A_17p1_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_17p2;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "17.2_1";
		port_code = 50;}A_17p2_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_17p2;};
		time = 1000;
		target_button = 2;
		code = "17.2_2";
		port_code = 60;}A_17p2_2;

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_17p3;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "17.3_1";
		port_code = 50;}A_17p3_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_17p3;};
		time = 1000;
		target_button = 2;
		code = "17.3_2";
		port_code = 60;}A_17p3_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_17p4;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "17.4_1";
		port_code = 50;}A_17p4_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_17p4;};
		time = 1000;
		target_button = 2;
		code = "17.4_2";
		port_code = 60;}A_17p4_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_17p5;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "17.5_1";
		port_code = 50;}A_17p5_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_17p5;};
		time = 1000;
		target_button = 2;
		code = "17.5_2";
		port_code = 60;}A_17p5_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_17p6;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "17.6_1";
		port_code = 50;}A_17p6_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_17p6;};
		time = 1000;
		target_button = 2;
		code = "17.6_2";
		port_code = 60;}A_17p6_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_17p7;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "17.7_1";
		port_code = 50;}A_17p7_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_17p7;};
		time = 1000;
		target_button = 2;
		code = "17.7_2";
		port_code = 60;}A_17p7_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_17p8;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "17.8_1";
		port_code = 50;}A_17p8_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_17p8;};
		time = 1000;
		target_button = 2;
		code = "17.8_2";
		port_code = 60;}A_17p8_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_u_17p9;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "17.9_1";
		port_code = 50;}A_17p9_1;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_d_17p9;};
		time = 1000;
		target_button = 2;
		code = "17.9_2";
		port_code = 60;}A_17p9_2;
		
trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_d_18p0;};
		time = 0;
		sound{wavefile A_p;};
		time = 1000;
		target_button = 1;
		code = "18.0_1";
		port_code = 50;}A_18p0_1;
		

trial{trial_duration = forever;
		clear_active_stimuli = true;
		trial_type = first_response;
		sound{wavefile A_p;};
		time = 0;
		sound{wavefile A_u_18p0;};
		time = 1000;
		target_button = 2;
		code = "18.0_2";
		port_code = 60;}A_18p0_2;

bitmap{filename = "instr123.bmp";}pt;
picture{bitmap pt; x = 0; y = 0;}pict;

bitmap{filename = "faux.bmp";}wrong;
bitmap{filename = "correct.bmp";}correct;

trial{clear_active_stimuli = true; 	
		picture{bitmap correct;x = 0; y = 0;};
		time = 0;
		code = "feedback_c";}feedcor;

trial{clear_active_stimuli = true; 	
		picture{bitmap wrong;x = 0; y = 0;};
		time = 0;
		code = "feedback_w";}feedwr;	

#PCL
begin_pcl;

#subroutine for wait
sub
	wait (int duration)
begin
loop
	int end_time = clock.time() + duration;
until
	clock.time() >= end_time
begin

end;
end;

#list of order of up and down sound presentations
array <int> bj[6];
bj = {1, 2, 1, 2, 2, 1};

int level = 19;
int jf = 0;


# LOOP 
loop
	int i = 1;
until i > 6
begin

pict.present();
wait(1000);

if (level == 0) then
		if (bj[i] == 1) then
		A_0_1.present();
		else
		A_0_2.present();
		end;
		
elseif (level == 1) then
		if (bj[i] == 1) then
		A_0p1_1.present();
		else
		A_0p1_2.present();
		end;
		
elseif (level == 2) then
		if (bj[i] == 1) then
		A_0p2_1.present();
		else
		A_0p2_2.present();
		end;
	
elseif (level == 3) then
		if (bj[i] == 1) then
		A_0p3_1.present();
		else
		A_0p3_2.present();
		end;
	
elseif (level == 4) then
		if (bj[i] == 1) then
		A_0p4_1.present();
		else
		A_0p4_2.present();
		end;
	
elseif (level == 5) then
		if (bj[i] == 1) then
		A_0p5_1.present();
		else
		A_0p5_2.present();
		end;
	 
elseif (level == 6) then
		if (bj[i] == 1) then
		A_0p6_1.present();
		else
		A_0p6_2.present();
		end;
	
elseif (level == 7) then
		if (bj[i] == 1) then
		A_0p7_1.present();
		else
		A_0p7_2.present();
		end;
	
elseif (level == 8) then
		if (bj[i] == 1) then
		A_0p8_1.present();
		else
		A_0p8_2.present();
		end;
	
elseif (level == 9) then
		if (bj[i] == 1) then
		A_0p9_1.present();
		else
		A_0p9_2.present();
		end;
	
elseif (level == 10) then
		if (bj[i] == 1) then
		A_1p0_1.present();
		else
		A_1p0_2.present();
		end;
	
elseif (level == 11) then
		if (bj[i] == 1) then
		A_1p1_1.present();
		else
		A_1p1_2.present();
		end;
	
elseif (level == 12) then
		if (bj[i] == 1) then
		A_1p2_1.present();
		else
		A_1p2_2.present();
		end;
	
elseif (level == 13) then
		if (bj[i] == 1) then
		A_1p3_1.present();
		else
		A_1p3_2.present();
		end;
	
elseif (level == 14) then
		if (bj[i] == 1) then
		A_1p4_1.present();
		else
		A_1p4_2.present();
		end;
	
elseif (level == 15) then
		if (bj[i] == 1) then
		A_1p5_1.present();
		else
		A_1p5_2.present();
		end;
	
elseif (level == 16) then
		if (bj[i] == 1) then
		A_1p6_1.present();
		else
		A_1p6_2.present();
		end;
		
elseif (level == 17) then
		if (bj[i] == 1) then
		A_1p7_1.present();
		else
		A_1p7_2.present();
		end;
		
elseif (level == 18) then
		if (bj[i] == 1) then
		A_1p8_1.present();
		else
		A_1p8_2.present();
		end;
		
elseif (level == 19) then
		if (bj[i] == 1) then
		A_1p9_1.present();
		else
		A_1p9_2.present();
		end;
		
elseif (level == 20) then
		if (bj[i] == 1) then
		A_2p0_1.present();
		else
		A_2p0_2.present();
		end;
		
elseif (level == 21) then
		if (bj[i] == 1) then
		A_2p1_1.present();
		else
		A_2p1_2.present();
		end;

elseif (level == 22) then
		if (bj[i] == 1) then
		A_2p2_1.present();
		else
		A_2p2_2.present();
		end;
		
elseif (level == 23) then
		if (bj[i] == 1) then
		A_2p3_1.present();
		else
		A_2p3_2.present();
		end;
		
elseif (level == 24) then
		if (bj[i] == 1) then
		A_2p4_1.present();
		else
		A_2p4_2.present();
		end;
		
elseif (level == 25) then
		if (bj[i] == 1) then
		A_2p5_1.present();
		else
		A_2p5_2.present();
		end;

elseif (level == 26) then
		if (bj[i] == 1) then
		A_2p6_1.present();
		else
		A_2p6_2.present();
		end;
		
elseif (level == 27) then
		if (bj[i] == 1) then
		A_2p7_1.present();
		else
		A_2p7_2.present();
		end;
		
elseif (level == 28) then
		if (bj[i] == 1) then
		A_2p8_1.present();
		else
		A_2p8_2.present();
		end;
		
elseif (level == 29) then
		if (bj[i] == 1) then
		A_2p9_1.present();
		else
		A_2p9_2.present();
		end;
		
elseif (level == 30) then
		if (bj[i] == 1) then
		A_3p0_1.present();
		else
		A_3p0_2.present();
		end;
		
elseif (level == 31) then
		if (bj[i] == 1) then
		A_3p1_1.present();
		else
		A_3p1_2.present();
		end;

elseif (level == 32) then
		if (bj[i] == 1) then
		A_3p2_1.present();
		else
		A_3p2_2.present();
		end;
		
elseif (level == 33) then
		if (bj[i] == 1) then
		A_3p3_1.present();
		else
		A_3p3_2.present();
		end;
		
elseif (level == 34) then
		if (bj[i] == 1) then
		A_3p4_1.present();
		else
		A_3p4_2.present();
		end;
		
elseif (level == 35) then
		if (bj[i] == 1) then
		A_3p5_1.present();
		else
		A_3p5_2.present();
		end;

elseif (level == 36) then
		if (bj[i] == 1) then
		A_3p6_1.present();
		else
		A_3p6_2.present();
		end;
		
elseif (level == 37) then
		if (bj[i] == 1) then
		A_3p7_1.present();
		else
		A_3p7_2.present();
		end;
		
elseif (level == 38) then
		if (bj[i] == 1) then
		A_3p8_1.present();
		else
		A_3p8_2.present();
		end;
		
elseif (level == 39) then
		if (bj[i] == 1) then
		A_3p9_1.present();
		else
		A_3p9_2.present();
		end;
		
elseif (level == 40) then
		if (bj[i] == 1) then
		A_4p0_1.present();
		else
		A_4p0_2.present();
		end;
		
elseif (level == 41) then
		if (bj[i] == 1) then
		A_4p1_1.present();
		else
		A_4p1_2.present();
		end;

elseif (level == 42) then
		if (bj[i] == 1) then
		A_4p2_1.present();
		else
		A_4p2_2.present();
		end;
		
elseif (level == 43) then
		if (bj[i] == 1) then
		A_4p3_1.present();
		else
		A_4p3_2.present();
		end;
		
elseif (level == 44) then
		if (bj[i] == 1) then
		A_4p4_1.present();
		else
		A_4p4_2.present();
		end;
		
elseif (level == 45) then
		if (bj[i] == 1) then
		A_4p5_1.present();
		else
		A_4p5_2.present();
		end;

elseif (level == 46) then
		if (bj[i] == 1) then
		A_4p6_1.present();
		else
		A_4p6_2.present();
		end;
		
elseif (level == 47) then
		if (bj[i] == 1) then
		A_4p7_1.present();
		else
		A_4p7_2.present();
		end;
		
elseif (level == 48) then
		if (bj[i] == 1) then
		A_4p8_1.present();
		else
		A_4p8_2.present();
		end;
		
elseif (level == 49) then
		if (bj[i] == 1) then
		A_4p9_1.present();
		else
		A_4p9_2.present();
		end;
		
elseif (level == 50) then
		if (bj[i] == 1) then
		A_5p0_1.present();
		else
		A_5p0_2.present();
		end;
		
elseif (level == 51) then
		if (bj[i] == 1) then
		A_5p1_1.present();
		else
		A_5p1_2.present();
		end;

elseif (level == 52) then
		if (bj[i] == 1) then
		A_5p2_1.present();
		else
		A_5p2_2.present();
		end;
		
elseif (level == 53) then
		if (bj[i] == 1) then
		A_5p3_1.present();
		else
		A_5p3_2.present();
		end;
		
elseif (level == 54) then
		if (bj[i] == 1) then
		A_5p4_1.present();
		else
		A_5p4_2.present();
		end;
		
elseif (level == 55) then
		if (bj[i] == 1) then
		A_5p5_1.present();
		else
		A_5p5_2.present();
		end;

elseif (level == 56) then
		if (bj[i] == 1) then
		A_5p6_1.present();
		else
		A_5p6_2.present();
		end;
		
elseif (level == 57) then
		if (bj[i] == 1) then
		A_5p7_1.present();
		else
		A_5p7_2.present();
		end;
		
elseif (level == 58) then
		if (bj[i] == 1) then
		A_5p8_1.present();
		else
		A_5p8_2.present();
		end;
		
elseif (level == 59) then
		if (bj[i] == 1) then
		A_5p9_1.present();
		else
		A_5p9_2.present();
		end;
		
elseif (level == 60) then
		if (bj[i] == 1) then
		A_6p0_1.present();
		else
		A_6p0_2.present();
		end;

elseif (level == 61) then
		if (bj[i] == 1) then
		A_6p1_1.present();
		else
		A_6p1_2.present();
		end;

elseif (level == 62) then
		if (bj[i] == 1) then
		A_6p2_1.present();
		else
		A_6p2_2.present();
		end;
		
elseif (level == 63) then
		if (bj[i] == 1) then
		A_6p3_1.present();
		else
		A_6p3_2.present();
		end;
		
elseif (level == 64) then
		if (bj[i] == 1) then
		A_6p4_1.present();
		else
		A_6p4_2.present();
		end;
		
elseif (level == 65) then
		if (bj[i] == 1) then
		A_6p5_1.present();
		else
		A_6p5_2.present();
		end;

elseif (level == 66) then
		if (bj[i] == 1) then
		A_6p6_1.present();
		else
		A_6p6_2.present();
		end;
		
elseif (level == 67) then
		if (bj[i] == 1) then
		A_6p7_1.present();
		else
		A_6p7_2.present();
		end;
		
elseif (level == 68) then
		if (bj[i] == 1) then
		A_6p8_1.present();
		else
		A_6p8_2.present();
		end;
		
elseif (level == 69) then
		if (bj[i] == 1) then
		A_6p9_1.present();
		else
		A_6p9_2.present();
		end;
		
elseif (level == 70) then
		if (bj[i] == 1) then
		A_7p0_1.present();
		else
		A_7p0_2.present();
		end;
		
elseif (level == 71) then
		if (bj[i] == 1) then
		A_7p1_1.present();
		else
		A_7p1_2.present();
		end;

elseif (level == 72) then
		if (bj[i] == 1) then
		A_7p2_1.present();
		else
		A_7p2_2.present();
		end;
		
elseif (level == 73) then
		if (bj[i] == 1) then
		A_7p3_1.present();
		else
		A_7p3_2.present();
		end;
		
elseif (level == 74) then
		if (bj[i] == 1) then
		A_7p4_1.present();
		else
		A_7p4_2.present();
		end;
		
elseif (level == 75) then
		if (bj[i] == 1) then
		A_7p5_1.present();
		else
		A_7p5_2.present();
		end;

elseif (level == 76) then
		if (bj[i] == 1) then
		A_7p6_1.present();
		else
		A_7p6_2.present();
		end;
		
elseif (level == 77) then
		if (bj[i] == 1) then
		A_7p7_1.present();
		else
		A_7p7_2.present();
		end;
		
elseif (level == 78) then
		if (bj[i] == 1) then
		A_7p8_1.present();
		else
		A_7p8_2.present();
		end;
		
elseif (level == 79) then
		if (bj[i] == 1) then
		A_7p9_1.present();
		else
		A_7p9_2.present();
		end;
		
elseif (level == 80) then
		if (bj[i] == 1) then
		A_8p0_1.present();
		else
		A_8p0_2.present();
		end;
		
elseif (level == 81) then
		if (bj[i] == 1) then
		A_8p1_1.present();
		else
		A_8p1_2.present();
		end;

elseif (level == 82) then
		if (bj[i] == 1) then
		A_8p2_1.present();
		else
		A_8p2_2.present();
		end;
		
elseif (level == 83) then
		if (bj[i] == 1) then
		A_8p3_1.present();
		else
		A_8p3_2.present();
		end;
		
elseif (level == 84) then
		if (bj[i] == 1) then
		A_8p4_1.present();
		else
		A_8p4_2.present();
		end;
		
elseif (level == 85) then
		if (bj[i] == 1) then
		A_8p5_1.present();
		else
		A_8p5_2.present();
		end;

elseif (level == 86) then
		if (bj[i] == 1) then
		A_8p6_1.present();
		else
		A_8p6_2.present();
		end;
		
elseif (level == 87) then
		if (bj[i] == 1) then
		A_8p7_1.present();
		else
		A_8p7_2.present();
		end;
		
elseif (level == 88) then
		if (bj[i] == 1) then
		A_8p8_1.present();
		else
		A_8p8_2.present();
		end;
		
elseif (level == 89) then
		if (bj[i] == 1) then
		A_8p9_1.present();
		else
		A_8p9_2.present();
		end;
		
elseif (level == 90) then
		if (bj[i] == 1) then
		A_9p0_1.present();
		else
		A_9p0_2.present();
		end;
		
elseif (level == 91) then
		if (bj[i] == 1) then
		A_9p1_1.present();
		else
		A_9p1_2.present();
		end;

elseif (level == 92) then
		if (bj[i] == 1) then
		A_9p2_1.present();
		else
		A_9p2_2.present();
		end;
		
elseif (level == 93) then
		if (bj[i] == 1) then
		A_9p3_1.present();
		else
		A_9p3_2.present();
		end;
		
elseif (level == 94) then
		if (bj[i] == 1) then
		A_9p4_1.present();
		else
		A_9p4_2.present();
		end;
		
elseif (level == 95) then
		if (bj[i] == 1) then
		A_9p5_1.present();
		else
		A_9p5_2.present();
		end;

elseif (level == 96) then
		if (bj[i] == 1) then
		A_9p6_1.present();
		else
		A_9p6_2.present();
		end;
		
elseif (level == 97) then
		if (bj[i] == 1) then
		A_9p7_1.present();
		else
		A_9p7_2.present();
		end;
		
elseif (level == 98) then
		if (bj[i] == 1) then
		A_9p8_1.present();
		else
		A_9p8_2.present();
		end;
		
elseif (level == 99) then
		if (bj[i] == 1) then
		A_9p9_1.present();
		else
		A_9p9_2.present();
		end;
		
elseif (level == 100) then
		if (bj[i] == 1) then
		A_10p0_1.present();
		else
		A_10p0_2.present();
		end;
		
elseif (level == 101) then
		if (bj[i] == 1) then
		A_10p1_1.present();
		else
		A_10p1_2.present();
		end;

elseif (level == 102) then
		if (bj[i] == 1) then
		A_10p2_1.present();
		else
		A_10p2_2.present();
		end;
		
elseif (level == 103) then
		if (bj[i] == 1) then
		A_10p3_1.present();
		else
		A_10p3_2.present();
		end;
		
elseif (level == 104) then
		if (bj[i] == 1) then
		A_10p4_1.present();
		else
		A_10p4_2.present();
		end;
		
elseif (level == 105) then
		if (bj[i] == 1) then
		A_10p5_1.present();
		else
		A_10p5_2.present();
		end;

elseif (level == 106) then
		if (bj[i] == 1) then
		A_10p6_1.present();
		else
		A_10p6_2.present();
		end;
		
elseif (level == 107) then
		if (bj[i] == 1) then
		A_10p7_1.present();
		else
		A_10p7_2.present();
		end;
		
elseif (level == 108) then
		if (bj[i] == 1) then
		A_10p8_1.present();
		else
		A_10p8_2.present();
		end;
		
elseif (level == 109) then
		if (bj[i] == 1) then
		A_10p9_1.present();
		else
		A_10p9_2.present();
		end;
		
elseif (level == 110) then
		if (bj[i] == 1) then
		A_11p0_1.present();
		else
		A_11p0_2.present();
		end;

elseif (level == 111) then
		if (bj[i] == 1) then
		A_11p1_1.present();
		else
		A_11p1_2.present();
		end;

elseif (level == 112) then
		if (bj[i] == 1) then
		A_11p2_1.present();
		else
		A_11p2_2.present();
		end;
		
elseif (level == 113) then
		if (bj[i] == 1) then
		A_11p3_1.present();
		else
		A_11p3_2.present();
		end;
		
elseif (level == 114) then
		if (bj[i] == 1) then
		A_11p4_1.present();
		else
		A_11p4_2.present();
		end;
		
elseif (level == 115) then
		if (bj[i] == 1) then
		A_11p5_1.present();
		else
		A_11p5_2.present();
		end;

elseif (level == 116) then
		if (bj[i] == 1) then
		A_11p6_1.present();
		else
		A_11p6_2.present();
		end;
		
elseif (level == 117) then
		if (bj[i] == 1) then
		A_11p7_1.present();
		else
		A_11p7_2.present();
		end;
		
elseif (level == 118) then
		if (bj[i] == 1) then
		A_11p8_1.present();
		else
		A_11p8_2.present();
		end;
		
elseif (level == 119) then
		if (bj[i] == 1) then
		A_11p9_1.present();
		else
		A_11p9_2.present();
		end;
		
elseif (level == 120) then
		if (bj[i] == 1) then
		A_12p0_1.present();
		else
		A_12p0_2.present();
		end;

elseif (level == 121) then
		if (bj[i] == 1) then
		A_12p1_1.present();
		else
		A_12p1_2.present();
		end;

elseif (level == 122) then
		if (bj[i] == 1) then
		A_12p2_1.present();
		else
		A_12p2_2.present();
		end;
		
elseif (level == 123) then
		if (bj[i] == 1) then
		A_12p3_1.present();
		else
		A_12p3_2.present();
		end;
		
elseif (level == 124) then
		if (bj[i] == 1) then
		A_12p4_1.present();
		else
		A_12p4_2.present();
		end;
		
elseif (level == 125) then
		if (bj[i] == 1) then
		A_12p5_1.present();
		else
		A_12p5_2.present();
		end;

elseif (level == 126) then
		if (bj[i] == 1) then
		A_12p6_1.present();
		else
		A_12p6_2.present();
		end;
		
elseif (level == 127) then
		if (bj[i] == 1) then
		A_12p7_1.present();
		else
		A_12p7_2.present();
		end;
		
elseif (level == 128) then
		if (bj[i] == 1) then
		A_12p8_1.present();
		else
		A_12p8_2.present();
		end;
		
elseif (level == 129) then
		if (bj[i] == 1) then
		A_12p9_1.present();
		else
		A_12p9_2.present();
		end;
		
elseif (level == 130) then
		if (bj[i] == 1) then
		A_13p0_1.present();
		else
		A_13p0_2.present();
		end;

elseif (level == 131) then
		if (bj[i] == 1) then
		A_13p1_1.present();
		else
		A_13p1_2.present();
		end;

elseif (level == 132) then
		if (bj[i] == 1) then
		A_13p2_1.present();
		else
		A_13p2_2.present();
		end;
		
elseif (level == 133) then
		if (bj[i] == 1) then
		A_13p3_1.present();
		else
		A_13p3_2.present();
		end;
		
elseif (level == 134) then
		if (bj[i] == 1) then
		A_13p4_1.present();
		else
		A_13p4_2.present();
		end;
		
elseif (level == 135) then
		if (bj[i] == 1) then
		A_13p5_1.present();
		else
		A_13p5_2.present();
		end;

elseif (level == 136) then
		if (bj[i] == 1) then
		A_13p6_1.present();
		else
		A_13p6_2.present();
		end;
		
elseif (level == 137) then
		if (bj[i] == 1) then
		A_13p7_1.present();
		else
		A_13p7_2.present();
		end;
		
elseif (level == 138) then
		if (bj[i] == 1) then
		A_13p8_1.present();
		else
		A_13p8_2.present();
		end;
		
elseif (level == 139) then
		if (bj[i] == 1) then
		A_13p9_1.present();
		else
		A_13p9_2.present();
		end;
		
elseif (level == 140) then
		if (bj[i] == 1) then
		A_14p0_1.present();
		else
		A_14p0_2.present();
		end;

elseif (level == 141) then
		if (bj[i] == 1) then
		A_14p1_1.present();
		else
		A_14p1_2.present();
		end;

elseif (level == 142) then
		if (bj[i] == 1) then
		A_14p2_1.present();
		else
		A_14p2_2.present();
		end;
		
elseif (level == 143) then
		if (bj[i] == 1) then
		A_14p3_1.present();
		else
		A_14p3_2.present();
		end;
		
elseif (level == 144) then
		if (bj[i] == 1) then
		A_14p4_1.present();
		else
		A_14p4_2.present();
		end;
		
elseif (level == 145) then
		if (bj[i] == 1) then
		A_14p5_1.present();
		else
		A_14p5_2.present();
		end;

elseif (level == 146) then
		if (bj[i] == 1) then
		A_14p6_1.present();
		else
		A_14p6_2.present();
		end;
		
elseif (level == 147) then
		if (bj[i] == 1) then
		A_14p7_1.present();
		else
		A_14p7_2.present();
		end;
		
elseif (level == 148) then
		if (bj[i] == 1) then
		A_14p8_1.present();
		else
		A_14p8_2.present();
		end;
		
elseif (level == 149) then
		if (bj[i] == 1) then
		A_14p9_1.present();
		else
		A_14p9_2.present();
		end;
		
elseif (level == 150) then
		if (bj[i] == 1) then
		A_15p0_1.present();
		else
		A_15p0_2.present();
		end;

elseif (level == 151) then
		if (bj[i] == 1) then
		A_15p1_1.present();
		else
		A_15p1_2.present();
		end;

elseif (level == 152) then
		if (bj[i] == 1) then
		A_15p2_1.present();
		else
		A_15p2_2.present();
		end;
		
elseif (level == 153) then
		if (bj[i] == 1) then
		A_15p3_1.present();
		else
		A_15p3_2.present();
		end;
		
elseif (level == 154) then
		if (bj[i] == 1) then
		A_15p4_1.present();
		else
		A_15p4_2.present();
		end;
		
elseif (level == 155) then
		if (bj[i] == 1) then
		A_15p5_1.present();
		else
		A_15p5_2.present();
		end;

elseif (level == 156) then
		if (bj[i] == 1) then
		A_15p6_1.present();
		else
		A_15p6_2.present();
		end;
		
elseif (level == 157) then
		if (bj[i] == 1) then
		A_15p7_1.present();
		else
		A_15p7_2.present();
		end;
		
elseif (level == 158) then
		if (bj[i] == 1) then
		A_15p8_1.present();
		else
		A_15p8_2.present();
		end;
		
elseif (level == 159) then
		if (bj[i] == 1) then
		A_15p9_1.present();
		else
		A_15p9_2.present();
		end;
		
elseif (level == 160) then
		if (bj[i] == 1) then
		A_16p0_1.present();
		else
		A_16p0_2.present();
		end;
		
elseif (level == 161) then
		if (bj[i] == 1) then
		A_16p1_1.present();
		else
		A_16p1_2.present();
		end;

elseif (level == 162) then
		if (bj[i] == 1) then
		A_16p2_1.present();
		else
		A_16p2_2.present();
		end;
	
elseif (level == 163) then
		if (bj[i] == 1) then
		A_16p3_1.present();
		else
		A_16p3_2.present();
		end;
		
elseif (level == 164) then
		if (bj[i] == 1) then
		A_16p4_1.present();
		else
		A_16p4_2.present();
		end;
		
elseif (level == 165) then
		if (bj[i] == 1) then
		A_16p5_1.present();
		else
		A_16p5_2.present();
		end;

elseif (level == 166) then
		if (bj[i] == 1) then
		A_16p6_1.present();
		else
		A_16p6_2.present();
		end;
		
elseif (level == 167) then
		if (bj[i] == 1) then
		A_16p7_1.present();
		else
		A_16p7_2.present();
		end;
		
elseif (level == 168) then
		if (bj[i] == 1) then
		A_16p8_1.present();
		else
		A_16p8_2.present();
		end;
		
elseif (level == 169) then
		if (bj[i] == 1) then
		A_16p9_1.present();
		else
		A_16p9_2.present();
		end;
		
elseif (level == 170) then
		if (bj[i] == 1) then
		A_17p0_1.present();
		else
		A_17p0_2.present();
		end;
		
elseif (level == 171) then
		if (bj[i] == 1) then
		A_17p1_1.present();
		else
		A_17p1_2.present();
		end;

elseif (level == 172) then
		if (bj[i] == 1) then
		A_17p2_1.present();
		else
		A_17p2_2.present();
		end;
		
elseif (level == 173) then
		if (bj[i] == 1) then
		A_17p3_1.present();
		else
		A_17p3_2.present();
		end;
		
elseif (level == 174) then
		if (bj[i] == 1) then
		A_17p4_1.present();
		else
		A_17p4_2.present();
		end;
		
elseif (level == 175) then
		if (bj[i] == 1) then
		A_17p5_1.present();
		else
		A_17p5_2.present();
		end;

elseif (level == 176) then
		if (bj[i] == 1) then
		A_17p6_1.present();
		else
		A_17p6_2.present();
		end;
		
elseif (level == 177) then
		if (bj[i] == 1) then
		A_17p7_1.present();
		else
		A_17p7_2.present();
		end;
		
elseif (level == 178) then
		if (bj[i] == 1) then
		A_17p8_1.present();
		else
		A_17p8_2.present();
		end;
		
elseif (level == 179) then
		if (bj[i] == 1) then
		A_17p9_1.present();
		else
		A_17p9_2.present();
		end;
		
elseif (level == 180) then
		if (bj[i] == 1) then
		A_18p0_1.present();
		else
		A_18p0_2.present();
		end;

end;
   
# Change difficulty level
stimulus_data last = stimulus_manager.last_stimulus_data();
   if (last.type() == stimulus_hit) then
   feedcor.present();
   jf = jf + 1;
   if (jf == 2) then
   level = level - 1;
   jf = 0;
   else 
   level = level;
   jf = jf;
   end;
   elseif (last.type() == stimulus_incorrect) then
   feedwr.present();
	jf = 0;
	level = level + 1;
	end;


wait(900);

i = i + 1;
end;

