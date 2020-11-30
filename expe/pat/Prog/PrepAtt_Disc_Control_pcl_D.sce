# - Header - #
# - Disc Threshold One - #
scenario = "17_March_2015";

$BP = "D";


response_matching = simple_matching;
active_buttons=3;		# button press
button_codes=251,252,253;

# - Screen Parameters - #
default_font_size = 26 ;
default_font = "Arial";
default_text_color = 0, 0, 0;
screen_width = 1024;
screen_height = 768;
screen_bit_depth = 32;
default_background_color = 200, 200, 200;

begin;
TEMPLATE "PrepAtt_stim_trial_$BP.tem" {}; 

begin_pcl;
preset string nom_sujet; #subject
preset string num_repeat; 

int TOT_trial = 16;
# = Temporal Parameters = #
int duree_instruc_task=3000;
int duree_instruc=2000; 		 
int max_rep=3000;

# =   Sound Paramaters  = #
int dur_sTAR=100;					#target sound duration
double correc_atttar =-0.25;
double correc_attdis =-0.55;
array<double> final_att[4];	# Values of attenuation left and right specific ot each subject
array<int>side[4];				# Table of four options 1=left Low, 2= Right Low, 3= Left High 4= Right High  

double final_att_a;				# Value of left low  
double final_att_b;				# Value of left high  
double final_att_c;				# Value of right low  
double final_att_d;				# Value of right high  

double att_sTARa;					# Target sound attenuation applied after correction "left low" 
double att_sTARb;					# Target sound attenuation applied after correction "left high" 
double att_sTARc;					# Target sound attenuation applied after correction "right low"
double att_sTARd;					# Target sound attenuation applied after correction "right high" 
double att_sTARbi_lo;
double att_sTARbi_hi;

double att_sDISg;					# Distracter sound attenuation left
double att_sDISd;					# Distracter sound attenuation right

# -- Variables -- #
string filename;				
int nbessais = 0;
int num;			
int tar;
string TAR;				
int codTAR;
int bp;							
int nbrep;						
string temp;
array<int> meantr[0];		
double moytr;					
int rep=0;
int correct=0;
int incorrect=0;
int miss=0;
int rec_time;					
int fa=0;
int missrep=0;					
int multirep=0;
int rep_before_tar=0;
int cor_llo=0;
int cor_lhi=0;
int cor_rlo=0;
int cor_rhi=0;		
int cor=0;

# == Reading Into Attenuation Files ==#
# Open
input_file inatt = new input_file;
filename.append("../log/"); 
filename.append(nom_sujet);
filename.append("_thresholds");
filename.append(".txt");
inatt.open(filename,false);

# Skip first line 
inatt.get_line();
 	
# Read side 1
inatt.set_delimiter('\t');
temp=inatt.get_line();
side[1]=inatt.get_int();	
if !inatt.last_succeeded() then 
 term.print( "Error reading file!\n" );
 exit();
else end;
temp=inatt.get_line();
temp=inatt.get_line();
if !inatt.last_succeeded() then 
 term.print( "Error reading file!\n" );
 exit();
else end;
inatt.set_delimiter('\n');
final_att[1]=inatt.get_double();
if !inatt.last_succeeded() then 
 term.print( "Error reading file!\n" );
 exit();
else end;

# Read side 2
inatt.set_delimiter('\t');
temp=inatt.get_line();
side[2]=inatt.get_int();
if !inatt.last_succeeded() then 
 term.print( "Error reading file!\n" );
 exit();
else end;
temp=inatt.get_line();
temp=inatt.get_line();
if !inatt.last_succeeded() then 
 term.print( "Error reading file!\n" );
 exit();
else end;
inatt.set_delimiter('\n');
final_att[2]=inatt.get_double();
if !inatt.last_succeeded() then 
 term.print( "Error reading file!\n" );
 exit();
else end;

# Read side 3
inatt.set_delimiter('\t');
temp=inatt.get_line();
side[3]=inatt.get_int();
if !inatt.last_succeeded() then 
 term.print( "Error reading file!\n" );
 exit();
else end;
temp=inatt.get_line();#	Read volume
temp=inatt.get_line();
if !inatt.last_succeeded() then 
 term.print( "Error reading file!\n" );
 exit();
else end;
inatt.set_delimiter('\n');
final_att[3]=inatt.get_double();
if !inatt.last_succeeded() then 
 term.print( "Error reading file!\n" );
 exit();
else end;

# Read side 4
inatt.set_delimiter('\t');
temp=inatt.get_line();
side[4]=inatt.get_int();
if !inatt.last_succeeded() then 
 term.print( "Error reading file!\n" );
 exit();
else end;
temp=inatt.get_line();#	Read volume
temp=inatt.get_line();
if !inatt.last_succeeded() then 
 term.print( "Error reading file!\n" );
 exit();
else end;
inatt.set_delimiter('\n');
final_att[4]=inatt.get_double();
if !inatt.last_succeeded() then 
 term.print( "Error reading file!\n" );
 exit();
else end;

inatt.close();

# Attenuation Calculation 

final_att_a	= final_att[1];		# left low
final_att_b	= final_att[2]; 		# left high  
final_att_c	= final_att[3]; 		# right low 
final_att_d	= final_att[4];  		#	right high 

att_sDISg=final_att_a+correc_attdis; #for dist left
att_sDISd=final_att_c+correc_attdis; #for dist right

att_sTARa=final_att_a + correc_atttar; #tar 
att_sTARb=final_att_b + correc_atttar;	#tar 
att_sTARc=final_att_c + correc_atttar; #tar
att_sTARd=final_att_d + correc_atttar; #tar

att_sTARbi_lo =(final_att_a+final_att_c)/2.0 + correc_atttar; #tar bilateral low
att_sTARbi_hi =(final_att_b+final_att_d)/2.0 + correc_atttar; #tar bilateral high


# == Instruction Display == #

text1.set_caption("Attenuation Gauche: " +string(final_att_a)+ "  Attenuation Droite: "+string(final_att_c)+"\n Press Enter To Continue."); 
text1.redraw();
info_trial2.present();
trial_instruc.present();

Sound_tar_1_low.set_pan(0.0);
Sound_tar_1_low.set_attenuation(att_sTARbi_lo); 
trial_instrucLow.present();
Sound_tar_1_high.set_pan(0.0);
Sound_tar_1_high.set_attenuation(att_sTARbi_hi); 
trial_instrucHigh.present();


# -- First Reading Into Settings file -- # 
input_file in = new input_file;
filename="";
filename=("Disc_Control.txt");
in.open(filename);
loop until
   in.end_of_file()
begin 
  	in.get_line();
	if in.last_succeeded()
	then
		nbessais = nbessais+1;
	else
		break;
	end;
end;
in.close();

# -- Creating Results File -- #
filename="";
filename.append(nom_sujet);
filename.append("_Disc_Control_");
filename.append(num_repeat);
filename.append(".txt");
output_file out = new output_file;
out.open(filename);
out.print("Subject: " + nom_sujet);
out.print("\n");

out.print("\n");
out.print("N	Tar	ER	SR	MR	HIT  RT");
out.print("\n");

# -- Second reading Into Parameters File -- # 
filename="";
filename=("Disc_Control.txt");
in.open(filename);
in.get_line();
int i=1;

# -- Start Loop -- #

loop until 
   in.end_of_file() || !in.last_succeeded() || (i > nbessais+1)
begin
   in.set_delimiter('\n');
	num=in.get_int();
   if !in.last_succeeded() then break; end;
   in.set_delimiter('\"');
   TAR=in.get_line();
   TAR=in.get_line();
   if !in.last_succeeded() then break; end;
   in.set_delimiter('\n');
   codTAR=in.get_int();
   if !in.last_succeeded() then break; end;
   bp=in.get_int();
   if !in.last_succeeded() then break; end;
   in.get_line(); # saute la fin de ligne
   
# -- Attribution of Events and Trials Names -- #

	TAR=TAR+(".wav");

	# Target
	# 1st Pair
	if (TAR=="S_tarson_Lo_1_L.wav") then
		Sound_tar_1_low.set_pan(-1.0);# Max left attenuation
		Sound_tar_1_low.set_attenuation(att_sTARa);
		tar=1;
		trial_tar1_low.set_duration(dur_sTAR+max_rep);
		event_target1_low.set_target_button(bp);	#determine la reponse attendue 	
		event_target1_low.set_event_code(string(codTAR));
		trial_tar1_low.present();
	end;
	
	if (TAR=="S_tarson_Lo_1_R.wav") then
		Sound_tar_1_low.set_pan(1.0);# Max right attenuation
		Sound_tar_1_low.set_attenuation(att_sTARc); 
		tar=2;
		trial_tar1_low.set_duration(dur_sTAR+max_rep);
		event_target1_low.set_target_button(bp);#determine la reponse attendue 	
		event_target1_low.set_event_code(string(codTAR));
		trial_tar1_low.present();
	end;
	
		if (TAR=="S_tarson_Hi_1_L.wav") then
		Sound_tar_1_high.set_pan(-1.0);# Max left attenuation
		Sound_tar_1_high.set_attenuation(att_sTARb);
		tar=3;
		trial_tar1_high.set_duration(dur_sTAR+max_rep);
		event_target1_high.set_target_button(bp);	#determine la reponse attendue 	
		event_target1_high.set_event_code(string(codTAR));
		trial_tar1_high.present();
	end;
	
	if (TAR=="S_tarson_Hi_1_R.wav") then
		Sound_tar_1_high.set_pan(1.0);# Max right attenuation
		Sound_tar_1_high.set_attenuation(att_sTARd);
		tar=4;
		trial_tar1_high.set_duration(dur_sTAR+max_rep);
		event_target1_high.set_target_button(bp);#determine la reponse attendue 	
		event_target1_high.set_event_code(string(codTAR));
		trial_tar1_high.present();
	end;

	
	if (bool( response_manager.response_count() )) then
      response_data last = response_manager.last_response_data();
      rep=last.button();
      stimulus_data last1 = stimulus_manager.last_stimulus_data();
      rec_time=last1.reaction_time();
      nbrep=response_manager.response_count();	
		if(nbrep)>1 then
			multirep=multirep+1;
			cor=0;
		else  # nbrep=1
			if rep == bp then
				meantr.add(rec_time);  #pour la moyenne des TR des essais corrects
				cor=1;
				if tar == 1 then 
					cor_llo=cor_llo+1;
				end;
				if tar == 2 then
					cor_rlo=cor_rlo+1;
				end;		
				if tar == 3 then
				cor_lhi=cor_lhi+1;
				end;
				if tar == 4 then
					cor_rhi=cor_rhi+1;
				end;
			else
				cor=0;
				incorrect = incorrect +1;
			end;			
		end;  		
	else  #nbrep=0
		missrep=missrep+1;
		rec_time=0;  
		rep=0;
		nbrep=0;
		cor=0;
	end;
	
  # Write Trial
	  out.print(i);
     out.print("	"); 
     out.print(tar);
     out.print("	");
     out.print(bp);
     out.print("	");
     out.print(rep);
     out.print("	");
     out.print(nbrep);
     out.print("	");
     out.print(cor);
     out.print("	");
     out.print(rec_time);
     out.print("\n");
	  i=i+1;
end;

# Write Block Results 
moytr=floor(arithmetic_mean(meantr));
#correct = response_manager.total_hits();
#incorrect = response_manager.total_incorrects();
#miss = response_manager.total_misses();
correct = cor_llo + cor_rlo + cor_lhi + cor_rhi;
#incorrect = TOT_trial - missrep - correct;



out.print("\n");
out.print("nb trial with correct rep:  LeftLow: ");
out.print(cor_llo);
out.print("/4   RightLow: ");
out.print(cor_rlo);
out.print("/4   LeftHigh: ");
out.print(cor_lhi);
out.print("/4   RightHigh: ");
out.print(cor_rhi);
out.print("/4\n");
out.print("nb trial with correct rep:");
out.print(correct);
out.print("\n");
out.print("nb trial with no rep:");
out.print(missrep);
out.print("\n");
out.print("nb trial with incorrect rep:");
out.print(incorrect);
out.print("\n");
out.print("nb trial with multip rep:");
out.print(multirep);
out.print("\n");
out.print("Average RT:");
out.print(moytr); 
out.print("\n");
out.close();
in.close();

#== Average Reaction Time ==#
#text1.set_caption("Press Enter To Continue. \n" + string(cor_llo) + string(cor_lhi) + string(cor_rlo) + string(cor_rhi)); 
#text1.redraw();
#info_trial2.present();