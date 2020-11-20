function Generate_info_file(pnum,psession,ID,safeID,IAF,IAF_dB,file_ID,info_path)

info_id=fopen(fullfile(info_path,[file_ID '_info.m']),'w');
fprintf(info_id,'part.safe_ID=%i;  \n',safeID);
fprintf(info_id,'part.number=%i;  \n',pnum);
fprintf(info_id,'part.session=%i;  \n',psession);
fprintf(info_id,'part.ID=''%s'';  \n',ID);
fprintf(info_id,'part.Bad_channel={'' ''};  \n');
fprintf(info_id,'part.ref_chan={''LM'',''RM''}; \n');
fprintf(info_id,'part.layout=''ActiCap64_MM_PO.lay''; \n');
fprintf(info_id,'part.comment=''none''; \n');
fprintf(info_id,'part.IAF=%4.2f ;%%Position of the peak (dB) \n',IAF);
fprintf(info_id,'part.IAFdB=%4.2f ;%%Height of the peak (dB) \n',IAF_dB);
fprintf(info_id,'part.file_ID=''%s'' ;%%Prefix for acessing files \n',file_ID);
fclose(info_id);