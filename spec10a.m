%%
cd('/Users/emory/Documents/GitHub/DS_ResearchProject_ND')
close all
%% Point Specs on Hex lattices
% Measurement with 10a spacing.
load 'Spec10a.mat'
h0=ksmooth(mean(didv0,2),1);
h10b=ksmooth(mean(didvb10,2),1); h10t=ksmooth(mean(didvt10,2),1);
h10br=h10b./h0; h10tr=h10t./h0;
%figure; plot(v,[h10br h10tr]);

% sim the hexagonal lattice specs
disp = [0.439, 0.4068, -10.996];
a = 2.5744; nhex = 5; vsim = linspace(-0.4, 0.5, 451)'; 
sf =10; vp = khex(nhex, sf*a,1); vspec=[0,sf*a/sqrt(3); sf*a/2,0]; 
simh10=zeros(size(vsim,1),size(vspec,1));

deltaR = -.09230312; 
deltaI = 0.18916686; 
for ni=1:size(vspec,1)
    simh10(:,ni) = kspec(vp, vspec(ni,:), vsim,(deltaR+deltaI*sqrt(-1)),disp); 
end

figure; plot(v,h10tr,vsim*1000,simh10(:,1));
figure; plot(v,h10br,vsim*1000,simh10(:,2));

%% Evaluating Plots 
% making data sets same size 
h10tr = h10tr(101:end); 
j = 1; 
h10tr_new = zeros(451,1);
for i = 1:2:901
    h10tr_new(j) = h10tr(i); 
    j = j + 1; 
end
h10tr_new = h10tr_new'; 


h10br_new = zeros(451,1);
h10br = h10br(101:end); 
j = 1; 
for i = 1:2:901
    h10br_new(j) = h10br(i); 
    j = j + 1; 
end
h10br_new = h10br_new'; 

simh10tr = simh10(:,1);
simh10br = simh10(:,2); 

% Finding stats
[RMSE, Rsquared, Residuals, Av_residual] = eStats(h10tr_new, simh10tr); 
fprintf('(tr) For deltaI: %fi , deltaR: %f, \n RMSE score: %f,R Squared Score: %f, average residual: %f \n', deltaI, deltaR, RMSE, Rsquared, Av_residual);  
[RMSE2, Rsquared2, Residuals2, Av_residual2] = eStats(h10br_new, simh10br); 
fprintf('(br) For deltaI: %fi , deltaR: %f, \n RMSE score: %f, R Squared Score: %f, average residual: %f \n', deltaI, deltaR, RMSE2, Rsquared2, Av_residual2);  