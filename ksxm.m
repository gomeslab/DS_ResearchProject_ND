function data = ksxm(filename)
% Reads multiple SXM files. 
% You can give the name of the file to open.
% For multiple files, use {}.
% To select files wi4h browser, just call function without anything.

%data=struct;
if nargin == 0,
    filter = {'*.sxm','SXM Data Files'};
    [files, fpath] = uigetfile(filter, 'Select STM data...','Multiselect','on');
    if isequal(files,0), 
        fprintf('User selected Cancel.\n')
        return;
    end;
    filename = strcat(fpath, files);
end;

if iscell(filename)
    for i=1:length(filename)
        data{i}=kloadsxm(filename{i});
    end;
else
    data=kloadsxm(filename);
end;

