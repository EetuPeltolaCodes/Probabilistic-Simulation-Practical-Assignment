%% Task 1
clearvars
close all
clc

% Initializing the simulation values
Nsim = 10^4;
shop_need = 10000;
batch_size = 100;
c1_lb = [48, 72];   % 1. constractor's lower boundaries
c1_ub = [72, 120];  % 1. constractor's upper boundaries
c2_lb = [60, 80];   % 2. constractor's lower boundaries
c2_ub = [80, 130];  % 2. constractor's upper boundaries

% Simulate with splits 40%/60% - 60%/40% with 1% step
for i = 0.4:0.01:0.6
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
    end
    disp(['Simulating with split ' , num2str(c1_shop_need) , ' for first contractor ' , num2str(c2_shop_need) , ' for second contractor '])
    mean_days = mean(days)
    days_95 = quantile(days, 0.95)
end

%% 
clearvars
close all
clc


% Initialize
Nsim = 10^5;
lb = [48, 72];
ub = [72, 120];
batch_size = 100;
device_need = 1000;
days = zeros(1,Nsim);

for i = 1:Nsim
    % Initialize the simulation
    spoint_1 = randi([lb(1), ub(1)]);   % Service line 1 time
    spoint_2 = 0;   % Service line 2 time
    batches_ready = 0;
    time_taken = 0;
    states = [1,0];
    while batches_ready < device_need   % Simulate until the device need is fullfilled
        time_taken = time_taken + 1;
        spoint_1 = max(0, spoint_1 - 1); % Decrement Service Point 1 time
        if states(2) == 1   % When the line 2 does something
            spoint_2 = max(0, spoint_2 - 1); % Decrement Service Point 2 time
            if spoint_2 == 0
                batches_ready = batches_ready + batch_size; % Add batch to ready count when Service Point 2 is done
                states(2) = 0;   % Change the state
            end
        end
        if spoint_1 == 0 && spoint_2 == 0 % If Service Point 1 is ready
            spoint_1 = randi([lb(1), ub(1)]); % Sample Service Point 1 time
            spoint_2 = randi([lb(2), ub(2)]); % Sample Service Point 2 time
            states(2) = 1;  % Change the state
        end
    end
    days(i) = (time_taken-1) / 24;  % Calculate days it took to fullfill the order (last hour is extra)
end

mean_days = mean(days)  % Calculate the mean
days_95 = quantile(days, 0.95)   % Calculate the 95%-quantile
