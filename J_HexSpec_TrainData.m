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

%% Checking the geometry
% First peaks are a bit small, and there may be additional peaks in the
% experiment according to Ken

% Loading some parameters 
constants = kconstants;
a0 = constants.a;  % Cu lattice spacing

% Building the CO posistion vector
hex_predicted = hexagon_v2(a0);

% Load the points from hexagon.ngef -- were parsed using python notebook 
hex_exp = csvread('Training_Data/Hexagon/NewHexagonNGEFPoints.csv', 1,1);

%This is in nm, convert to Angstroms
hex_exp = hex_exp*10;

% scan angle from topograph is 128, rotating for better comparison. 
theta = -15*pi/180; 

% Angle Found by using an arctan function on the change in y, x, between two 
% points

R = [cos(theta), sin(theta); -sin(theta), cos(theta)];
hex_exp = hex_exp*R;

% Checking that we use the same size hexagon as we built
topofile = ksxm('Topo021.sxm');
x = linspace(-90,90,256);
figure;
imagesc(x,x,ltstrip(topofile.Zf),[-2,2]*10^-11); kcm('gold')
axis image 
line(hex_predicted(:,1), hex_predicted(:,2),'marker','x','color','g','markersize',10,'linestyle','none');
line(hex_exp(:,1), hex_exp(:,2),'marker','o','color','b','markersize',10,'linestyle','none');


%% Comparing Data to Simulation

% Simulation parameters
constants = kconstants;
a0 = constants.a;  % Cu lattice spacing

vpCO = hexagon_v2(a0);
%delta = -0.125 + 0.060*1i;
delta = -0.13054543+0.08995103*1i;
sf = 0.948;
dispersion = [0.439, 0.4068*(sf^2), -10.996/(sf^4)];
 
% Running the Simulation 
PredictSpec = kspec(vpCO, [0,0], limVoltage, delta, dispersion); 

% Plotting Simulation vs Experiment
figure; 
plot(limVoltage, [PredictSpec, limExpSpec]);
axis square
legend('Prediction', 'Experiment')

%% Creating large set of training data from simulated data
tic
% Simulation parameters
training_size = 10000;

% Dispersion
sf = 0.948;
dispersion = [0.439, 0.4068*(sf^2), -10.996/(sf^4)];

% Bias Voltage
nv = 401;
bias_sim = linspace(-0.3, 0.5, nv);

% CO geometry
constants = kconstants;
a0 = constants.a;
vpCO = hexagon_v2(a0);

% Spec position
vspec = [0,0];

% Defining random values for delta
% seed = rng;
seed = 56743;
rng(seed); 
DeltaValues = rand([training_size,2]);
%delta R should be between -pi/2 to 0
%delta I should be from 0 to 1 -- no change needed
DeltaValues(:,1) = -DeltaValues(:,1)*pi/2;


np = 4;
trainingData = zeros(training_size, (2 + nv));

f = waitbar(0, 'Calculating Simulated Data');
for i = 1:training_size  
    trainingdelta = DeltaValues(i,1)+1i*DeltaValues(i,2);  
    trainingSpec = kspec(vpCO, vspec, bias_sim, trainingdelta, dispersion);
    trainingData(i,:) = [DeltaValues(i,:),trainingSpec'];    
    waitbar(i/training_size, f)
end
close(f)
toc

%% Writing the data to CSV file
%csvwrite('Training_Data/Hexagon/J_HexTrainData_1.csv', trainingData);
csvwrite('Training_Data/Hexagon/J_HexBias_1.csv', bias_sim);


%% Error when changing parameters in Hex_RF
% Changing max_depth

delta_rf = [ -0.13281288 , 0.13383751 ; -0.14122301 , 0.09551758; -0.13382613 , 0.09720693; -0.13054543 , 0.08995103; -0.13054543 , 0.08995103; -0.13054543 , 0.08995103];

max_depth = [5; 10; 15; 20; 40; 70];

ndeltas=length(max_depth);
error = zeros(ndeltas);
for i=1:ndeltas
    delta = delta_rf(i,1) + delta_rf(i,2)*1i;
    PredictSpec = kspec(vpCO, [0,0], limVoltage, delta, dispersion); 
    error(i) = sum((PredictSpec - limExpSpec).^2);
end
plot( max_depth, error);
% the best max_depth is 20 %

%% Changing n_estimators
delta_rf = [-0.096144 , 0.041011; -0.096144 , 0.041011; -0.094166 , 0.06210067; -0.1156495 , 0.0700015; -0.10519 , 0.0706376; -0.114451 ,  0.0866534;-0.11435825 , 0.08401255; -0.1257298 ,  0.08903692; -0.13054543 , 0.08995103; -0.12842967 , 0.09609838; -0.12761736 , 0.09774626; -0.13009329 , 0.10102789];
n_estimators = [1; 2; 3; 4; 5; 10; 20; 25; 30; 40; 50; 100];

ndeltas=length(n_estimators);
error = zeros(ndeltas, 1);
for i=1:ndeltas
    delta = delta_rf(i,1) + delta_rf(i,2)*1i;
    PredictSpec = kspec(vpCO, [0,0], limVoltage, delta, dispersion); 
    error(i) = sum((PredictSpec - limExpSpec).^2);
end
plot(n_estimators, error);
% the best n_estimators is around 10 or 20


%% Changing max_features
delta_rf = [-0.1393253  0.1158945; -0.1331034  0.1005136; -0.1371662 , 0.1181083; -0.1225858 , 0.0937325; -0.161327 , 0.0853384; -0.1301926 , 0.100274; -0.1219579 , 0.0957039; -0.1365582 , 0.08739105; -0.1321002 , 0.1009435; -0.1273228 , 0.0958089; -0.1138194 , 0.0956431; -0.1218518 , 0.0983424];
max_features = [10; 30; 50; 75; 100; 125; 150; 200; 250; 300; 350; 400];

ndeltas=length(max_features);
error = zeros(ndeltas, 1);
for i=1:ndeltas
    delta = delta_rf(i,1) + delta_rf(i,2)*1i;
    PredictSpec = kspec(vpCO, [0,0], limVoltage, delta, dispersion); 
    error(i) = sum((PredictSpec - limExpSpec).^2);
end
plot(max_features, error);
% best max_features is probably to leave at max number

%% Changing max_features
% delta_rf = [-0.15322 , 0.052083];
% max_features = [1];
% 
% ndeltas=length(max_features);
% error = zeros(ndeltas, 1);
% for i=1:ndeltas
%     delta = delta_rf(i,1) + delta_rf(i,2)*1i;
%     PredictSpec = kspec(vpCO, [0,0], limVoltage, delta, dispersion); 
%     error(i) = sum((PredictSpec - limExpSpec).^2);
% end
% figure; plot(limVoltage, [PredictSpec, limExpSpec]);
% 
% 
% delta_rf = [-0.13054543 , 0.08995103];
% delta = delta_rf(i,1) + delta_rf(i,2)*1i;
% PredictSpec = kspec(vpCO, [0,0], limVoltage, delta, dispersion);
% figure; plot(limVoltage, [PredictSpec, limExpSpec]);

%% Ideal Value of delta compared to actual graph

delta_rf = [-0.114451 , 0.0866534];
delta = delta_rf(1,1) + delta_rf(1,2)*1i;
PredictSpec = kspec(vpCO, [0,0], limVoltage, delta, dispersion);
figure; plot(limVoltage, [PredictSpec, limExpSpec]);

error = sum((PredictSpec - limExpSpec).^2);

%%

delta_rf = [-0.1358 , 0.1014];
delta = delta_rf(1,1) + delta_rf(1,2)*1i;
PredictSpec = kspec(vpCO, [0,0], limVoltage, delta, dispersion);
figure; plot(limVoltage, [PredictSpec, limExpSpec]);

error = sum((PredictSpec - limExpSpec).^2);
