%% Practical Assignment
% Probabilistic Simulations
% Authors: Eetu Knutars, Eetu Peltola
%% 
clc; close all; clearvars

demand = 10000;
batch_size = 100;
batches = demand/batch_size;
lb = [48, 60, 72, 80];
ub = [72, 80, 120, 130];

% Greedy simulation: assign each batch to the contractor that is
% free earliest. This way we get an estimate of the optimal batch
% split between contractors.

Nsim = 1e4; 
days = zeros(Nsim, 1);
batch_split = zeros(Nsim,2);
for sim = 1:Nsim

    % Simulate machine operating times
    times = zeros(batches, 4);
    for i = 1:4
    times(:,i) = randi([lb(i),ub(i)], batches, 1);
    end
    
    serv_free = [0,0,0,0]; serv_batches = [0,0];
    for i = 1:batches

        % Find worker whose machine 1 is free earliest
        serv_index = find(serv_free == min(serv_free(1:2)), 1);
        serv_batches(serv_index) = serv_batches(serv_index) + 1;

        % Update machine 1 free time
        serv_free(serv_index) = serv_free(serv_index) + times(i,serv_index);

        % Update machine 2 free time
        if serv_free(serv_index) > serv_free(serv_index+2)
            serv_free(serv_index+2) = serv_free(serv_index)+times(i,serv_index+2);
        else
            serv_free(serv_index+2) = serv_free(serv_index+2) + times(i,serv_index+2);
        end

    end
    days(sim) = max(serv_free)/24;
    batch_split(sim,:) = serv_batches;
end
days = sort(days);
histogram(days)
xlabel('Average amount of days needed')
ylabel('Occurrences')
title('Histogram of Average Days for Batch Processing')
mean_days = mean(days);
mean_split = round(mean(batch_split));
disp("Average days in greedy approach: " + num2str(mean_days))
disp("Average batch split between contractors: " + num2str(mean_split(1)) +...
    " / " + num2str(mean_split(2)) + newline())

% Greedy approach splits the batches approximately 54/46 between
% the contractors. Lets find an optimal split around this estimate

split_statistics = [];
for contractor_1 = mean_split(1)-4:mean_split(1)+4
    contractor_2 = batches - contractor_1;
    days = zeros(Nsim,1);

    % Simulate outcome for given split
    for sim = 1:Nsim
        % Simulate machine operating times
        times = zeros(batches, 4);
        for i = 1:4
        times(:,i) = randi([lb(i),ub(i)], batches, 1);
        end
        s1 = [0,0]; s2 = [0,0];
        for i = 1:contractor_1
            s1(1) = s1(1) + times(i,1);
            s1(2) = max(s1) + times(i,3);
        end
        for i = 1:contractor_2
            s2(1) = s2(1) + times(i,2);
            s2(2) = max(s2) + times(i,4);
        end
        days(sim) = max([s1(2),s2(2)])/24;
    end
    days = sort(days);
    days_95 = ceil(days(round(.95*Nsim)));
    disp("Split " + num2str(contractor_1) + "/" + num2str(contractor_2) +...
        ": average = " + num2str(mean(days) + ", 95% confidence = " +...
        num2str(days_95)))
end

% Best split based on the simulations is 52/48 with ~214 average days and
% 221 days with 95% confidence.
