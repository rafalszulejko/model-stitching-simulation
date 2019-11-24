function [FR, GR, HR, DR, TRIM] = read_case(filename)
    
    function res = trim_nans(vec)
        while isnan(vec(end))
            vec = vec(1:(length(vec)-1));
        end
        
        res = vec;
    end

    file = fopen(filename, 'r');
    
    line = fgetl(file);
    
    while line(1) == '#'
        line = fgetl(file);
    end

    while ~feof(file)
        tabinfo = split(line, ' ');
        tab_h = str2num(cell2mat(tabinfo(2)));
        tab_w = str2num(cell2mat(tabinfo(3)));
        
        tabname = cell2mat(tabinfo(1));
        
        tempfilename = strcat(tabname, '.dat');
        tempfile = fopen(tempfilename, 'w');
        
        line = fgetl(file);

        while ~isempty(line) && ~feof(file)
            fprintf(tempfile, line);
            fprintf(tempfile, '\n');
            line = fgetl(file);
        end
        
        fprintf(tempfile, line);
        
        if ~feof(file)
            line = fgetl(file);
        end
        
        fclose(tempfile);
        
        reshapedtab = readmatrix(tempfilename);

        reshapedtab = reshape(...
            trim_nans(...
            reshape (reshapedtab', [numel(reshapedtab) 1])'), [tab_h, tab_w]);
        
        switch tabname
            case 'FR'
                FR = reshapedtab;
            case 'GR'
                GR = reshapedtab;
            case 'HR'
                HR = reshapedtab;
            case 'DR'
                DR = reshapedtab;
            case 'TRIM'
                TRIM = reshapedtab;
            otherwise
                fprintf("unexpected matrix name");
        end
        
        delete(tempfilename);
    end
    
    fclose(file);
end