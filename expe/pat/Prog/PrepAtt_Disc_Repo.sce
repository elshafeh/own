# - Header - #
# - Disc Threshold One - #

scenario = "17_March_2015";


# - Screen Parameters - #
default_font_size = 26 ;
default_font = "Arial";
default_text_color = 0, 0, 0;
write_codes = true;
screen_width = 1024;
screen_height = 768;
screen_bit_depth = 32;
default_background_color = 200, 200, 200;

begin;
TEMPLATE "PrepAtt_stim_trial_repo.tem" {}; 

begin_pcl;

int TOT_trial = 16;
# = Temporal Parameters = #
int duree_instruc_task=3000;
int duree_instruc=2000; 		 
int max_rep=3000;


trial_instruc.present();
trial_repo.present();