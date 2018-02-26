load result_test;

figure,
plot(result.MRR_intest, '-s');
title('coarse graph MRR');
xlabel('rank');
ylabel('MRR value');
saveas(gcf, 'coarse graph MRR', 'png');

figure,
plot(result.RMSE, '-s');
title('coarse graph RMSE');
xlabel('rank');
ylabel('RMSE value');
saveas(gcf, 'coarse graph RMSE', 'png');

MRR = [];
RMSE = [];

load result_test5;
MRR = [MRR; result.MRR_intest(3:5:75)];
RMSE = [RMSE; result.RMSE(3:5:75)];

figure,
X = [1:3:44];
Y = [0:0.05:0.2];
s1 = surf(repmat(X, 5, 1), repmat(Y', 1, 15), reshape(result.MRR_intest, 5, 15));
s1.EdgeColor = 'none';
title('2-D surf plot MRR');
xlabel('rank');
ylabel('lambda');
saveas(gcf, '2-D surf plot MRR', 'fig');

figure,
X = [1:3:44];
Y = [0:0.05:0.2];
s1 = surf(repmat(X, 5, 1), repmat(Y', 1, 15), reshape(result.RMSE, 5, 15));
s1.EdgeColor = 'none';
title('2-D surf plot RMSE');
xlabel('rank');
ylabel('lambda');
saveas(gcf, '2-D surf plot RMSE', 'fig');

load result_test4;
MRR = [MRR; result.MRR_intest];
RMSE = [RMSE; result.RMSE];

load result_test6;
MRR = [MRR; result.MRR_intest];
RMSE = [RMSE; result.RMSE];

load result_test7;
MRR = [MRR; result.MRR_intest];
RMSE = [RMSE; result.RMSE];

figure,
plot(X, mean(MRR), '-s');
title('mean over 4 tests MRR');
xlabel('rank');
ylabel('mean value');
saveas(gcf, 'mean over 4 tests MRR', 'png');

figure,
plot(X, var(MRR), '-s');
title('variance over 4 tests MRR');
xlabel('rank');
ylabel('variance value');
saveas(gcf, 'variance over 4 tests MRR', 'png');

figure,
plot(X, mean(RMSE), '-s');
title('mean over 4 tests RMSE');
xlabel('rank');
ylabel('mean value');
saveas(gcf, 'mean over 4 tests RMSE', 'png');

figure,
plot(X, var(RMSE), '-s');
title('variance over 4 tests RMSE');
xlabel('rank');
ylabel('variance value');
saveas(gcf, 'variance over 4 tests RMSE', 'png');