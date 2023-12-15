function y = decision_tree_v3_MFCC(database)
    songs = length(database);
    %Feature matrix
    data_features = zeros(songs, 13);
    data_labels = strings(songs, 1);
    data_filenames = strings(songs, 1);
    
    for i = 1:songs
        features = [database(i).MFCC(:,1) database(i).MFCC(:,2) database(i).MFCC(:,3) database(i).MFCC(:,4) database(i).MFCC(:,5) ...
                    database(i).MFCC(:,6) database(i).MFCC(:,7) database(i).MFCC(:,8) database(i).MFCC(:,9) database(i).MFCC(:,10) ...
                    database(i).MFCC(:,11) database(i).MFCC(:,12) database(i).MFCC(:,13)];
                    %database(i).pitch database(i).zerocrossrate database(i).shortTimeEnergy];            
        data_features(i, :) = features;
        data_labels(i, 1) = string(database(i).artist);
        data_filenames(i, 1) = database(i).filename;
    end

    avg_accuracy = 0;
    for i = 1:100
      
    % Split the data into training and testing sets
    rng(i);  % Set seed for reproducibility
    splitRatio = 0.8;
    splitIdx = randperm(size(data_features, 1), round(splitRatio * size(data_features, 1)));

    data_features_train = data_features(splitIdx, :);
    data_labels_train = data_labels(splitIdx);

    data_features_test = data_features(~ismember(1:size(data_features, 1), splitIdx), :);
    data_labels_test = data_labels(~ismember(1:size(data_features, 1), splitIdx));
    data_filenames_test = data_filenames(~ismember(1:size(data_features, 1), splitIdx));

    % Train a decision tree model
    treeModel = fitctree(data_features_train, data_labels_train);

    % Make predictions on the test set
    data_labels_pred = predict(treeModel, data_features_test);

    % Evaluate the accuracy
    accuracy = sum(data_labels_pred == data_labels_test) / numel(data_labels_test);
    fprintf('Accuracy: %.2f%%\n', accuracy * 100);
    avg_accuracy = avg_accuracy + accuracy;
    % Display results with filenames
    for i = 1:numel(data_filenames_test)
        fprintf('PREDICTION: %d\n', i);
        fprintf('Song: %s\n', data_filenames_test(i));
        disp('Predicted: ');
        disp(data_labels_pred(i));
        disp('Actual: ');
        disp(data_labels_test(i));

        if data_labels_pred(i) == data_labels_test(i)
            fprintf('PREDICTION: %d IS CORRECT\n', i);
        else
            fprintf('PREDICTION: %d IS WRONG\n', i);
        end
        fprintf('\n');
    end

    view(treeModel, 'Mode', 'graph');
    end
    fprintf('Accuracy: %.2f%%\n', avg_accuracy/100 * 100);
end
