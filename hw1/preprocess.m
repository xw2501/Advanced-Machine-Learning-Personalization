%% preprocessing
function preprocess()
    rawData = csvread('ratings.csv', 1);
    rawData = rawData(:, 1:3);
    
    movies_id = unique(rawData(:, 2));
    for i = 1:length(rawData(:, 2))
        rawData(i, 2) = find(movies_id==rawData(i, 2));
    end
    
    save('rawData', 'rawData');
end