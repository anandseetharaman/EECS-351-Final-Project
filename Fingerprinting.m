% Fingerprinting Script
disp('FINGERPRINTING START');
% Parameters for the spectrogram
windowSize = 1024;
overlap = 512;
nfft = 1024;

% Create an empty database to store fingerprints
database = struct('filename', {}, 'fingerprint', {}, 'artist', {});

audioFiles = {'best_I_ever_had.wav','both.wav','gods_plan.wav','hotline_bling.wav','Jumpman.wav','money_in_the_grave.wav','nice_for_what.wav','one_dance.wav','wants_and_needs.wav','the_motto.wav', 'swift_all_too_well.wav', 'swift_anti_hero.wav', 'swift_bad_blood.wav', 'swift_blank_space.wav', 'swift_love_story.wav', 'swift_out_of_the_woods.wav', 'swift_shake_it_off.wav', 'swift_style.wav', 'swift_wildest_dreams.wav', 'swift_you_belong_with_me.wav'};
%audioFiles = {'swift_all_too_well.wav', 'swift_anti_hero.wav', 'swift_bad_blood.wav', 'swift_blank_space.wav', 'swift_love_story.wav', 'swift_out_of_the_woods.wav', 'swift_shake_it_off.wav', 'swift_style.wav', 'swift_wildest_dreams.wav', 'swift_you_belong_with_me.wav'};

numSongs = length(audioFiles);
% Process each audio file
for i = 1:numSongs
    
    % Load the audio file
    [y, fs] = audioread(audioFiles{i});
    
    % Compute the spectrogram
    [S, F, T] = spectrogram(y(:,1), hamming(windowSize), overlap, nfft, fs);
    
    % Your fingerprint generation function (replace this with your actual implementation)
    fingerprint = hashSpectrogramFeatures(S,F);
    
    if(i < 11)
        artist = 'Drake';
    else
        artist = 'Taylor_Swift';
    end

    % Store the fingerprint, filename, and artist in the database
    entry = struct('filename', audioFiles{i}, 'fingerprint', fingerprint, 'artist', artist);
   
    database = [database, entry];
end

%run decision tree classifier
%decision_tree_v1(database);

% Query a new audio file and match it against the database
queryFilePath = 'swift_all_too_well.wav';

% Load the query audio file
[y_query, fs_query] = audioread(queryFilePath);

% Compute the spectrogram for the query
[S_query, F_query, T_query] = spectrogram(y_query(:,1), hamming(windowSize), overlap, nfft, fs_query);

% Your fingerprint generation function for the query
queryFingerprint = hashSpectrogramFeatures(S_query, F_query);

% Matching (compare the query fingerprint with database fingerprints)
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

% Your comparison function (replace this with your actual implementation)
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

%Hash function for spectrogram features
function fingerprint = hashSpectrogramFeatures(spec_S,spec_F)
    %Number of logarithmic bands to split frequencies into
    numLogBands = 6;

    % Specify the minimum and maximum frequencies
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

    % Apply a max filter to identify local maxima
    maxFilteredSpectrogram = ordfilt2(abs(spec_S), 9, ones(3, 3));

    % Create a binary image with ones at local maxima
    binaryImage = (abs(spec_S) == maxFilteredSpectrogram);
   
    figure(2);
    imagesc(binaryImage);
    colormap(gray);
    title(['Binary Image - Log Band ', num2str(i)]);
    xlabel('Time');
    ylabel('Frequency');
    colorbar;
    % Convert the binary image to a binary vector
    fingerprint = binaryImage(:);
end
