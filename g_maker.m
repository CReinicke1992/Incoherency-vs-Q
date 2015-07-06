close all
clear
addpath('../../Incoherency/Diagonal-Relation/Incoherency-Functions')

%% Create a 3d blending matrix

% * b must be a divisor of Nsx = 21 -> The blending matrix is can descibe 3d blending

% Parameters
Ns  = 1071;     % Number of sources
b   = 3;        % Blending factor
dt  = 0.004;    % Sampling rate: Seconds per sample
tg  = 100;      % Maximum time delay in time samples
Nt  = 301;      % Number of time samples
pattern = 0;    % Blending pattern (Time + Space)


% Patterns:
% 0     Time
% 1     Time Space Experiment
% 2     Time Space
% 3     Space
% 4     None

% Exerimentally combinations for different incoherency values
%                   % Incoherency (%)
b_tg = [ 63, 7;     % 5
         21, 2;     % 10
         21, 5;     % 15
         21, 7;     % 20
         21, 10;    % 25
         21, 12;    % 30 
         21, 14;    % 35
         21, 17;    % 40
         21, 21;    % 45
         21, 23;    % 50
         21, 27;    % 55
         21, 31;    % 60 
         21, 38;    % 65
         21, 45;    % 70
         21, 53;    % 75
         7 , 14;    % 80
         7 , 19;    % 85
         7 , 24;    % 90
         7 , 45;    % 95
         3 , 200 ]; % 100
     
reps = 10; % Repetitions per incoherency

% incoherency: tg/b combi x repetition
incoherency = zeros(size(b_tg,1),reps);
time = zeros(size(incoherency));


for iter = 1:size(b_tg,1)
    
    b = b_tg(iter,1);
    tg = b_tg(iter,2);
    
    for rep = 1:reps
        
        sprintf('iter = %d / %d, rep = %d / %d',iter,size(b_tg,1),rep,reps)
        
        tic;
        
        [G3,g3] = crane(Ns,Nt,b,tg,pattern);
        
        
        g = g3dto2d(g3);
        path = strcat('g-matrices/','in',num2str(iter*5),'-rep',num2str(rep),'.mat');
        save(path,'g')
        
        %% Compute GGH, sum along diagonals, and sum over all frequency components
        
        % Initialize matrix to save the sums along diagonals for each frequency
        % component separately
        diagsum = zeros(2*Ns-1,Nt);
        
        % Iterate over all frequency components
        for w = 1:size(G3,3)
            
            % Compute G*Gh
            G = squeeze( G3(:,:,w) );
            Gh = G';
            GGH = G*Gh;
            
            % Sum along diagonals
            % Save the result in diagsum
            for dia = 1-Ns:Ns-1
                diagsum(dia+Ns,w) =  abs( sum(diag(GGH,dia)) );
            end
            
        end
        
        % Sum over all frequency components
        % Ideally the output is the autocorrelation with respect to source lag
        autocorr = sum(diagsum,2);
     
        in = autocorr(Ns,1)^2 / sum(autocorr.^2);
        
        incoherency(iter,rep) = in;
        time(iter,rep) = toc;
    end
end

save('Parameters/incoherency.mat','incoherency');
save('Parameters/time.mat','time');
