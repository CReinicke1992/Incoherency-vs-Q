%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PURPOSE

% * Load g matrices with varying incoherencies
% * Blend and deblend a data set with these g matrices
% * Save all quality factors to compare deblending quality vs incoherency
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% 1 Load Functions & data

addpath('Functions/')


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

% Load the fkmask which is in Cartesian format
fileID = 'Data/fkmask_red.mat';
FKmask = load(fileID); clear fileID
fkmask = FKmask.mask; clear Fkmask

%% 2 Load blending parameters & initialize quality + time matrices

% Incoherency matrix
in = load('Parameters/incoherency.mat');
incoherency = in.incoherency; clear in
[in,reps] = size(incoherency);

% Quality matrix
Q = zeros(in,reps);

% Time matrix
time = zeros(in,reps);


%% 3 Iterate over all g matrices

total = tic;

for iter = 1:in
    
    for rep = 1:reps
        
        loop = tic;
        
        % Indicate iteration numbers
        sprintf('iter = %d / %d, rep = %d / %d',iter,in,rep,reps)
        
        % Load g matrix
        fileID = strcat('g-matrices/','in',num2str(iter*5),'-rep',num2str(rep),'.mat');
        gamma = load(fileID);
        g = gamma.g; 
        
        % Blend and deblend the data with g
        [~,q] = blend_deblend(data,Nri,Nsi,fkmask,g);
        
        % Save quality factor and computing times
        Q(iter,rep) = q;
        t = toc(loop);
        time(iter,rep) = t;
        
    end
end

% Stop total time
total_time = toc(total);

% Save quality + time matrices and total computing time
save('Parameters/quality.mat','Q');
save('Parameters/deblending_time.mat','time');
save('Parameters/total_time_blending_master.mat','total_time');
