function dataset=kloadsxm(fn)

%This function is used with ksxm to read SXM files.
%This is a modefied version of loadsxm.m

if exist(fn, 'file')
    fid = fopen(fn, 'r', 'ieee-be');    % open with big-endian
else
    fprintf('File does not exist.\n');
    return;
end

% check whether file is a Nanonis data file.
s1 = fgetl(fid);
if ~strcmp(s1, ':NANONIS_VERSION:')
    fprintf('File seems not to be a Nanonis file\n');
    return;
end


% get header
header.version = str2double(fgetl(fid));
read_tag = 1;

% read header data
% The header consists of key-value pairs. Usually the key is on one line, embedded in colons
% e.g. :SCAN_PIXELS:, the next line contains the value.
% Some special keys may have multi-line values (like :COMMENT:), in this case read value
% until next key is detected (line starts with a colon) and set read_tag to 0 (because key has
% been read already).

while 1
    if read_tag
        s1 = strtrim(fgetl(fid));
    end
    s1 = s1(2:length(s1)-1); % remove leading and trailing colon
    read_tag = 1;
    switch s1
        % strings:
        case {'SCANIT_TYPE', 'REC_DATE', 'REC_TIME', 'SCAN_FILE', 'SCAN_DIR'}
            s2 = strtrim(fgetl(fid));
            header.(lower(s1)) = s2;
            % comment:
        case 'COMMENT'
            s_com = '';
            s2 = strtrim(fgetl(fid));
            while ~strncmp(s2, ':', 1)
                s_com = [s_com s2 char(13)];
                s2 = strtrim(fgetl(fid));
            end
            header.comment = s_com;
            s1 = s2;
            read_tag = 0; % already read next key (tag)
            % Z-controller settings:
        case 'Z-CONTROLLER'
            header.z_ctrl_tags = strtrim(fgetl(fid));
            header.z_ctrl_values = strtrim(fgetl(fid));
            % numbers:
        case {'BIAS', 'REC_TEMP', 'ACQ_TIME', 'SCAN_ANGLE'}
            s2 = fgetl(fid);
            header.(lower(s1)) = str2num(s2);
            % array of two numbers:
        case {'SCAN_PIXELS', 'SCAN_TIME', 'SCAN_RANGE', 'SCAN_OFFSET'}
            s2=fgetl(fid);
            header.(lower(s1)) = sscanf(s2, '%f');
            % data info:
        case 'DATA_INFO'
            s = '';
            s2=strtrim(fgetl(fid));
            while length(s2)>2
                s = sprintf('%s\n%s', s, s2);
                s2 = strtrim(fgetl(fid));
            end
            header.data_info = s;
        case 'SCANIT_END'
            break;
        otherwise % treat as strings
            s1 = regexprep(lower(s1), '[^a-z0-9_]', '_');
            s_line = strtrim(fgetl(fid));
            s2 = '';
            while ~strncmp(s_line, ':', 1)
                s2 = [s2 s_line char(13)];
                s_line = strtrim(fgetl(fid));
            end
            header.(s1) = s2;
            s1 = s_line;
            read_tag = 0; % already read next key (tag)
    end
end

% \1A\04 (hex) indicates beginning of binary data
s1 = [0 0];
while s1~=[26 4]
    s2 = fread(fid, 1, 'char');
    s1(1) = s1(2);
    s1(2) = s2;
end

%Counting how many channels there are
datainfo = strsplit(header.data_info);
datainfo = datainfo(2:end);
nChannel = size(datainfo,2)/6-1;

%Readind data
pix = header.scan_pixels;

for nc=1:nChannel,
    data = fread(fid, [pix(1) pix(2)], 'float');
    data = transpose(data);
    dataset.(strcat(datainfo{(nc)*6+2},'f'))=data;
    if strcmp(datainfo{nc*6+4},'both'),
        data = fread(fid, [pix(1) pix(2)], 'float');
        data = transpose(data);
        dataset.(strcat(datainfo{(nc)*6+2},'b'))=data;
    end
end


fclose(fid);

dataset.Params=header;
