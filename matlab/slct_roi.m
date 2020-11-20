    clear;

atlas          	= ft_read_atlas('/Users/heshamelshafei/Documents/GitHub/fieldtrip/template/atlas/aal/ROI_MNI_V4.nii');
slct_axs        = [1 2 19 20 43:70 79:90];
roi_label       = [atlas.tissuelabel(slct_axs)]';