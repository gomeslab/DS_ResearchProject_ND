%% Point Specs on graphene lattices
% Measurement with 10a spacing.
load 'Spec10a.mat'
h0=ksmooth(mean(didv0,2),1);
h10b=ksmooth(mean(didvb10,2),1); h10t=ksmooth(mean(didvt10,2),1);
h10br=h10b./h0; h10tr=h10t./h0;
figure; plot(v,[h10br h10tr]);

y = interp1(v,h10tr,bias_sim*1000);
csvwrite('J_graph_y.csv', y);

%% Optimizing phase and scale factor.

a = 10*2.5477; nhex = 5; vsim = linspace(-0.4, 0.5, 451)'; 
vp = khex(nhex, a,1); vspec=[0, a/sqrt(3)];%; sf*a/2,0]; 

% Defining the cost functions
yt = interp1(v,h10tr,vsim*1000);

lb1 = [-pi/2,0];
ub1 = [0,1];

delta0 = [-0.5,0.5];
disp0 = [-0.45,0.35,0];
nint = 20;
delta = zeros (nint+1,2);
sf = zeros (nint+1,1);
delta(1,:) = [-.5,.5];
sf(1) = 1;

% Optimizing delta and sf at same time with grad descent
% cost = @(params)norm(yt-kspec(vp, vspec, vsim,params(1)+sqrt(-1)*params(2),[0.439, 0.4068*params(3)^2, -10.996/params(3)^4]));
% [best_params, history]= kminimizer2(cost,[-.5,.5,1]);

% Alternating optmization of delta and sf: 
% tic
% for ni = 1:nint
%     cost1 = @(delta)norm(yt-kspec(vp, vspec, vsim,delta(1)+sqrt(-1)*delta(2),[0.439, 0.4068*sf(ni)^2, -10.996/sf(ni)^4]));
%     delta(ni+1,:) = fmincon(cost1,delta(ni,:),[],[],[],[],lb1,ub1);
%     cost2 = @(sf)norm(yt-kspec(vp, vspec, vsim,delta(ni+1,1)+sqrt(-1)*delta(ni+1,2),[0.439, 0.4068*sf^2, -10.996/sf^4]));
%     sf(ni+1) = kminimizer(cost2,sf(ni));
% end
% toc
tic
% Optimizing all parameters at same time with grad descent
cost = @(params)norm(yt-kspec(vp, vspec, vsim,params(1)+sqrt(-1)*params(2),[params(3:4),params(5)*100]));
[best_params, history]= kminimizer2(cost,[-.5,.5,.45,.35,-0.1]);

toc


%%
simh = kspec(vp, vspec, vsim,best_params(1)+sqrt(-1)*best_params(2),[best_params(3:4),100*best_params(5)]);

figure; plot(v,h10tr,vsim*1000,simh(:,1));
%figure; plot(v,h10br,vsim*1000,simh(:,2));


%% Hexagon Spec Data
% This file produces simulated data to train ML models that predict the
% phase parameter. 

%% Loading and Plotting Data

% Load the data from 2 specs to average
Spec_data1 = kdat('BiasSpec001.dat');
Spec_data2 = kdat('BiasSpec003.dat');

%Average forward and backward
spec1 = 0.5*(Spec_data1.Data(:,3)+Spec_data1.Data(:,5)); 
spec2 = 0.5*(Spec_data2.Data(:,3)+Spec_data2.Data(:,5));
expSpec = 0.5*(spec1 + spec2);


%Loading the bare Cu spec
nv = 501;
Cu_data = k3ds('GridSpec001.3ds');
Cu_allspecs=reshape(Cu_data.LIX,[100,nv]);
dataCu=mean(Cu_allspecs)';

%Normalize by bare Cu
expSpec = expSpec./dataCu;

expVoltage = Spec_data1.Data(:,1);

%First need spec points above E = -0.4 only
bias_limit = -0.4;
limVoltage = expVoltage(expVoltage>= bias_limit);
limExpSpec = expSpec(expVoltage>= bias_limit);

%Checking that the original and downsampled specs look the same
figure; 
plot(limVoltage, limExpSpec);
title('Experimental Point Spec taken on Hex Corral')

% csvwrite('/Users/lauracollins/Desktop/DS_ResearchProject_ND/HexagonExperimentalData053118_v2.csv', expSpec4);
% csvwrite('/Users/lauracollins/Desktop/DS_ResearchProject_ND/HexagonExperimentalData053118_specPoints.csv', expSpec3);

% Simulation parameters
constants = kconstants;
a0 = constants.a;  % Cu lattice spacing
vpCO = hexagon_v2(a0);
delta = -0.125 + 0.060*1i;
sf = 0.948;
dispersion = [0.439, 0.4068*(sf^2), -10.996/(sf^4)];
 
% Running the Simulation 
PredictSpec = kspec(vpCO, [0,0], limVoltage, delta, dispersion); 

% Plotting Simulation vs Experiment
figure; 
plot(limVoltage, [PredictSpec, limExpSpec]);
axis square
legend('Prediction', 'Experiment')


%% Optimizing phase and scale factor.

a = 10*2.5477; vsim = linspace(-0.3, 0.5, 401)'; 
vspec=[0,0];%; sf*a/2,0]; 

% Defining the cost functions
yt = interp1(limVoltage,limExpSpec,vsim);

lb1 = [-pi/2,0];
ub1 = [0,1];

delta0 = [-0.5,0.5];
disp0 = [-0.45,0.35,0];
nint = 20;
delta = zeros (nint+1,2);
sf = zeros (nint+1,1);
delta(1,:) = [-.5,.5];
sf(1) = 1;

% Optimizing delta and sf at same time with grad descent
% cost = @(params)norm(yt-kspec(vp, vspec, vsim,params(1)+sqrt(-1)*params(2),[0.439, 0.4068*params(3)^2, -10.996/params(3)^4]));
% [best_params, history]= kminimizer2(cost,[-.5,.5,1]);

% Alternating optmization of delta and sf: 
% tic
% for ni = 1:nint
%     cost1 = @(delta)norm(yt-kspec(vp, vspec, vsim,delta(1)+sqrt(-1)*delta(2),[0.439, 0.4068*sf(ni)^2, -10.996/sf(ni)^4]));
%     delta(ni+1,:) = fmincon(cost1,delta(ni,:),[],[],[],[],lb1,ub1);
%     cost2 = @(sf)norm(yt-kspec(vp, vspec, vsim,delta(ni+1,1)+sqrt(-1)*delta(ni+1,2),[0.439, 0.4068*sf^2, -10.996/sf^4]));
%     sf(ni+1) = kminimizer(cost2,sf(ni));
% end
% toc
tic
% Optimizing all parameters at same time with grad descent
cost = @(params)norm(yt-kspec(vpCO, vspec, vsim,params(1)+sqrt(-1)*params(2),dispersion));
[best_params, history]= kminimizer2(cost,[-.5,.5]);

toc

%%
function [xmin, history] = kminimizer(fun, xmin)

num_iters = 15;
alpha = 0.001;
history = zeros(num_iters+1, 1);
delta = 0.005;
%history(1)=fun(xmin);
for iter = 1:num_iters
    grad = (fun(xmin+delta)-fun(xmin-delta))/2/delta;
    xmin=xmin - alpha*grad;
%    history(iter+1)=fun(xmin);
end

end

%%
function [xmin, history] = kminimizer2(fun, xmin)

num_iters = 400;
alpha = 0.0001;
history = zeros(num_iters+1, 1);
delta = 0.001;
nx = length(xmin);
grad = zeros(1,nx);
history(1)=fun(xmin);

for iter = 1:num_iters
    for ix = 1:nx
        xp = xmin;
        xm = xmin;
        xp(ix)=xp(ix)+delta;
        xm(ix)=xm(ix)-delta;
        grad(ix)=(fun(xp)-fun(xm))/2/delta;
    end
    xmin = xmin - alpha*grad;
    history(iter+1)=fun(xmin);
end

end
