%% Practical Assignment
% Probabilistic Simulations
% Authors: Eetu Knutars, Eetu Peltola

clearvars
close all
clc

% 

% Initializing the simulation values
Nsim = 10^4;
shop_need = 10000;
batch_size = 100;
c1_lb = [48, 72];   % 1. constractor's lower boundaries
c1_ub = [72, 120];  % 1. constractor's upper boundaries
c2_lb = [60, 80];   % 2. constractor's lower boundaries
c2_ub = [80, 130];  % 2. constractor's upper boundaries

splits = (0.4:0.01:0.6);
plot_means = zeros(1, length(splits));
n = 1;
% Simulate with splits 40%/60% - 60%/40% with 1% step

% Best split is 52%/48%
best_split_days = zeros(1, Nsim);
best_split = 0.52;
n1 = 1;
for i = splits
    days = zeros(1, Nsim);
    % Split the batches to the constractors
    c1_shop_need = shop_need * i;
    c2_shop_need = shop_need - c1_shop_need;
    % Run the simulation N times
    for j = 1:Nsim
        % Initialize the simulation

        % Check if the 1. constractor is used
        if c1_shop_need ~= 0
            c1_s1_wait_time = randi([c1_lb(1),c1_ub(1)]);
        else
            c1_s1_wait_time = 0;
        end

        c1_s2_wait_time = 0;
        c1_state = [1,0];

        % Check if the 2. constractor is used
        if c2_shop_need ~= 0
            c2_s1_wait_time = randi([c2_lb(1),c2_ub(1)]);
        else
            c2_s1_wait_time = 0;
        end

        c2_s2_wait_time = 0;
        c2_state = [1,0];
        batches_ready_c1 = 0;
        batches_ready_c2 = 0;
        time_taken = 0;

        % Iterate until both constractors have reached the goal
        while (batches_ready_c1 < c1_shop_need) || (batches_ready_c2 < c2_shop_need)
            % Check the 1.constractor
            if batches_ready_c1 < c1_shop_need
                % Check if second line is working
                if c1_state(2) == 1
                    % Check if the second line is ready
                    if c1_s2_wait_time == 0
                        batches_ready_c1 = batches_ready_c1 + batch_size;
                        c1_state(2) = 0;
                    end
                end
                % Check if both of the lines are ready
                if c1_s1_wait_time == 0 && c1_s2_wait_time == 0
                    c1_s1_wait_time = randi([c1_lb(1),c1_ub(1)]);
                    c1_s2_wait_time = randi([c1_lb(2),c1_ub(2)]);
                    c1_state(2) = 1;
                end
            end
            % Check the 2.constractor
            if batches_ready_c2 < c2_shop_need
                % Check if second line is working
                if c2_state(2) == 1
                    % Check if the second line is ready
                    if c2_s2_wait_time == 0
                        batches_ready_c2 = batches_ready_c2 + batch_size;
                        c2_state(2) = 0;
                    end
                end
                % Check if both of the lines are ready
                if c2_s1_wait_time == 0 && c2_s2_wait_time == 0
                    c2_s1_wait_time = randi([c2_lb(1),c2_ub(1)]);
                    c2_s2_wait_time = randi([c2_lb(2),c2_ub(2)]);
                    c2_state(2) = 1;
                end
            end
            % Dummy variable to get the right time step
            ps_time = [c1_s1_wait_time,c1_s2_wait_time,c2_s1_wait_time,c2_s2_wait_time];
            ps_time = ps_time(ps_time ~= 0);
            time_step = min(ps_time);

            % Update the time taken and all the waiting times
            time_taken = time_taken + time_step;
            c1_s1_wait_time = max(0, c1_s1_wait_time - time_step);
            c1_s2_wait_time = max(0, c1_s2_wait_time - time_step);
            c2_s1_wait_time = max(0, c2_s1_wait_time - time_step);
            c2_s2_wait_time = max(0, c2_s2_wait_time - time_step);
        end
        % Calculate the days taken 
        days(j) = (time_taken-time_step) /24;   % (last time step is extra)

        if i == best_split
            best_split_days(n1) = days(j);
            n1 = n1+1;
        end

    end
    mean_days = round(mean(days),2);
    days_95 = round(quantile(days, 0.95),2);
    if i == best_split
        fprintf('<strong>Split %d/%d: average = %.2f, 95%% confidence = %.2f</strong>\n', i*100, (1-i)*100, mean_days, days_95)
    else   
        disp(['Split ' , num2str(i*100) , '/' , num2str((1-i)*100) , ': average = ', num2str(mean_days), ', 95% confidence = ', num2str(days_95)])
    end
    plot_means(n) = mean_days;
    n = n+1;
end


% Make some plots
temp = shop_need*splits/batch_size;
plot(temp, plot_means, '-b')
hold on
a = plot(temp(min(plot_means)==plot_means), min(plot_means), 'r.', 'MarkerSize',20);
plot(temp(min(plot_means)==plot_means), min(plot_means), 'ko-', 'MarkerSize',10, 'LineWidth',1)
xticks(shop_need*splits/batch_size)
xlabel('Number of Batches Assigned to Contractor 1')
ylabel('Average Processing Time (Days)')
title('Impact of Batch Distribution on Processing Time')
legend(a, 'The Best Processing Time')
hold off

histogram(best_split_days)
xlabel('Processing Time (Days)')
ylabel('Frequency')
title('Distribution of Processing Times for the Best Batch Split (52% / 48%)')