%Fingerprinting / decision tree 1 script 
disp('FINGERPRINTING START');
%Parameters for the spectrogram
windowSize = 1024;
overlap = 512;
nfft = 1024;

%Create an empty database to store fingerprints
database = struct('filename', {}, 'fingerprint', {}, 'artist', {});

audioFiles = {'best_I_ever_had.wav','both.wav','gods_plan.wav','hotline_bling.wav','Jumpman.wav','money_in_the_grave.wav','nice_for_what.wav','one_dance.wav','wants_and_needs.wav','the_motto.wav', ... 
              'swift_all_too_well.wav', 'swift_anti_hero.wav', 'swift_bad_blood.wav', 'swift_blank_space.wav', 'swift_love_story.wav', 'swift_out_of_the_woods.wav', 'swift_shake_it_off.wav', 'swift_style.wav', 'swift_wildest_dreams.wav', 'swift_you_belong_with_me.wav' ...
              'Beyonce_7_11.wav', 'Beyonce_Best Thing I Never Had.wav', 'Beyonce_Countdown.wav', 'Beyonce_Formation.wav', 'Beyonce_Halo.wav', 'Beyonce_If I Were A Boy.wav', 'Beyonce_Love On Top.wav', 'Beyonce_Pretty Hurts.wav', 'Beyonce_Single Ladies.wav', 'Beyonce_Sorry.wav' ...
              'Pitbull - Dont Stop the Party.wav','Pitbull - Feel This Moment.wav', 'Pitbull - Fireball.wav', 'Pitbull - Give Me Everything (Lyrics) Ft. Ne-Yo, Afrojack, Nayer.wav', 'Pitbull - Hotel Room Service.wav', 'Pitbull - I Like It Lyrics.wav', 'Pitbull - International Love .wav', 'Pitbull - On The Floor.wav', 'Pitbull - Timber.wav', 'Pitbull - Time of Our Lives.wav'};

numSongs = length(audioFiles);
%Process each audio file
for i = 1:numSongs
    
    %Load the audio file
    [y, fs] = audioread(audioFiles{i});
    
    %Compute the spectrogram
    [S, F, T] = spectrogram(y(:,1), hamming(windowSize), overlap, nfft, fs);
    
    if(i == 39)
    %Plot the spectrogram
    figure;
    imagesc(T, F, 10*log10(abs(S)));
    axis xy;  % To flip the y-axis so that lower frequencies are at the bottom
    colormap(jet);  % You can choose a different colormap if needed

    %Label the axes
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    title('Spectrogram of Timber by Pitbull');
    colorbar;  % Add a colorbar to show the power levels
    end

    %Your fingerprint generation function (replace this with your actual implementation)
    fingerprint = hashSpectrogramFeatures(S,F,i);
    
    %Pad fingerprints so they are all the same size
    padding = logical(zeros(500688,1));
    if(size(fingerprint,1) < 500688)
        padding(1:size(fingerprint,1), 1) = fingerprint;
        fingerprint = padding;
    end

    if(i <= 10)
        artist = 'Drake';
    elseif(i > 10 & i <= 20)
        artist = 'Taylor Swift';
    elseif(i > 20 & i <= 30)
        artist = 'Beyonce';
    else
        artist = 'Pitbull';
    end

    % tore the fingerprint, filename, and artist in the database
    entry = struct('filename', audioFiles{i}, 'fingerprint', fingerprint, 'artist', artist);
   
    database = [database, entry];
end

%Run decision tree classifier
decision_tree(database);

%{
%perform Jaccard Comparison with query file
disp('Perform Jaccard Comparison with query file START');
% Query a new audio file and match it against the database
queryFilePath = 'swift_all_too_well.wav';

%Load the query audio file
[y_query, fs_query] = audioread(queryFilePath);

%Compute the spectrogram for the query
[S_query, F_query, T_query] = spectrogram(y_query(:,1), hamming(windowSize), overlap, nfft, fs_query);

%Your fingerprint generation function for the query
queryFingerprint = hashSpectrogramFeatures(S_query, F_query);

%Matching (compare the query fingerprint with database fingerprints)
threshold = 0.8; % Adjust the threshold as needed
for i = 1:length(database)
    similarity = compareFingerprints(queryFingerprint, database(i).fingerprint);
    disp('Similarity: ')
    disp(similarity);
    % Check if similarity is above the threshold for a match
    if similarity > threshold
        disp(['Match found for: ', database(i).filename]);
    else
        disp(['No match found for: ', database(i).filename])
    end
    
end

%Your comparison function (replace this with your actual implementation)
function similarity = compareFingerprints(queryFingerprint, referenceFingerprint)
    % Implement your comparison logic here
    % Example: Compute the Jaccard similarity between two binary vectors
    if(size(queryFingerprint,1) < size(referenceFingerprint,1))
        pad = zeros(size(referenceFingerprint,1),1);
        pad(1:size(queryFingerprint,1), 1) = queryFingerprint;
        queryFingerprint = pad;
        
    elseif(size(queryFingerprint,1) > size(referenceFingerprint,2))
        pad = zeros(size(queryFingerprint,1),1);
        pad(1:size(referenceFingerprint,1), 1) = referenceFingerprint;
        referenceFingerprint = pad;
    end
    similarity = sum(queryFingerprint & referenceFingerprint) / sum(queryFingerprint | referenceFingerprint);
end
%}
%Hash function for spectrogram features
function fingerprint = hashSpectrogramFeatures(spec_S,spec_F,song_index)
    %Number of logarithmic bands to split frequencies into
    numLogBands = 6;

    %Specify the minimum and maximum frequencies
    minFreq = 1;
    maxFreq = max(abs(spec_F(:)));

    %Create logarithmically spaced bands
    logBands = logspace(log10(minFreq), log10(maxFreq), numLogBands + 1);
    maxInBands = zeros(size(spec_S, 2), numLogBands);
   
    for i = 1:numLogBands
        bandIndices = spec_F >= logBands(i) & spec_F <= logBands(i+1);
        
        if all(bandIndices == 0)
            %If bandIndices is all zeros, set maxInBands to zero
            maxInBands(:, i) = 0;
        else
            %Else, compute the maximum value
            maxInBands(:, i) = max(abs(spec_S(bandIndices, :)), [], 1);
        end
    end

    %Apply a max filter to identify local maxima
    maxFilteredSpectrogram = ordfilt2(abs(spec_S), 9, ones(3, 3));

    %Create a binary image with ones at local maxima
    binaryImage = (abs(spec_S) == maxFilteredSpectrogram);
   
    %The spectrogram has a time range from 0 to 10 seconds
    originalTimeRange = [0, 10];
    
    %plot binary image
    if(song_index == 39)
    figure(2);
    imagesc(binaryImage);
    colormap(gray);
    title(['Binary Image for Timber by Pitbull - Log Band ', num2str(i)]);
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    % Adjust x-axis ticks and labels based on the original time range
    xticks(linspace(1, size(spec_S, 2), numel(originalTimeRange)));
    xticklabels(linspace(originalTimeRange(1), originalTimeRange(2), numel(originalTimeRange)));
    colorbar;
    end
    % Convert the binary image to a binary vector
    fingerprint = binaryImage(:);
end

%decision tree that takes in fingerprinting
function x = decision_tree(database)
    songs = length(database);
    %feature matrix
    data_fingerprint = zeros(songs,500688);
    data_labels = strings(songs,1);
    data_filenames = strings(songs,1);
    for i = 1:songs
        data_fingerprint(i,:) = database(i).fingerprint;
        data_labels(i,1) = string(database(i).artist);
        data_filenames(i,1) = database(i).filename;
    end
    avg_accuracy = 0;

    %Warning: You may want to comment out plots before running a high
    %number of trials.
    trials = 100;
    for k = 1:trials
    %Split the data into training and testing sets
    rng(k);  %Set seed for reproducibility
    splitRatio = 0.8;
    splitIdx = randperm(size(data_fingerprint, 1), round(splitRatio * size(data_fingerprint, 1)));

    data_fingerprint_train = data_fingerprint(splitIdx, :);
    data_labels_train = data_labels(splitIdx);
    data_filenames_train = data_filenames(splitIdx);

    data_fingerprint_test = data_fingerprint(~ismember(1:size(data_fingerprint, 1), splitIdx), :);
    data_labels_test = data_labels(~ismember(1:size(data_fingerprint, 1), splitIdx));
    data_filenames_test = data_filenames(~ismember(1:size(data_fingerprint, 1), splitIdx));

    %Train a decision tree model
    treeModel = fitctree(data_fingerprint_train, data_labels_train);

    %Make predictions on the test set
    data_labels_pred = predict(treeModel, data_fingerprint_test);
    
    %Evaluate the accuracy
    accuracy = sum(data_labels_pred == data_labels_test) / numel(data_labels_test);
    fprintf('Accuracy: %.2f%%\n', accuracy * 100);
    avg_accuracy = avg_accuracy + accuracy;
    
    %Display results with filenames
    for i = 1:numel(data_filenames_test)
        %fprintf('Song: %s, Predicted: %s, Actual: %s\n', data_filenames_test(i), data_labels_pred(i), data_labels_test(i));
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

    view(treeModel, 'Mode', 'graph');
    end
    fprintf('Avg Accuracy: %.2f%%\n', avg_accuracy / 100 * 100);
end
