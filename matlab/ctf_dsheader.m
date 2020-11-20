function value_label=ctf_dsheader(ds,label)


%executes CTF dshead function and extracts the value of the specified label
%useful to check very quickly whether a set of datasets were recorded with the
%same configuration parameters ....
%inputs
%ds=char; name of the dataset
%label=char; name of the label : 'Channels', 'Trials', 'File Gradient',
%'Samples', 'Rate'
%outputs
%value_label=value of the label


%o*o*o*o*o*o*o*o*o*o*o*o*o**o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o
% auteur : F.Lecaignard  
% 16/12/2010 : creation
%o*o*o*o*o*o*o*o*o*o*o*o*o**o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o*o



ficlog=[ ds '/dsheader.log'];
fid=fopen(ficlog,'r');
C=textscan(fid,'%s%s%s%s%s%s');
fclose(fid);

value_label=[];

switch label 
    case 'Channels'
        h=strmatch('Channels',C{1});
        val=C{2};
        value_label=str2num(val{h});
    case 'File Gradient'
        h=strmatch('File',C{1});
        val=C{3};
        value_label=str2num(val{h});
    case 'Trials'
        h=strmatch('Trials',C{1})
        val=C{3}
        value_label=str2num(val{h});
    case 'Samples'
        h=strmatch('Samples',C{1});
        val=C{3};
        value_label=str2num(val{h});
    case 'Rate'
        h=strmatch('Rate',C{1});
        val=C{3};
        value_label=str2num(val{h});
    case 'Duration'
        h=strmatch('Duration',C{1});
        val=C{2};
        value_label=str2num(val{h});
end