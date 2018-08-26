%% Graphene Spec Data for Predicting Scale Factor 
% Emory Smith 

%% Generating specs for a range of deltas, and scale factors

training_size = 12000;
training1 = cell(training_size,3);

rng('default'); 
vars = rand([3,1,training_size]);
%delta I should be from 0 to 1
%delta R should be between -pi/2 to 0
vars(2,1,:) = (vars(2,1,:)-1)*pi/2;

%scale_factor should be between 0.9 and 1.1
vars(3,1,:) = vars(3,1,:)./5+0.9;

nv = 451;
bias_sim = linspace(-0.4, 0.5, nv);
dispersion1 = [0.439, 0.3633, -13.7882];

%vspec = [0,0];
abc = kconstants;
a0 = abc.a;

trainingA = zeros(training_size, (3+nv*2));
nhex = 5;
for i = 1:training_size
    
    
    deltaI = vars(1,1,i);
    deltaR = vars(2,1,i);
    
    delta = deltaR+sqrt(-1)*deltaI;
    
    sf = vars(3,1,i);
    
    vpCO_temp = khex(nhex, sf*a0,1); % position of COs
    vspec = [0,sf*a0/sqrt(3); sf*a0/2,0]; % position of measurements (top and bond sides)
    
    training1{i,1} = [deltaI, deltaR, sf];
    training1{i,2} = kspec(vpCO_temp, vspec(1,:), bias_sim, delta, dispersion1);
    training1{i,3} = kspec(vpCO_temp, vspec(2,:), bias_sim, delta, dispersion1);


    trainingA(i,:) = [deltaI deltaR sf training1{i,2}' training1{i,3}'];

    i

end
    


%% Saving the training data

save('/Users/emory/Documents/GitHub/DS_ResearchProject_ND/Training_Data/Graphene/GrapheneTrainingData180722_sf.mat', 'trainingA');
csvwrite('/Users/emory/Documents/GitHub/DS_ResearchProject_ND/Training_Data/Graphene/GrapheneTrainingData180722_sf.csv', trainingA);
csvwrite('/Users/emory/Documents/GitHub/DS_ResearchProject_ND/GrapheneTrainingData180722_bias.csv', bias_sim);


%% Generate a second set of simulated training data with the predicted scale factor from the first set

training_size = 2500;
training1 = cell(training_size,2);

rng('default'); 
vars = rand([2,1,training_size]);
%delta I should be from 0 to 1
%delta R should be between -pi/2 to 0
vars(2,1,:) = (vars(2,1,:)-1)*pi/2;

% %scale_factor should be between 0.9 and 1.1
% vars(3,1,:) = vars(3,1,:)./5+0.9;

sf = 0.964;

%x_sim = linspace(0,140,nspec);
%k_sim = kv2k(E,dispersion1);

% nv = 201;
% bias3 = linspace(-0.4, 0.5, nv);
% bias4 = linspace(-0.25, 0.25, nv);
nv = 451;
bias_sim = linspace(-0.4, 0.5, nv);
dispersion1 = [0.439, 0.4068, -10.996];

vspec = [0,0];
abc = kconstants;
a0 = abc.a;

trainingA = zeros(training_size, (2+nv));

for i = 1:training_size
    
    
    deltaI = vars(1,1,i);
    deltaR = vars(2,1,i);
    
    delta = deltaR+sqrt(-1)*deltaI;
    
    %scale_factor = vars(3,1,i);
    
    vpCO_temp = hexagon_v2(sf*a0);
    
    training1{i,1} = [deltaI, deltaR];
    training1{i,2} = kspec(vpCO_temp, vspec, bias_sim, delta, dispersion1);

    trainingA(i,:) = [deltaI deltaR training1{i,2}'];

    i

end


csvwrite('/Users/lauracollins/Desktop/DS_ResearchProject_ND/HexagonTrainingData060618_v5.csv', trainingA);


%% Comparing Simulation with Predicted Phase to Experimental 

% making different versions of vpCO
vpCO = hexagon_v2(a0);
new_a = 2.42;
vpCO_v2 = hexagon_v2(new_a);
vpCO_v3 = hexagon_v2(2.3);

scale_factor = 0.8993;
vpCO_v4 = hexagon_v2(scale_factor*a0);
dispersion1 = [0.439, 0.4068, -10.996];

% making different phases 
predPhase1 = -0.105 + sqrt(-1)*0.175;
predPhase2 = -0.03 + sqrt(-1)*0.175; 
predPhase3 = -0.15 + sqrt(-1)*0.05;

% making different specs 
sim_pred_spec1 = kspec(vpCO, vspec, bias3, predPhase1,dispersion1);
sim_pred_spec2 = kspec(vpCO, vspec, bias3, predPhase2, dispersion1);
sim_pred_spec3 = kspec(vpCO, vspec, bias3, predPhase3, dispersion1);
%sim_pred_spec_exp = kspec(vpCO, vspec, bias_exp3, predPhase3, dispersion1);


sim_pred_spec1_v2 = kspec(vpCO_v2, vspec, bias3, predPhase1, dispersion1);
sim_pred_spec2_v2 = kspec(vpCO_v2, vspec, bias3, predPhase2, dispersion1);
sim_pred_spec3_v2 = kspec(vpCO_v2, vspec, bias3, predPhase3, dispersion1);
%sim_pred_spec_exp_v2 = kspec(vpCO_v2, vspec, bias_exp3, predPhase3, dispersion1); 

sim_pred_spec1_v3 = kspec(vpCO_v3, vspec, bias3, predPhase1, dispersion1);
sim_pred_spec2_v3 = kspec(vpCO_v3, vspec, bias3, predPhase2, dispersion1);
sim_pred_spec3_v3 = kspec(vpCO_v3, vspec, bias3, predPhase3, dispersion1);
%sim_pred_spec_exp_v3 = kspec(vpCO_v3, vspec, bias_exp3, predPhase3, dispersion1); 

sim_pred_spec1_v4 = kspec(vpCO_v4, vspec, bias3, predPhase1, dispersion1);
sim_pred_spec2_v4 = kspec(vpCO_v4, vspec, bias3, predPhase2, dispersion1);
sim_pred_spec3_v4 = kspec(vpCO_v4, vspec, bias3, predPhase3, dispersion1);
%sim_pred_spec_exp_v4 = kspec(vpCO_v4, vspec, bias3_exp3, predPhase3, dispersion1);

% plotting 
figure; 
plot(bias3, expSpec3, 'b','LineWidth', 2); %  experimental 
hold on
plot(bias3, sim_pred_spec1, '.m', 'LineWidth', 2); % phase 1 
hold on 
plot(bias3, sim_pred_spec2,'r', 'LineWidth', 2); % phase 2 
hold on 
plot(bias3, sim_pred_spec3, 'k', 'LineWidth', 2); % phase 3
legend('Experimental', 'phase 1', 'phase 2', 'phase 3')
title('vpCO')


figure;
plot(bias3, expSpec3, 'b','LineWidth', 2); %  experimental 
hold on
plot(bias3, sim_pred_spec1_v2, '.m', 'LineWidth', 2); % phase 1 
hold on 
plot(bias3, sim_pred_spec2_v2,'r', 'LineWidth', 2); % phase 2 
hold on 
plot(bias3, sim_pred_spec3_v2, 'k', 'LineWidth', 2); % phase 3
legend('Experimental', 'phase 1', 'phase 2', 'phase 3')
title('vpCO_v2')

figure;
plot(bias3, expSpec3, 'b','LineWidth', 2); %  experimental 
hold on
plot(bias3, sim_pred_spec1_v3, '.m', 'LineWidth', 2); % phase 1 
hold on 
plot(bias3, sim_pred_spec2_v3,'r', 'LineWidth', 2); % phase 2 
hold on 
plot(bias3, sim_pred_spec3_v3, 'k', 'LineWidth', 2); % phase 3
legend('Experimental', 'phase 1', 'phase 2', 'phase 3')
title('vpCO_v3')

figure;
plot(bias3, expSpec3, 'b','LineWidth', 2); %  experimental 
hold on
plot(bias3, sim_pred_spec1_v4, '.m', 'LineWidth', 2); % phase 1 
hold on 
plot(bias3, sim_pred_spec2_v4,'r', 'LineWidth', 2); % phase 2 
hold on 
plot(bias3, sim_pred_spec3_v4, 'k', 'LineWidth', 2); % phase 3
legend('Experimental', 'phase 1', 'phase 2', 'phase 3')
title('vpCO_v3')

% figure; 
% subplot(1, 4, 1) 
% plot(bias3, expSpec3, 'b','LineWidth', 2); %  experimental 
% hold on
% plot(bias3, sim_pred_spec_exp, 'r', 'LineWidth', 2);  
% hold on 
% plot(bias3, sim_pred_spec_exp_v2, 'k', 'LineWidth', 2);  
% hold on 
% plot(bias3, sim_pred_spec_exp_v3, 'y', 'LineWidth', 2);  
% hold on 
% plot(bias3, sim_pred_spec_exp_v4, 'g', 'LineWidth', 2);  
% legend('Experimental', 'vpCO', 'vpCO_v2','vpCO_v3', 'vpCO_v4')
% title('phase 3')
% 




%diff1 = sum((expSpec3 - sim_pred_spec2').^2)
%diff2 = sum((expSpec3 - sim_pred_spec1').^2)
%diff3 = sum((expSpec4 - sim_pred_spec_exp').^2)








