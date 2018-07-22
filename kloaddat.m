function dataset = kloaddat(fn)

%This function is used with ksxm to read DAT files.
%This is a modefied version of loaddat.m

if exist(fn, 'file')
        fid = fopen(fn, 'r', 'ieee-be');    % open with big-endian
else
        fprintf('File does not exist.\n');
        return;
end

s1 = fgetl(fid);

%Retrieving information from header

while ~strcmp(s1,'[DATA]')
    
    
    s2 = strsplit(s1,'\t');
    s3 = s2{1};
    s3 = s3(isletter(s3)); %Remove spaces from variable name
    if ~strcmp(s3,'')
        dataset.Params.(lower(s3)) = s2{2};
    end
        s1 = fgetl(fid);
    
end

% Retrieving the Column Headers for the data. 
s1 = fgetl(fid);
dataset.Labels= strsplit(s1,'\t')';

%Retrieving the actual data.
dataset.Data=[];
s1 = fgetl(fid);

while ~strcmp(class(s1),'double')
    s2 = str2double(strsplit(s1,'\t'));
    dataset.Data=[dataset.Data; s2];
    s1 = fgetl(fid);
end

fclose(fid);

