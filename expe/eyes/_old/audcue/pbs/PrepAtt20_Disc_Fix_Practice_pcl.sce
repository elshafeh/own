# == Header == #
# Disc Fix Delay

scenario = "17_March_2015";

active_buttons=3;		#button press
button_codes=251,252,253;

# == Screen Parameters == #
default_font_size = 24 ;
default_font = "Arial";
default_text_color = 0, 0, 0;   #noir
#screen_width = 1024;
#screen_height = 768;
#screen_bit_depth = 32;
default_background_color = 200, 200, 200;

begin;
TEMPLATE "PrepAtt_stim_trial.tem" {}; 

begin_pcl;
preset string nom_sujet; #subject

# == Temporal Parameters == #
int duree_instruc_task=1000;	# Display task for 2s 
int duree_instruc=3000; 		# Instruction 1s before sounds start 
int duree_mem_sound=300; 
int max_rep=3300; # increased by 300
int duree_minstruct=50;
int rep_plus=0;
int delay_plus1=0;
int delay_plus2=0;

# === Sound Paramaters  == #
int dur_sTAR=100;					#target sound duration
int dur_sDIS=300;					# distractor duration
int dur_cue=194;					#cue presentation 192 (to be changed in Template "PrepAtt_stim_trial.tem" to 200 for trials = 12 trames a 60Hz
double correc_atttar =-0.20;
double correc_attdis =-0.35;
array<double> final_att[4];	# Values of attenuation left and right specific ot each subject
array<int>side[4];				# Table of four options 1=left Low, 2= Right Low, 3= Left High 4= Right High  

double final_atta;				# Value of left low 
double final_attb;				# Value of left high 
double final_attc;				# Value of right low 
double final_attd;				# Value of right high 

double att_sTARa;					# Target sound attenuation applied after correction "left low" 
double att_sTARb;					# Target sound attenuation applied after correction "left high"
double att_sTARc;					# Target sound attenuation applied after correction "right low" 
double att_sTARd;					# Target sound attenuation applied after correction "right high"

double att_sDISg;					# Distracter sound attenuation left
double att_sDISd;					# Distracter sound attenuation right


# == Variables == #
string filename;
int nbessais = 0;
int num;
int trialt;
string cue;
int codCUE;
int delay1;
int dis;
int dis1;
int tar;
int fa = 0;
int codDIS;
string DIS;
string TARwav;
int delay2;
string TAR;
int codTAR;
int bp;
int ISIrand;
int nbrep;
string temp;
array<int> meantr[0];
array<int> meantr_val[0];
array<int> meantr_inval[0];
double moytr;
double moytr_val;
double moytr_inval;
double cue_check;
string up;
string down;
int valide;
int rep=0;
int rec_time;
int missrep=0;
int multirep=0;
int rep_before_tar=0;
int cuefic;
int counter;
int ER;
int SR;
int correct =0;
int incorrect=0;
int norep=0;

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

final_atta= final_att[1];		# left low 
final_attb= final_att[3]; 	# right low 
final_attc= final_att[2]; # left high 
final_attd= final_att[4];  #right high 

att_sDISg=final_atta+correc_attdis; #for dist left
att_sDISd=final_attb+correc_attdis; #for dist right

att_sTARa=final_atta + correc_atttar; #tar 
att_sTARb=final_attb + correc_atttar;	#tar 
att_sTARc=final_attc + correc_atttar; #tar
att_sTARd=final_attd + correc_atttar; #tar


# == Attenuation Display == #
text1.set_caption("Attenuation Gauche: " +string(final_atta)+ "  Attenuation Droite: "+string(final_attb)+"\n Press Enter To Continue."); 
text1.redraw();
info_trial2.present();

# -- Memory -- #
# Display
trial_instruc2.set_duration(duree_instruc_task);
trial_instruc2.present();
trial_no.set_duration(duree_instruc);
trial_no.present();

# Play
#low
Sound_tar_1_low.set_attenuation(att_sTARb);
Sound_tar_1_low.set_pan(0.0);# Max left attenuation
mem_tar1_low.set_duration(dur_sTAR);
mem_tar1_low.present();
trial_no.set_duration(duree_instruc);
trial_no.present();

#high
Sound_tar_1_high.set_attenuation(att_sTARd);
Sound_tar_1_high.set_pan(0.0);# Max left attenuation
mem_tar1_high.set_duration(dur_sTAR);
mem_tar1_high.present();
trial_no.set_duration(duree_instruc);
trial_no.present();

#disc_instruc.present();
#trial_no.set_duration(duree_instruc);
#trial_no.present();

# == Display Instructions == #
disc_instruc.present();
event_instruc.set_port_code(90);
trial_no.set_duration(duree_instruc);
trial_no.present();

# == First Reading Into Settings file to find the number of lines == #
input_file in = new input_file;
filename="";
filename=("Practice_Disc");
filename.append(".txt"); 
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

# === Creating Results File == #
filename="";
filename.append(nom_sujet);
filename.append("_");
filename.append("Practice_Disc"); #discrimination 
filename.append(".txt");
output_file out = new output_file;
out.open(filename);
out.print("Subject: "+nom_sujet);
out.print("\n");
out.print("\n");
out.print("N	Cue	D1 	Dis	D2 	Tar	ER	SR	FA	MR	RT");
out.print("\n");

# == Second reading Into Parameters File to Initialize variables in the loop presentation of trials == #
filename="";
filename=("Practice_Disc.txt");
in.open(filename);
in.get_line(); # Skip First Line
int i=1;

#Start Loop
loop until 
   in.end_of_file() || !in.last_succeeded() || (i > nbessais+1)
begin
   in.set_delimiter('\n');
	num=in.get_int();
   if !in.last_succeeded() then break; end;
   valide=in.get_int();
   if !in.last_succeeded() then break; end;
   in.set_delimiter('\"');
   cue=in.get_line();
   cue=in.get_line();
   if !in.last_succeeded() then break; end;
   in.set_delimiter('\n');
   codCUE=in.get_int();
	if !in.last_succeeded() then break; end;
	delay1=in.get_int();
	if !in.last_succeeded() then break; end;
	dis1=in.get_int();
 	if !in.last_succeeded() then break; end;
 	codDIS=in.get_int();
 	if !in.last_succeeded() then break; end;
   in.set_delimiter('\"');
   DIS=in.get_line();
   DIS=in.get_line();
   if !in.last_succeeded() then break; end;
   in.set_delimiter('\n');
   delay2=in.get_int();
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
   ISIrand=in.get_int();
   if !in.last_succeeded() then break; end;
   in.get_line(); 
   
# == Attribution of Events and Trials Names == #
# Output for the matlab code: low_L(A) high_L (B) high_R (C) low_R (D) Blank (E)

	TAR=TAR+(".wav");

	if dis1==0 then
		dis=1;
	else
		dis=2;
	end;
   
	DIS=DIS+(".wav");
   Sound_tar_1_low_wav.set_filename(DIS);
	Sound_tar_1_high_wav.set_filename(DIS);
	Sound_dis_wav.set_filename(DIS);
 
	# Cue + Dis
   
	if (cue=="Larrow") then
     event_cue.set_stimulus(Larrow);
     event_cue_dis.set_stimulus(Larrow);
     cuefic=1;
   end;
	
	if (cue=="Rarrow") then
     event_cue.set_stimulus(Rarrow);
     event_cue_dis.set_stimulus(Rarrow);
     cuefic=2;
   end;
   
	if (cue=="Barrow") then
     event_cue.set_stimulus(Barrow);
     event_cue_dis.set_stimulus(Barrow);
     cuefic=0;
   end;
   
	if (DIS!="nul.wav") then
     Sound_dis.get_wavefile().load();
     event_cue_dis.set_event_code(string(codCUE));
		event_cue_dis.set_port_code(codCUE);
     event_dis.set_event_code(string(codDIS));
		event_dis.set_port_code(codDIS);

     if(final_attc>=final_atta) then
       Sound_dis.set_pan(-att_sDISd+att_sDISg);
       Sound_dis.set_attenuation(att_sDISg); # Commented to avoid a bug
     else
       Sound_dis.set_pan(att_sDISd-att_sDISg);
       Sound_dis.set_attenuation(att_sDISd);
     end;
   else
     event_cue.set_event_code(string(codCUE));
		event_cue.set_port_code(codCUE);
   end;  
   
	trial_cue.set_duration(dur_cue+delay1+delay_plus1+dur_sDIS+delay2+delay_plus2);
   trial_cuedis.set_duration(dur_cue+delay1+delay_plus1+dur_sDIS+delay2+delay_plus2);
   event_dis.set_delta_time(dur_cue+delay1+delay_plus1);
   
   random_trial[dis].present();
   
	if (bool( response_manager.response_count() )) then
	  fa=fa+1; # false alarms 
	  rep_before_tar=response_manager.response_count();;
	  rec_time=0;
	end;

	# Target
	
	if (TAR=="S_tarson_A.wav") then
		Sound_tar_1_low.set_pan(-1.0);# Max left attenuation
		Sound_tar_1_low.set_attenuation(att_sTARa);
		#Sound_tar_1_low.set_attenuation(att_sTARb);
		tar=1;
		trial_tar1_low.set_duration(dur_sTAR+max_rep+rep_plus+ISIrand);
		event_target1_low.set_target_button(bp);	#determine la reponse attendue 	
		event_target1_low.set_event_code(string(codTAR));
		event_target1_low.set_port_code(codTAR);
		trial_tar1_low.present();
	end;
	
	if (TAR=="S_tarson_B.wav") then
		Sound_tar_1_low.set_pan(1.0);# Max right attenuation
		Sound_tar_1_low.set_attenuation(att_sTARb); 
		tar=2;
		trial_tar1_low.set_duration(dur_sTAR+max_rep+rep_plus+ISIrand);
		event_target1_low.set_target_button(bp);#determine la reponse attendue 	
		event_target1_low.set_event_code(string(codTAR));
		event_target1_low.set_port_code(codTAR);
		trial_tar1_low.present();
	end;
	
		if (TAR=="S_tarson_C.wav") then
		Sound_tar_1_high.set_pan(-1.0);# Max left attenuation
		Sound_tar_1_high.set_attenuation(att_sTARc);
		#Sound_tar_1_high.set_attenuation(att_sTARd);
		tar=3;
		trial_tar1_high.set_duration(dur_sTAR+max_rep+rep_plus+ISIrand);
		event_target1_high.set_target_button(bp);	#determine la reponse attendue 	
		event_target1_high.set_event_code(string(codTAR));
		event_target1_high.set_port_code(codTAR);
		trial_tar1_high.present();
	end;
	
	if (TAR=="S_tarson_D.wav") then
		Sound_tar_1_high.set_pan(1.0);# Max right attenuation
		Sound_tar_1_high.set_attenuation(att_sTARd);
		tar=4;
		trial_tar1_high.set_duration(dur_sTAR+max_rep+rep_plus+ISIrand);
		event_target1_high.set_target_button(bp);#determine la reponse attendue 	
		event_target1_high.set_event_code(string(codTAR));
		event_target1_high.set_port_code(codTAR);
		trial_tar1_high.present();
	end;
	
	if (bool( response_manager.response_count() )) then
     response_data last = response_manager.last_response_data();
     rep=last.button();
     stimulus_data last1 = stimulus_manager.last_stimulus_data();
     rec_time=last1.reaction_time();
     nbrep=response_manager.response_count(); 
   else
   missrep=missrep+1;
     rec_time=0;  
   end;  
    
	if (nbrep>0) then
     if(nbrep)>1 then
       multirep=multirep+1;
       meantr.add(rec_time);
       rec_time=0;
     else  
       meantr.add(rec_time);
     end;  
  end;

	if rep == bp then
		correct=correct+1;
	else
		incorrect=incorrect+1;
	end;
	
	if cuefic != 0 then 
		if dis1==0 then
			meantr_val.add(rec_time);
		else
		meantr_inval.add(rec_time);
		end;
	end;  
	
# Write Trial
     out.print(i);
     out.print("	");
     out.print(cuefic);
     out.print("	");
     out.print(delay1);
     out.print("	");    
     out.print(dis1);
     out.print("	");
     out.print(delay2);
     out.print("	"); 
     out.print(tar);
     out.print("	");
     out.print(bp);
     out.print("	");
     out.print(rep);
     out.print("	");
     out.print(rep_before_tar);
     out.print("	");
     out.print(nbrep);
     out.print("	");
     out.print(rec_time);
     out.print("\n");
	if(DIS!="nul.wav") then
	Sound_dis.get_wavefile().unload();
	end;

	i=i+1;
end;

moytr=floor(arithmetic_mean(meantr));
moytr_val=floor(arithmetic_mean(meantr_val));
moytr_inval=floor(arithmetic_mean(meantr_inval));
cue_check= moytr_inval - moytr_val; 

# == Write Block Results == # 
out.print("\n");
out.print("nb trial with correct rep:");
out.print(correct);
out.print("\n");
out.print("nb trial with incorrect rep:");
out.print(incorrect);
out.print("\n");
out.print("nb trial with no rep:");
out.print(missrep);
out.print("\n");
out.print("Average RT:");
out.print(moytr); 
out.print("\n");
out.close();
in.close();

#== Average Reaction Time ==#

if cue_check > 19.0 then 
	text1.set_caption("temps de reaction "+string(moytr)+" + \n correct trials = "+string(correct)+" / 9 \n  Press Enter To Continue."); 
	text1.redraw();
	info_trial2.present();
else
	text1.set_caption("temps de reaction "+string(moytr)+" - \n correct trials = "+string(correct)+" / 9 \n  Press Enter To Continue."); 
	text1.redraw();
	info_trial2.present();
end; 