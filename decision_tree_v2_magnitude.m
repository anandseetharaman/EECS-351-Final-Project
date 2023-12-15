function y = decision_tree_v2_magnitude(database, random)
    %Feature matrix
    songs = length(database);
    data_mag = zeros(songs,513);
    data_labels = strings(songs,1);
    data_filenames = strings(songs,1);
    for i = 1:songs
        data_mag(i,:) = database(i).mag;
        data_labels(i,1) = string(database(i).artist);
        data_filenames(i,1) = database(i).filename;
    end
    %Split the data into training and testing sets
    rng(random);  %Set seed for reproducibility
    splitRatio = 0.8;
    splitIdx = randperm(size(data_mag, 1), round(splitRatio * size(data_mag, 1)));

    data_frequency_train = data_mag(splitIdx, :);
    data_labels_train = data_labels(splitIdx);
    %data_filenames_train = data_filenames(splitIdx);

    data_frequency_test = data_mag(~ismember(1:size(data_mag, 1), splitIdx), :);
    data_labels_test = data_labels(~ismember(1:size(data_mag, 1), splitIdx));
    data_filenames_test = data_filenames(~ismember(1:size(data_mag, 1), splitIdx));

    %Train a decision tree model
    treeModel = fitctree(data_frequency_train, data_labels_train);

    %Make predictions on the test set
    data_labels_pred = predict(treeModel, data_frequency_test);
    
    %Evaluate the accuracy
    accuracy = sum(data_labels_pred == data_labels_test) / numel(data_labels_test);
    fprintf('Accuracy: %.2f%%\n', accuracy * 100);
    
    
    %Display results with filenames
    for i = 1:numel(data_filenames_test)
        fprintf('PREDICTION: %d\n',i);
        fprintf('Song: %s\n',data_filenames_test(i));
        disp('Predicted: ');
        disp(data_labels_pred(i));
        disp('Actual: ');
        disp(data_labels_test(i));
        if(data_labels_pred(i) == data_labels_test(i))
            fprintf('PREDICTION: %d IS CORRECT\n',i);
        else
            fprintf('PREDICTION: %d IS WRONG\n',i);
        end
        fprintf('\n');
                
    end
    %view decision tree WARNING comment this out if you are going to run this 100
    %times
    view(treeModel, 'Mode', 'graph');
    y = accuracy;
end