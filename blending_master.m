data = load('Data/Data_red_Delphi_Bandlimited.mat');
p = data.data_fil3d;

figure; imagesc(squeeze(p(:,1,:)));