%% Creating a model to predict deltaI and deltaR 

% Defining parameters for simulation
dsf = 0.9122372353064065; % dispersion scale factor 
dispersion = [0.439, 0.4068 *dsf ^2, -10.996 / dsf ^4]; % coefficients for: E = E0 + ak^2 + bk^2
abc = kconstants; % physical parameters of copper
a0 = abc.a; % space between CO atoms
nhex = 5; % radius of hex, number of COs from center diagonally
nspec = 451;
E = linspace(-0.4, 0.5, nspec); % energies
sf =10; % scale factor, spacing between each Copper (sf*a0) 

% Defining the geometry of artificial graphene lattice
vp = khex(nhex, sf*a0,1); % position of COs
vspec = [0,sf*a0/sqrt(3); sf*a0/2,0]; % position of measurements (top and bond sides)

% Creating Training
training_size = 2500;
training = zeros(training_size, nspec*2 + 2 ); % initialize matrix

rng('default'); % seed of randomness
delta = rand([training_size,2]);
% delta I should be from 0 to 1
% delta R should be between -pi/2 to 0
delta(:,1) = (delta(:,1)-1)*pi/2; % transfering numbers to correct range for delta R

% Inserting delta values in first two columns of training data
training(:,1:2)=delta;
f = waitbar(0,'Simulating Data');
for i = 1:training_size
    
    d = delta(i,1)+sqrt(-1)*delta(i,2);
    training(i,3:end) = reshape(kspec(vp, vspec, E, d, dispersion),1,2*nspec);  
     waitbar(i/training_size, f)
end

close(f)
%% Saving the training data
save('/Users/emory/Documents/GitHub/DS_ResearchProject_ND/Training_Data/Graphene/ES_AG_Spec_data_180806_sf_0.91.mat', 'training');
csvwrite('/Users/emory/Documents/GitHub/DS_ResearchProject_ND/Training_Data/Graphene/ES_AG_Spec_data_180806_sf_0.91.csv', training);
%% Point Specs
% Measurement with 10a spacing. % save for predicting data
load 'Spec10a.mat'
h0=ksmooth(mean(didv0,2),5);
h10b=ksmooth(mean(didvb10,2),5); h10t=ksmooth(mean(didvt10,2),5);
h10br=h10b./h0; h10tr=h10t./h0;
figure; plot(v,[h10br h10tr]);


dsf = 0.8993; % dispersion scale factor
a = 2.5477; nhex = 5; E = linspace(-0.4, 0.5, 451)'; 
sf =10*dsf; vp = khex(nhex, sf*a,1); vspec=[0,sf*a/sqrt(3); sf*a/2,0]; 
simh10=zeros(size(E,1),size(vspec,1));
deltaR = -0.08659537367345266
deltaI = 0.1629937674981297 
for ni=1:size(vspec,1)
    simh10(:,ni) = kspec(vp, vspec(ni,:), E,(deltaR+deltaI*sqrt(-1)));
end

%% Create Data for Experimental Predicting 
topSide_pnts = interp1(v/1000, h10tr, E); 
bondSide_pnts = interp1(v/1000, h10br, E); 
all_cols = [topSide_pnts', bondSide_pnts'];
disp('done creating experimental');
%% Saving the experimental data
save('/Users/emory/Documents/GitHub/DS_ResearchProject_ND/Training_Data/Graphene/ES_AG_Exp_data__180729_sf_0.8993.mat', 'all_cols');
csvwrite('/Users/emory/Documents/GitHub/DS_ResearchProject_ND/Training_Data/Graphene/ES_AG_Exp_data_180729_sf_0.8993.csv', all_cols);

%% Plotting 
figure; 
plot(v,h10tr);
hold on 
plot (E*1000,simh10(:,1));
legend('experimental', 'simulated');
figure; plot(v,h10br); 
hold on 
plot(E*1000,simh10(:,2));
legend('experimental', 'simulated');
