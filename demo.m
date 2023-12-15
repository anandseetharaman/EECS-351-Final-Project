% Ensure demoKNNClassifier.mat has been loaded into the Workspace and that
% the supporting .wav files are in the current folder.
% Run either 1A, 1B, 1C, or 1D then 2 by using the 'Run Section' option in 
% the 'Editor' Header, outputs prediction to Command Window.

%% 1A (Normal Test) Expected Pitbull

filePath = 'Pitbull - Hotel Room Service.wav';
[audioData, sampleRate] = audioread('Pitbull - Hotel Room Service.wav');
sound(audioData, sampleRate);
%% 1B (Normal Test) Expected Drake

filePath = 'Drake - Churchill Downs.wav';
[audioData, sampleRate] = audioread('Drake - Churchill Downs.wav');
sound(audioData, sampleRate);
%% 1C (Short Clip Test) Expected Lana Del Rey

filePath = 'Lana Del Rey - Doin Time.wav'; 
[audioData, sampleRate] = audioread('Lana Del Rey - Doin Time.wav');
sound(audioData, sampleRate);
%% 1D (Talking Test) Expected Taylor Swift

filePath = 'Taylor Swift - Talking.wav';
[audioData, sampleRate] = audioread('Taylor Swift - Talking.wav');
sound(audioData, sampleRate);
%% 2 Prediction Code
[y, Fs] = audioread(filePath);

N = length(y); 
frequencies = (0:N-1) * Fs / N; 

Y = fft(y, N); 
Y_mag = abs(Y(1:N/2+1)); 

[~, idx] = max(Y_mag);

fundamentalFrequency = frequencies(idx);

filteredSignal = filter(testnotch(fundamentalFrequency),y); % 

audiowrite("filtered_"+filePath,filteredSignal,Fs);
[folder, baseFileName, ext] = fileparts(filePath);
filtered_fileName = ['filtered_', baseFileName, ext];
filtered_filePath = fullfile(folder, filtered_fileName);

adstestmain = audioDatastore(filtered_filePath);

fs = 44100;
windowLength = round(0.025*fs);
overlapLength = round(0.020*fs);
afe = audioFeatureExtractor(SampleRate=fs, ...
    Window=hamming(windowLength,"periodic"),OverlapLength=overlapLength, ...
    zerocrossrate=true,shortTimeEnergy=true,pitch=true,mfcc=true,mfccDelta=true,mfccDeltaDelta=true,spectralCentroid=true,harmonicRatio=true);
featureMap = info(afe);

features = [];
labels = [];
energyThreshold = 0.005;
zcrThreshold = 0.15;
numVectorsPerFile = [];

allFeatures = extract(afe,adstestmain,SampleRateMismatchRule="resample");
allLabels = {'Drake'; 'Taylor Swift'; 'Lana Del Rey'; 'Pitbull'};

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

M = mean(features, 1);
S = std(features, [], 1);
features = (features - M) ./ S;

prediction = predict(trainedClassifier,features);
prediction = categorical(string(prediction));

r2 = prediction(1:numel(adstestmain));
idx = 1;
for ii = 1:numel(adstestmain)
    r2(ii) = mode(prediction(idx:idx+numVectorsPerFile(ii)-1));
    idx = idx + numVectorsPerFile(ii);
end

disp(['Prediction:' r2]);
