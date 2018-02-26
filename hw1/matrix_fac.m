load rawData;

dataLen = size(rawData, 1);

%% remove empty movies


trainSet = randsample(linspace(1, dataLen, dataLen), floor(dataLen/2));
testSet = setdiff(linspace(1, dataLen, dataLen), trainSet);

result = struct();
result.RMSE = [];
result.MRR = [];
result.MRR_intest = [];

%% hyper parameters

% result_test4
% rank_r_set = [1:3:44];

% result_test5
% rank_r_set = [1:3:44];
% lambda_set = [0:0.05:0.2];

% result_test6
% result_test7
rank_r_set = [1 2 4 8 16 32 64 128 256];
lambda_set = [0.1];

%% init
max_loop = 100;
tol = 5e-5;
upt_step = 1e-2;

%% main loop
for rank_r_indx = 1:length(rank_r_set)
    for lambda_indx = 1:length(lambda_set)
        rank_r = rank_r_set(rank_r_indx);
        lambda = lambda_set(lambda_indx);
        fprintf('now computing for rank %d and lambda %d.\n', rank_r, lambda);
        %-----------------------------------------------------------------%
        % @computeVW
        [V, W] = computeVW(max_loop, tol, upt_step, rawData, rank_r, lambda, trainSet);
        %-----------------------------------------------------------------%
        %-----------------------------------------------------------------%
        % @computeRMSE
        RMSE = computeRMSE(rawData, testSet, V, W);
        %-----------------------------------------------------------------%
        result.RMSE = [result.RMSE RMSE];
        %-----------------------------------------------------------------%
        % @computeMRR
        [MRR, MRR_intest] = computeMRR(rawData, testSet, V, W);
        %-----------------------------------------------------------------%
%         result.MRR = [result.MRR MRR];
        result.MRR_intest = [result.MRR_intest MRR_intest];
        save('result_test', 'result');
    end
end

function [V, W] = computeVW(max_loop, tol, upt_step, rawData, rank_r, lambda, trainSet)
    count = 0;
    upt_value = 5;
    pre_value = 10;
    userNum = max(rawData(:, 1));
    movieNum = max(rawData(:, 2));
    V = rand(userNum, rank_r);
    W = rand(movieNum, rank_r);
    while(count<max_loop)
        tic
        upt_value = 0;
        for i = 1:length(trainSet)
            user_indx = rawData(trainSet(i), 1);
            movie_indx = rawData(trainSet(i), 2);
            rating = rawData(trainSet(i), 3);
            rating_pred = V(user_indx, :)*W(movie_indx, :)';
            % rating_pred = max([min([rating_pred, 5]), 0]);
            % update V, gradient descend and project back
            upt = upt_step*((rating - rating_pred)*W(movie_indx, :) - lambda*V(user_indx, :));
            temp = V(user_indx, :) + upt;
            temp(temp<0) = 0;
            V(user_indx, :) = temp;
            % update W, same
            upt = upt_step*((rating - rating_pred)*V(user_indx, :) - lambda*W(movie_indx, :));
            temp = W(movie_indx, :) + upt;
            temp(temp<0) = 0;
            W(movie_indx, :) = temp;
            upt_value = upt_value + abs(rating - rating_pred);
        end
        upt_value = upt_value / length(trainSet);
        count = count + 1;
        if(upt_value>pre_value || abs(upt_value-pre_value)<tol)
            break;
        else
            pre_value = upt_value;
        end
%         fprintf('step %d update value %d\n', count, upt_value);
        toc
    end
end

function RMSE = computeRMSE(rawData, testSet, V, W)
    RMSE = 0;
    for i = 1:length(testSet)
        user_indx = rawData(testSet(i), 1);
        movie_indx = rawData(testSet(i), 2);
        rating = rawData(testSet(i), 3);
        rating_pred = V(user_indx, :)*W(movie_indx, :)';
%         rating_pred = max([min([rating_pred, 5]), 0]);
        RMSE = RMSE + (rating_pred-rating)^2;
    end
    RMSE = sqrt(RMSE/length(testSet));
end

function [MRR, MRR_intest] = computeMRR(rawData, testSet, V, W)
    MRR = 0;
    MRR_intest = 0;
    users = unique(rawData(:, 1));
    user_num = 0;
    for i = 1:length(users)
        % % sort in all movies
%         cur_user = find(rawData(:, 1)==users(i));
%         cur_user = cur_user(ismember(cur_user, testSet));
%         rating_pred = V(users(i), :)*W';
%         [~, rating_indx] = sort(rating_pred);
%         rating_indx = ones(size(rating_indx))./(rating_indx);
%         cur_user = cur_user(find(rawData(cur_user, 3)>=3));
%         if(isempty(cur_user))
%             continue;
%         end
%         MRR = MRR + mean(rating_indx(rawData(cur_user, 2)));
        % % sort in test movies
        cur_user = find(rawData(:, 1)==users(i));
        cur_user = cur_user(ismember(cur_user, testSet));
        rating_pred = V(users(i), :)*W';
        [~, rating_indx] = sort(rating_pred(rawData(cur_user, 2)), 'descend');
        rating_indx = ones(size(rating_indx))./(rating_indx);
        cur_user = find(rawData(cur_user, 3)>=3);
        if(isempty(cur_user))
            continue;
        end
        MRR_intest = MRR_intest + mean(rating_indx(cur_user));
        user_num = user_num + 1;
    end
%     MRR = MRR / user_num;
    MRR_intest = MRR_intest / user_num;
end