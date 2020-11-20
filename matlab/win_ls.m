function win_ls(filename)

flist               = struct2table(dir(filename));

if height(flist) > 0
    
    sortedflist         = sortrows(flist,'date','descend');
    
    for nf = 1:height(sortedflist)
        
        tmp             = sortedflist.date(nf);
        tmp             = strsplit(tmp{1},' ');
        
        v_date          = strsplit(tmp{1},'-');
        v_day           = v_date{1};
        v_mnth       	= v_date{2};
        v_year          = v_date{3};
        
        v_time          = strsplit(tmp{2},':');
        v_hour          = v_time{1};
        v_min           = v_time{2};
        
        data{nf,1}      = sortedflist.name{nf};
        data{nf,2}      = v_day;
        
        month_list      = {'Jan' 'Feb' 'Mar' 'Apr' 'May' 'Jun' 'Jul' 'Aug' 'Sep' 'Oct' 'Nov' 'Dec'};
        
        data{nf,3}      = find(strcmp(v_mnth,month_list));
        
        if data{nf,3} < 10
            data{nf,3}  = ['0' num2str(data{nf,3})];
        else
            data{nf,3}  = num2str(data{nf,3});
        end
        
        data{nf,4}      = v_year;
        data{nf,5}      = v_hour;
        data{nf,6}      = v_min;
        
        
    end
    
    keep data;
    
    data                = cell2table(data,'VariableNames',{'name' 'day' 'month' 'year' 'hour' 'minutes'});
    data                = sortrows(data,{'year','month','day','hour','minutes'},'descend');
    
    for nf = 1:height(data)
        fprintf('%s-%s-%s\t%s:%s\t%s\n',data.day{nf},data.month{nf},data.year{nf},data.hour{nf},data.minutes{nf},data.name{nf});
    end
    
else
    
    disp('No files were found :(');
    
end