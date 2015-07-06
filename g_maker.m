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

% Vary b = 1,3,7,21
% Vary tg = 1,10,50,100
% incoherency bxtg
incoherency = zeros(4,4);
time = zeros(size(incoherency));

% Patterns:
% 0     Time
% 1     Time Space Experiment
% 2     Time Space
% 3     Space
% 4     None

ind_b = 1;
for b = [3,1]
    
    ind_tg = 1;
    for tg = [200,10,50,100]
        
        sprintf('b = %d, tg = %d.',b,tg)
        
        tic;
        
        [G3,g3] = crane(Ns,Nt,b,tg,pattern);
        
        
        g = g3dto2d(g3);
        path = strcat('g-matrices/','tg',num2str(tg),'-b',num2str(b),'.mat');
        %save(path,'g')
        
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
        
%         figure(2); plot( autocorr(:,1) ); title('autocorrelation for summed frequencies');
%         figure(3); plot( diagsum(:,3) ); title('autocorrelation of w = 3');
        
        
        in = autocorr(Ns,1)^2 / sum(autocorr.^2);
        
        incoherency(ind_b,ind_tg) = in;
        time(ind_b,ind_tg) = toc;
        
        ind_tg = ind_tg + 1;
        return
    end
    ind_b = ind_b + 1;
end

save('Parameters/incoherency.mat','incoherency');
save('Parameters/time.mat','time');
