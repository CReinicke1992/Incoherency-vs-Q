% data = load('Data/Data_red_Delphi_Bandlimited.mat');
% p = data.data_fil3d;
% 
% figure; imagesc(squeeze(p(:,1,:)));

in = load('Parameters/incoherency.mat');
incoherency = in.incoherency; clear in

[in,reps] = size(incoherency);

for iter = 1:in
    for rep = 1:reps
        
    end
end