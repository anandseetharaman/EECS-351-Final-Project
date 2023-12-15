disp('Decision Tree for Magnitude Spectrum START');
%Parameters for the spectrogram
windowSize = 1024;
overlap = 512;
nfft = 1024;

%Create an empty database to store magnitude spectrum
database = struct('filename', {}, 'mag', {}, 'artist', {});
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
    
    %Compute the magnitude spectrum (power spectral density)
    magnitudeSpectrum = abs(S);

    %Compute max value across time frames for each frequency
    frequencyMatrix = max(magnitudeSpectrum, [], 2);

    
    %Pad magnitude spectrum so they are all the same size
    padding = zeros(513,1);
    if(size(frequencyMatrix,1) < 513)
        padding(1:size(frequencyMatrix,1), 1) = frequencyMatrix;
        frequencyMatrix = padding;
    end
    
    %Artist labels
    if(i <= 10)
        artist = 'Drake';
    elseif(i > 10 & i <= 20)
        artist = 'Taylor Swift';
    elseif(i > 20 & i <= 30)
        artist = 'Beyonce';
    else
        artist = 'Pitbull';
    end

    % Store the magnitude spectrum max, filename, and artist in the database
    entry = struct('filename', audioFiles{i}, 'mag', frequencyMatrix, 'artist', artist);
   
    database = [database, entry];
end
avg_accuracy = 0;

for random = 1:100
    %run decision tree classifier
    avg_accuracy = avg_accuracy + decision_tree_v2_magnitude(database, random);
end

fprintf('Avg Accuracy: %.2f%%\n', avg_accuracy / 100 * 100);