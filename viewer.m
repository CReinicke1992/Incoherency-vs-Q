% PURPOSE
% * Plot incoherency vs quality

quality = load('Parameters/quality.mat');
Q = quality.Q;

incoherency = load('Parameters/incoherency.mat');
in = incoherency.incoherency;

clear incoherency quality

in_m = mean(in,2);
Q_m = mean(Q,2);

figure; plot(in_m,Q_m);