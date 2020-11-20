clear;

for nproject = [4 5 6]
    
   flist            = dir(['P:/3015039.0' num2str(nproject) '/bil/tf/*mat']); 
   
   for nfile = 1:length(flist)
       
       fname_in     = [flist(nfile).folder filesep flist(nfile).name];
       fname_out    = ['I:/bil/tf/' flist(nfile).name];
       fprintf('moving file %5d out of %5d : %s \n',nfile,length(flist),fname_in);
       movefile(fname_in,fname_out);
       
   end
end