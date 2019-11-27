% case folders e.g. 'case_0', 'case_1' etc. should be located in 'data' folder
addpath("data");

casefolders = dir("data");
casefolders = casefolders(3:end);

U_breakpoints = zeros(length(casefolders), 1);

for casefolder = 0:(length(casefolders) - 1)
    casefolderpath = strcat("data/", "case_", num2str(casefolder));
    addpath(casefolderpath);
    
    if casefolder == 0
        [I, m] = read_tab(strcat("config_00", num2str(casefolder), ".tab"), 'TOTISI', 'VMASSSI');
        Ixx = I(1);
        Ixz = I(3);
        Iyy = I(4);
        Izz = I(6);
    end
    
    U_case = read_tab(strcat("config_00", num2str(casefolder), ".tab"), 'VEQ');
    
    U_breakpoints(casefolder + 1) = convvel(U_case, 'kts', 'm/s');
    
    [FR(:, :, casefolder + 1),...
        GR(:, :, casefolder + 1),...
        TRIM(:, :, casefolder + 1)] = read_tab(strcat("linearize_", num2str(casefolder), ".tab"), 'FR', 'GR', 'TRIM');
    
    rmpath(casefolderpath)
end

clearvars casefolder casefolders casefolderpath I U_case

g = -9.81;

M = [Ixx, 0, -Ixz;
    0, Iyy, 0;
    -Ixz, 0, Izz];
M = [eye(3)*m, zeros(3);
    zeros(3) , M];