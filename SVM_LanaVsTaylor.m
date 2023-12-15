%%

%Comparing Beyonce and Taylor Swift

filePaths = {'Lana Del Rey - National Anthem (Lyrics)-2.wav', 'Lana Del Rey - Born To Die.wav','Lana Del Rey - Blue Jeans-2.wav','Lana Del Rey - Bel Air (Official Video)-2.wav','Lana Del Rey - Young and Beautiful.wav', 'Lana Del Rey - West Coast-2.wav', 'Lana Del Rey - Summertime Sadness (Lyrics)-2.wav', 'Lana Del Rey - Shades Of Cool-2.wav', 'Lana Del Rey - Radio (Lyrics)-2.wav','Taylor Swift - You Belong With Me.wav','Taylor Swift - Out Of The Woods (Taylors Version) (Lyric Video).wav','Taylor Swift - Love Story.wav','Taylor Swift - Blank Space (Taylors Version) (Lyric Video).wav','Taylor Swift - Bad Blood (Taylors Version) (Lyric Video).wav','Taylor Swift - Anti-Hero (Official Lyric Video).wav','Taylor Swift - Wildest Dreams (Taylors Version) (Lyric Video).wav','Taylor Swift - Style (Taylors Version) (Lyric Video).wav','Taylor Swift - Shake It Off (Taylors Version) (Lyric Video).wav'};
addpath(genpath(fullfile(matlabroot, 'toolbox', 'audio')));

audioData = cell(numel(filePaths), 1);
for i = 1:numel(filePaths)
    audioData{i} = audioread(filePaths{i});
end

numMFCC = 14; % Can change this number

% Assuming you have the Audio Toolbox installed
features = zeros(numel(audioData), numMFCC); % numMFCC is the desired number of coefficients

% Placeholder values, replace with the actual number of samples for each artist
numSamplesArtistA = 9;
numSamplesArtistB = 9;

labels = [ones(numSamplesArtistA, 1); 2 * ones(numSamplesArtistB, 1)]; % 1 for ArtistA, 2 for ArtistB

for i = 1:numel(audioData)
    % Explicitly specify the sampling rate (fs)
    [audio, fs] = audioread(filePaths{i});
    mfccs = mfcc(audio, double(fs), 'NumCoeffs', numMFCC);
    features(i, :) = mean(mfccs, 'all');
end


% Assuming you want to split 80% for training and 20% for testing
rng(42); % Set seed for reproducibility
cv = cvpartition(labels, 'HoldOut', (3/9));

% Training set
X_train = features(training(cv), :);
Y_train = labels(training(cv));

% Testing set
X_test = features(test(cv), :);
Y_test = labels(test(cv));

% Assuming you have the Statistics and Machine Learning Toolbox
X_train_scaled = zscore(X_train);
X_test_scaled = zscore(X_test);

% Assuming you have the Statistics and Machine Learning Toolbox
svm_model = fitcsvm(X_train_scaled, Y_train, 'KernelFunction', 'linear');

% Assuming you have the Statistics and Machine Learning Toolbox
predictions = predict(svm_model, X_test_scaled);

% Evaluate accuracy
accuracy = sum(predictions == Y_test) / numel(Y_test);

confMat = confusionmat(Y_test, predictions);

% Visualize confusion matrix as a heatmap
figure;
heatmap({'ArtistA', 'ArtistB'}, {'ArtistA', 'ArtistB'}, confMat, 'Colormap', parula, 'ColorLimits', [min(confMat(:)), max(confMat(:))]);
title('Confusion Matrix');
xlabel('Predicted Class');
ylabel('True Class');
    
% Calculate precision, recall, and F1-score
precision = diag(confMat) ./ sum(confMat, 1)';
recall = diag(confMat) ./ sum(confMat, 2);
f1Score = 2 * (precision .* recall) ./ (precision + recall);

