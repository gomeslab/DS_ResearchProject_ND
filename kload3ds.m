function datasets = kload3ds(fn)
%   This is a modified version of load3ds
%   load3ds  Nanonis 3ds file loader
%   datasets = load3ds(fn, pt_index) reads a Nanonis 
%   3ds file fn.
   

header='';

if exist(fn, 'file')
    fid = fopen(fn, 'r', 'ieee-be');    % open with big-endian
else
    fprintf('File does not exist.\n');
    return;
end

% read header data
% The header consists of key-value pairs, separated by an equal sign,
% e.g. Grid dim="64 x 64". If the value contains spaces it is enclosed by
% double quotes (").
while 1
    s = strtrim(fgetl(fid));
    if strcmpi(s,':HEADER_END:')
        break
    end
    
    s1 = strsplit(s,'=');

    s_key = strrep(lower(s1{1}), ' ', '_');
    s_val = strrep(s1{2}, '"', '');
    
    switch s_key
        
        % dimension:
        case 'grid_dim'
            s_vals = strsplit(s_val, 'x');
            header.grid_dim = [str2num(s_vals{1}), str2num(s_vals{2})];
            
            % grid settings
        case 'grid_settings'
            header.grid_settings = sscanf(s_val, '%f;%f;%f;%f;%f');
            
            % fixed parameters, experiment parameters, channels:
        case {'fixed_parameters', 'experiment_parameters', 'channels'}
            s_vals = strsplit(s_val, ';');
            header.(s_key) = s_vals;
            
            % number of parameters
        case '#_parameters_(4_byte)'
            header.num_parameters = str2num(s_val);
            
            % experiment size
        case 'experiment_size_(bytes)'
            header.experiment_size = str2num(s_val);
            
            % spectroscopy points
        case 'points'
            header.points = str2num(s_val);
            
            % delay before measuring
        case 'delay_before_measuring_(s)'
            header.delay_before_meas = str2num(s_val);
                        
            % other parameters -> treat as strings
        otherwise
            s_key = regexprep(s_key, '[^a-z0-9_]', '_');
            if length(s_key)>63, s_key = 'bias_spec_settings'; end;
            header.(s_key) = s_val;
    end
end

datasets.Params=header;


% read the data 

numX = header.grid_dim(1);
numY = header.grid_dim(2);
numZ = header.points;

datasets.Topo = zeros(numX,numY); %should only need a 2d map for the topo
newCh = strtok(header.channels); %only keeps the title of the channel up to the space
numCh = size(newCh,2);

%initialize 3d matrices to store data from all of the points. 
for i = 1:numCh
    datasets.(newCh{i})=zeros(numX,numY,numZ);
end;

fseek(fid, 0, 0);

%now we need to actually get the data from all the spots in the grid
for i = 1:numX
    for j = 1:numY
        par = fread(fid, header.num_parameters, 'float');%The Z(m) is stored as parameter.
%         datasets.Topo(i,j,:) = par(5);
        datasets.par{i,j}=par;
        
        data = fread(fid, [header.points numel(header.channels)], 'float');
        
        for data_index= 1:numCh
            datasets.(newCh{data_index})(i,j,:) = data(:,data_index);
        end      
    end
end

fclose(fid);

end  



