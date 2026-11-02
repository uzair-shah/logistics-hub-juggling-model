%Making this code state independent
TransitionMatrix_J_3_3_1Bay = [ 0.25	0.25	0.25	0.25	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0.25	0.25	0.25	0.25	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0.25	0	0	0	0.25	0.25	0.25	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0.25	0	0	0	0.25	0.25	0.25	0	0	0	0	0	0	0	0	0	0	0
0.25	0	0	0	0.25	0	0	0.25	0	0.25	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0.25	0.25	0.25	0.25	0	0	0	0	0	0	0
0	0	0	0	0.25	0	0	0	0	0	0	0	0.25	0.25	0.25	0	0	0	0	0
0	0	0.25	0	0.25	0.25	0.25	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0.25	0	0	0	0	0	0	0	0	0.25	0.25	0.25	0	0	0
0.25	0	0	0	0.25	0	0	0.25	0	0.25	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0.25	0	0	0	0	0	0	0	0.25	0.25	0.25
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0
0	0	0	0	0.25	0	0	0	0	0	0.25	0	0	0.25	0	0	0	0	0.25	0
0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0.25	0	0	0	0	0.25	0.25	0.25	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0.25	0	0	0	0	0	0	0	0.25	0.25	0.25
0	0	0	0	0	0	0	0	0	0.25	0	0	0	0	0	0	0	0.25	0.25	0.25
0	0	0	0	0.25	0	0	0	0	0	0.25	0	0	0.25	0	0	0	0	0.25	0];
X = TransitionMatrix_J_3_3_1Bay;
X_name = " J(<=3,3,1)";


% Creating theoretical stationary vector corresponding to eigen value 1
[eig_vecs,eig_vals] = eig(X'); 
stationary_vec = (eig_vecs(:,1)/sum(eig_vecs(:,1)))'; %Theoretical stationary state

% Initializing Variables
num_states = 20; %Total number of states
seeds = 30;
n = 10^5; %no. of iterations

%Cost and revenue
base_revenue = 15;
fixed_cost = 5;
delay_cost = 5;
bay_cost = 5;

total_cost = 0;
total_revenue = 0;

diff_mat = zeros(num_states,n,seeds); %difference vector to calc norm diff btw sim-vec and st-vec
sim_st_vec_matrix = zeros(num_states,num_states,seeds); %Storing vectors from different starting states and seeds

pos_1_car_processed = [1,5,8,11,14,16];
pos_2_car_processed = [10,19,20];
pos_3_car_processed = [18];




tic %Calculating the time it takes to run the loop
for seed = 1:seeds
    rng(1947793+seed);
    
    for k = 1:num_states
        s_vec = zeros(1,num_states); %State Vector for simulation
        
        pos = k; %starting state position
        
        
        
        for i = 1:n % Loop over n times
            pos_indxs = find(X(pos,:)); %Index position of non-zero probs
            probs = X(pos, pos_indxs);
            x = rand; %Random number between 0 and 1
            
            cum_probs = cumsum(probs,2);
        
            for j = 1:length(cum_probs)
                if x <= cum_probs(j) %if the rand value is less than the value in cumulative probabilities
                    pos = pos_indxs(j); %value of associated pos_indexes index is an index in original vector
                    s_vec(pos) = s_vec(pos) + 1; %increase value of original vector
                    if any(pos == pos_1_car_processed) %positions 17 and onwards are cases where there are more than 2 trucks arriving at the hub
                        total_cost = total_cost + bay_cost*1 + delay_cost*0 + fixed_cost;
                        total_revenue = total_revenue + base_revenue*1;
                    elseif any(pos == pos_2_car_processed)
                        total_cost = total_cost + bay_cost*1 + delay_cost*1 + fixed_cost; %2 cars arrive, one gets processed other doesnt
                        total_revenue = total_revenue + base_revenue*1;
                    elseif any(pos == pos_3_car_processed)
                        total_cost = total_cost + bay_cost*1 + delay_cost*2 + fixed_cost;
                        total_revenue = total_revenue + base_revenue*1;
                    else
                        total_cost = total_cost + fixed_cost;
                    end
           
                    break;
                end
            end
            sim_st_vec = s_vec/sum(s_vec);
            diff_mat(k,i,seed) = (norm(sim_st_vec - stationary_vec))^2;
        end
        sim_st_vec_matrix(k,:,seed) = sim_st_vec;
    end
end
disp('%%%%%%%%%%%%%%%')
disp(['Juggling system: ' X_name])
elapsedTime = toc;
disp(['The loop took ' num2str(elapsedTime) ' seconds.']);
avg_cost = (total_cost/num_states)/seeds;
avg_revenue = (total_revenue / num_states) / seeds; % 
disp(['It cost ' num2str(avg_cost)])
disp(['Revenue generated ', num2str(avg_revenue)])

mean_sim_st_vec = mean(sim_st_vec_matrix,[1,3]); %gives a 1x20 sized vector which has been averaged across all rows and all seeds to give final dist vector
mean_diff_vec = mean(diff_mat,[1,3]); %averages difference across all states and seeds
rssq = (norm(stationary_vec - mean_sim_st_vec))^2; %residual sum of squares
disp(['RSSQ is calculated out to be ' num2str(rssq)])
disp('%%%%%%%%%%%%%%%')

% Difference between the theoretical stationary distribution 
% and the simulated stationary distribution for comparison
disp('The theroetical stationary vector is as follows')
disp(stationary_vec)
disp('The simulated stationary vector is as follows')
disp(mean_sim_st_vec)



% Plot the residual sum of squares over iterations
figure('Name','Convergence');
t = 1:n;
% loglog(t,mean_diff_vec)
plot(t,mean_diff_vec);
ylim([0,0.001])
% yline(10^-7,'-','Threshold');
xlabel('Iterations');
ylabel('Residual Sum of Squares');
title('Convergence of Simulated Stationary Distribution of' + X_name);
grid on;

% Plot the residual sum of squares over iterations - Log Graph
figure('Name','Convergence_Log');
t = 1:n;
loglog(t,mean_diff_vec)
% plot(t,diff_vec);
% ylim([0,0.01])
% yline(10^-7,'-','Threshold');
xlabel('Iterations (Log Scale)');
ylabel('Residual Sum of Squares (Log Scale)');
title('Convergence of Simulated Stationary Distribution of' + X_name);
grid on;

% Plot simulated vs theoretical stationary distribution on the same graph
figure('Name','SimVsStState');
states =["100"	"000"	"010"	"001"	"110"	"020"	"011"	"101"	"002"	"200"	"120"	"030"	"021"	"111"	"012"	"102"	"003"	"300"	"210"	"201"];



combined = [mean_sim_st_vec(:), stationary_vec(:)];   % 6 x 2 matrix | Combine both vectors as columns so bar() draws grouped bars

b = bar(states, combined);
b(1).FaceColor = [0.20 0.45 0.75];   % simulated  (blue)
b(2).FaceColor = [0.85 0.40 0.20];   % theoretical (orange)

xlabel("States");
ylabel("Probabilities");
title("Simulated vs Theoretical Stationary State Distribution of" + X_name);
legend("Simulated","Theoretical","Location","best");
grid on;