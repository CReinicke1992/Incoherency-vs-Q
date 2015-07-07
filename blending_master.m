% data = load('Data/Data_red_Delphi_Bandlimited.mat');
% p = data.data_fil3d;
% 
% figure; imagesc(squeeze(p(:,1,:)));


% For simplicity load only a small part of the data
% Load the bandlimited data in Delphi format
fileID  = 'Data/Data_red_Delphi_Bandlimited.mat';
my_data = load(fileID); clear fileID
data    = my_data.data_fil3d; clear my_data


% Load the paramteres which belong to the loaded data, in this case it is
% the reduced data
fileID = 'Parameters/Parameters_red.mat';
Parameters_red = load(fileID); clear fileID
Nri  = Parameters_red.Nri;   % Number of inline receivers
Nsi  = Parameters_red.Nsi;   % Number of inline sources
clear Parameters_red




% Incoherency matrix
in = load('Parameters/incoherency.mat');
incoherency = in.incoherency; clear in
[in,reps] = size(incoherency);


% Blending parameters
blend_pars = load('Parameters/Blending_pars.mat');
b_tg = blend_pars.b_tg; clear blend_pars

for iter = 1:in
    
    % Blending factor
    b = b_tg(iter,1);
    
    for rep = 1:reps
        
        % Indicate iteration numbers
        sprintf('iter = %d / %d, rep = %d / %d',iter,size(b_tg,1),rep,reps)
        
        % Load g matrix
        fileID = strcat('g-matrices/','in',num2str(iter*5),'-rep',num2str(rep),'.mat');
        gamma = load(fileID);
        g = gamma.g; 
        
    end
end