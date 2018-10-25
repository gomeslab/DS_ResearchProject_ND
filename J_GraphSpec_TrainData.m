%% Creating large set of training data from simulated data
tic
% Simulation parameters
training_size = 10000;

% Dispersion
sf = 0.948;
dispersion = [0.439, 0.4068*(sf^2), -10.996/(sf^4)];

% Bias Voltage
nv = 451;
bias_sim = linspace(-0.4, 0.5, nv);

% CO geometry
a = 10*2.5477;
nhex = 5;
vp = khex(nhex, a,1);

% Spec position
vspec = [0, a/sqrt(3)];

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
    trainingSpec = kspec(vp, vspec, bias_sim, trainingdelta, dispersion);
    trainingData(i,:) = [DeltaValues(i,:),trainingSpec'];    
    waitbar(i/training_size, f)
end
close(f)
toc

%% Writing the data to CSV file
csvwrite('Training_Data/Graphene/J_GraphTrainData_1.csv', trainingData);
csvwrite('Training_Data/Graphene/J_GraphBias_1.csv', bias_sim);


%% error of value from Graph_RF

delta_rf = [-0.1107769 , 0.1072339];
delta = delta_rf(1,1) + delta_rf(1,2)*1i;
PredictSpec = kspec(vp, vspec, bias_sim, delta, dispersion);
figure; plot(bias_sim, [PredictSpec, y']);

error = sum((PredictSpec - y').^2);