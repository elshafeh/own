function [gradlabels maglabels indgrad indmag]=obob_selchans(origLabel)
%Helper function that splits the origLabel field into mags and grads

mn=1;
gn=1;
for i=1:length(origLabel)
    if strncmp(fliplr(cell2mat(origLabel(i))),'1',1)
        maglabels{mn}=cell2mat(origLabel(i));
        indmag(mn)=i;
        mn=mn+1;
    else
        gradlabels{gn}=cell2mat(origLabel(i));
        indgrad(gn)=i;
        gn=gn+1;
    end
end

maglabels=maglabels';
gradlabels=gradlabels';

