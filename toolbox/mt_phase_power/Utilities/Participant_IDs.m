function [Names_Test,Names_ReTest]=Participant_IDs(File_st,flag)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mireia Torralba 2017 (MRG group)
%
% Get file names for accepted preprocessed participants and check that
% record matches the contents of the follow-up excel file. 
%
% Inputs
%   File_st:    strucutre containing paths for loading files
%   flag:       string: Test(default),Retest or Both
% Outputs
%  Names_Test: cell array with names for Test Session
%  Names_ReTest: cell array with names for Re-Test Session
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if nargin<2
    flag='test';
end
   
flag=lower(flag);

contents=dir(File_st.preproc_files_path);
n=0;
clear Files
for i=1:length(contents)
    if (~contents(i).isdir) && strcmpi(contents(i).name(1), 'P')
        n=n+1;
        Files{1,n}=contents(i).name(1:22);
    end
end

Names=unique(Files);

%Participants=List(arrayfun(@(x) x.name(1), List) ~= '.');
%Participants=List(arrayfun(@(x) x.name(1), List) == 'P');
%Participants=Participants(arrayfun(@(x) x.isdir,Participants));
%Names=arrayfun(@(x) sscanf(x.name,'%s'),Participants,'UniformOutput',false);
Names_Test=Names(cell2mat(cellfun(@(x) (strcmp(x(5:9),'_S01_')),Names,'UniformOutput',false)));
Names_Test=cellfun(@(x) x(1:22),Names_Test,'UniformOutput',false);
Names_ReTest=Names(cell2mat(cellfun(@(x) (strcmp(x(5:9),'_S02_')),Names,'UniformOutput',false)));
Names_ReTest=cellfun(@(x) x(1:22),Names_ReTest,'UniformOutput',false);


% %Compare with participants available in Excel file
% [~,Excel_Names_Test]=xlsread(fullfile(File_st.preproc_main_path,'Accepted_participants.xlsx'),'Accepted_participants','A2:A500');
% [~,Excel_Names_ReTest]=xlsread(fullfile(File_st.preproc_main_path,'Accepted_participants.xlsx'),'Accepted_participants','B2:B500');



switch flag
    case 'test'
        %Check available files correspond to accepted participants
        [Selection,ok]=listdlg('PromptString','Select participants','SelectionMode','multiple','ListString',Names_Test);
        Names_Test=Names_Test(Selection);
      %  assert(ismember(Excel_Names_Test,Names_Test),'Mismatch between Test info files and Excel contents');
        
    case 'retest'
        [Selection,ok]=listdlg('PromptString','Select participants','SelectionMode','multiple','ListString',Names_ReTest);
        Names_ReTest=Names_ReTest(Selection);
       % assert(ismember(Excel_Names_ReTest,Names_ReTest),'Mismatch between Retest info files and Excel contents');
    case 'both'
        
         [Selection,ok]=listdlg('PromptString','Select participants','SelectionMode','multiple','ListString',Names_Test);
         Names_Test=Names_Test(Selection);
         [Selection,ok]=listdlg('PromptString','Select participants','SelectionMode','multiple','ListString',Names_ReTest);
        Names_ReTest=Names_ReTest(Selection);
       %  assert(ismember(Excel_Names_Test,Names_Test),'Mismatch between Test info files and Excel contents');
       %  assert(ismember(Excel_Names_ReTest,Names_ReTest),'Mismatch between Retest info files and Excel contents');
    otherwise
        error('Unvalid flag option. Please choose one of the following: Test, Retest, Both or leave empty for default (Test)');
end