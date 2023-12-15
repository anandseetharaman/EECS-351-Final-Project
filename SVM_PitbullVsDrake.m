%%

%Comparing Pitbull and Drake

filePaths = {'Drake - Wants and Needs (Lyrics) ft. Lil Baby.wav','Drake - Trust Issues (Lyrics)-2.wav','Drake - Search & Rescue-2.wav','Drake - Passionfruit (Lyrics)-2.wav','Drake - Nice For What.wav','Drake - Money In The Grave ft. Rick Ross.wav','Drake - Hotline Bling.wav','Pitbull - Time Of Our Lives (Lyric) ft. Ne-Yo.wav', 'Pitbull - Timber.wav','Pitbull - On The Floor.wav', 'Pitbull - International Love .wav', 'Pitbull - I Like It Lyrics.wav', 'Pitbull - Hotel Room Service.wav', 'Pitbull - Give Me Everything.wav', 'Pitbull - Fireball.wav'};

addpath(genpath(fullfile(matlabroot, 'toolbox', 'audio')));

audioData = cell(numel(filePaths), 1);
for i = 1:numel(filePaths)
    audioData{i} = audioread(filePaths{i});
end

numMFCC = 14; % Can change this number

% Assuming you have the Audio Toolbox installed
features = zeros(numel(audioData), numMFCC); % numMFCC is the desired number of coefficients

% Placeholder values, replace with the actual number of samples for each artist
numSamplesArtistA = 7;
numSamplesArtistB = 7;

labels = [ones(numSamplesArtistA, 1); 2 * ones(numSamplesArtistB, 1)]; % 1 for ArtistA, 2 for ArtistB

for i = 1:numel(audioData)
    % Explicitly specify the sampling rate (fs)
    [audio, fs] = audioread(filePaths{i});
    mfccs = mfcc(audio, double(fs), 'NumCoeffs', numMFCC);
    features(i, :) = mean(mfccs, 'all');
end


% Assuming you want to split 80% for training and 20% for testing
rng(42); % Set seed for reproducibility
cv = cvpartition(labels, 'HoldOut', (3/7));

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





%% 
ads = audioDatastore('/path/to/data/folder/with/subfolders/of/artists', 'LabelSource', 'foldernames', 'FileExtensions', '.wav','IncludeSubfolders',true);
[adsTrain,adsTest] = splitEachLabel(ads,0.8);
[sampleTrain,dsInfo] = read(adsTrain);

fs = dsInfo.SampleRate;
windowLength = round(0.03*fs);
overlapLength = round(0.025*fs);
afe = audioFeatureExtractor(SampleRate=fs, ...
    Window=hamming(windowLength,"periodic"),OverlapLength=overlapLength, ...
    zerocrossrate=true,shortTimeEnergy=true,pitch=true,mfcc=true);

featureMap = info(afe);

features = [];
labels = [];
energyThreshold = 0.005;
zcrThreshold = 0.2;

allFeatures = extract(afe,adsTrain,SampleRateMismatchRule="resample");
allLabels = adsTrain.Labels;

for ii = 1:numel(allFeatures)

    thisFeature = allFeatures{ii};

    isSpeech = thisFeature(:,featureMap.shortTimeEnergy) > energyThreshold;
    isVoiced = thisFeature(:,featureMap.zerocrossrate) < zcrThreshold;

    voicedSpeech = isSpeech & isVoiced;

    thisFeature(~voicedSpeech,:) = [];
    thisFeature(:,[featureMap.zerocrossrate,featureMap.shortTimeEnergy]) = [];
    label = repelem(allLabels(ii),size(thisFeature,1));
    
    features = [features;thisFeature];
    labels = [labels,label];
end

M = mean(features,1);
S = std(features,[],1);
features = (features-M)./S;

trainedClassifier = fitcknn(features,labels, ...
    Distance="euclidean", ...
    NumNeighbors=5, ...
    DistanceWeight="squaredinverse", ...
    Standardize=false, ...
    ClassNames=unique(labels));

k = 5;
group = labels;
c = cvpartition(group,KFold=k); % 5-fold stratified cross validation
partitionedModel = crossval(trainedClassifier,CVPartition=c);

validationAccuracy = 1 - kfoldLoss(partitionedModel,LossFun="ClassifError");
fprintf('\nValidation accuracy = %.2f%%\n', validationAccuracy*100);

validationPredictions = kfoldPredict(partitionedModel);
figure(Units="normalized",Position=[0.4 0.4 0.4 0.4])
confusionchart(labels,validationPredictions,title="Validation Accuracy", ...
    ColumnSummary="column-normalized",RowSummary="row-normalized");

features = [];
labels = [];
numVectorsPerFile = [];

allFeatures = extract(afe,adsTest,SampleRateMismatchRule="resample");
allLabels = adsTest.Labels;

for ii = 1:numel(allFeatures)

    thisFeature = allFeatures{ii};

    isSpeech = thisFeature(:,featureMap.shortTimeEnergy) > energyThreshold;
    isVoiced = thisFeature(:,featureMap.zerocrossrate) < zcrThreshold;

    voicedSpeech = isSpeech & isVoiced;

    thisFeature(~voicedSpeech,:) = [];
    numVec = size(thisFeature,1);
    thisFeature(:,[featureMap.zerocrossrate,featureMap.shortTimeEnergy]) = [];
    
    label = repelem(allLabels(ii),numVec);
    
    numVectorsPerFile = [numVectorsPerFile,numVec];
    features = [features;thisFeature];
    labels = [labels,label];
end
features = (features-M)./S;

prediction = predict(trainedClassifier,features);
prediction = categorical(string(prediction));

figure(Units="normalized",Position=[0.4 0.4 0.4 0.4])
confusionchart(labels(:),prediction,title="Test Accuracy (Per Frame)", ...
    ColumnSummary="column-normalized",RowSummary="row-normalized");

r2 = prediction(1:numel(adsTest.Files));
idx = 1;
for ii = 1:numel(adsTest.Files)
    r2(ii) = mode(prediction(idx:idx+numVectorsPerFile(ii)-1));
    idx = idx + numVectorsPerFile(ii);
end

figure(Units="normalized",Position=[0.4 0.4 0.4 0.4])
confusionchart(adsTest.Labels,r2,title="Test Accuracy (Per File)", ...
    ColumnSummary="column-normalized",RowSummary="row-normalized");
