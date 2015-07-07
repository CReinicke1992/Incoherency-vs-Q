% Locarion: /Users/christianreinicke/Dropbox/MasterSemester/SyntheticData/Deblending/Functions
% It is assumed that this function is called from the folder 'Deblending'
% The function loads data, fkmask and parameters automatically
% The input variables should allow to use different blending designs

% INPUT



function [debl,Q] = blend_deblend(data,Nri,Nsi,fkmask,g)

[Nt,Nr,Ns] = size(data);
Ne = size(g,2);
b = Ns/Ne;

%% 4 Pad data with zeros to avoid wrap arounds in time

% Maximum time shift
pad = max(g(:)); 

% As inititally the function deblend.m expected an even t_g, I use an even
% pad number to avoid stupid errors.
if mod(pad,2) ~= 0
    pad = pad + 1;
end

% Update Nt
NT = Nt + pad;

% Append zeros to the data
p_new           = zeros(NT,Nr,Ns,'single');
p_new(1:Nt,:,:) = data;
data            = p_new; clear p_new;


%% 5 BLENDING

% Blend
data_bl = blend(data,g); 

%% 6 DEBLENING

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

