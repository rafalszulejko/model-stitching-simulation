function varargout = read_tab(filename, varargin)
    %% safety checks and setup
    narginchk(2, inf);
    
    if nargin - 1 ~= nargout
        error("Number of required variables and output length don't match.")
    end

    file = fopen(filename);
    
    line = fgetl(file);
    
    vars_read = 0;
    %% skip all comments
    function skipcomments()
        while line(1) == '#'
            line = fgetl(file);
        end
    end

    skipcomments()
    %% read matrices
    while ~feof(file)
        tabinfo = split(line, ' ');
        
        tabname = cell2mat(tabinfo(1));
        
        if ~ismember(tabname, varargin)
            line = fgetl(file);
            while ~isempty(line) && ~feof(file) && ~isletter(line(1))
                line = fgetl(file);
            end
            
            continue
        end
        
        tab_pos = find(cellfun(@(x) isequal(x, tabname), varargin));
        
        tab_h = str2num(cell2mat(tabinfo(2)));
        tab_w = str2num(cell2mat(tabinfo(3)));
        
        tempfilename = strcat(tabname, '.dat');
        tempfile = fopen(tempfilename, 'w');
        
        line = fgetl(file);
        
        skipcomments();

        while ~isempty(line) && ~feof(file) && line(1) == ' '
            fprintf(tempfile, line);
            fprintf(tempfile, '\n');
            line = fgetl(file);
        end
        
        if feof(file)
            fprintf(tempfile, line);
        else
            if isempty(line)
                line = fgetl(file);
            end
        end
        
        
        fclose(tempfile);
        
        reshapedtab = readmatrix(tempfilename);

        varargout{tab_pos} = reshape(...
            trim_nans(...
            reshape (reshapedtab', [numel(reshapedtab) 1])'), [tab_w, tab_h]).';

        delete(tempfilename);
        
        vars_read = vars_read + 1;
        
        if vars_read == nargin - 1
            break
        end
    end
    
    if vars_read < nargin - 1
        error("Not all requested variables were found in the file.");
    end
    
    fclose(file);
end

function res = trim_nans(vec)
    while isnan(vec(end))
        vec = vec(1:(length(vec)-1));
    end

    res = vec;
end