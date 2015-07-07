
% * Modified version of /Users/christianreinicke/Dropbox/MasterSemester/SyntheticData/Deblending/Functions/blend_deblend.m
% * Main differences:
%   -> Data and fkmask are input parameters, they are not loaded in the
%      function
%   -> The results are not saved
%   -> Only the quality factor is of interest
%   -> Q is returned and saved in quality_master.m
%   -> All g matrices are saved so if the data corresponding to a specific
%      Q is needed the deblending can be done for this g matrix and saved 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT
% * data    Unblended data in Delphi format
% * Nri     Number of inline receivers
% * Nsi     Number of inline sources
% * fkmask  fkk mask (I think it can be Delphi or Cartesian format)
% * g       Blending matrix (the format which is read by blend.m)

% OUTPUT
% * debl    Deblended data
% * Q       Quality factor of the deblended data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [debl,Q] = blend_deblend(data,Nri,Nsi,fkmask,g)


%% 1 Define parameters

[Nt,Nr,Ns] = size(data);
Ne = size(g,2);
b = Ns/Ne;

%% 2 Pad data with zeros to avoid wrap arounds in time

% Maximum time shift
pad = max(g(:)); 

% As inititally the function deblend.m expected an even t_g, I use an even
% pad number to avoid stupid errors.
% Possible idea: 
% * fft performs better for odd number of time samples
% * Assume data with an odd number of time samples is input
% * Then an even tg guarantees that Nt remains odd
if mod(pad,2) ~= 0
    pad = pad + 1;
end

% Update Nt
NT = Nt + pad;

% Append zeros to the data
p_new           = zeros(NT,Nr,Ns,'single');
p_new(1:Nt,:,:) = data;
data            = p_new; clear p_new;


%% 3 BLENDING

% Blend
data_bl = blend(data,g); 

%% 4 DEBLENING

%%%%%%%%%%%%%%%%%%%%%%%%%%
% PREPARATION

% Step 1: Pseudo deblend
data_ps = blend(data_bl,-g',1/b); clear data_bl

% Throw away data which cannot be correct
data_ps(Nt+1:end,:,:) = 0;

% First estimate of the deblended data p
p = data_ps;

% Maximum value for thresholding
max_val = max(abs( p(:) )); 
%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%
% ITERATIONS

% Number of iterations
Niter = 100; 

for iter = 1:Niter
    
    %disp([' iteration: ',num2str(iter)]);
    
    % Step 2: fk filter in the receiver domain
    p(1:Nt,:,:) = fk3d_mod(p(1:Nt,:,:),fkmask,Nri,Nsi);
    
    % Step 3: Threshold, the treshold goes down to zero after all iterations
    % threshold = max_val - max_val/Niter * iter; 
    threshold = max_val * 0.9^(iter);
    p(abs(p)<threshold) = 0;
    
    % Throw away data which cannot be correct
    p(Nt+1:end,:,:) = 0;
    
    % Step 4: estimate noise
    n = blend(blend(p,g),-g',1/b) - p;
    
    % Step 5: subtract noise from pseudo deblended result
    p = data_ps - n;
    
    % Throw away data which cannot be correct
    p(Nt+1:end,:,:) = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%
clear data_ps n g

% Output the deblended data
debl = p(1:Nt,:,:); clear p

% Quantify the performance of the deblending based on Ibrahim
Q = quality_factor(data(1:Nt,:,:),debl);

