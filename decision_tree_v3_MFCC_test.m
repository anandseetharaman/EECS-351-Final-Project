%Decision tree that takes in MFCCs
disp('Decision Tree using MFCC START');

%Create an empty database to store MFCCs
%Note: we are extracting other features but decided to only use MFCCs
database = struct('filename', {}, 'MFCC', {}, 'zerocrossrate', {}, 'shortTimeEnergy', {}, 'pitch', {}, 'artist', {});
audioFiles = {'best_I_ever_had.wav','both.wav','gods_plan.wav','hotline_bling.wav','Jumpman.wav','money_in_the_grave.wav','nice_for_what.wav','one_dance.wav','wants_and_needs.wav','the_motto.wav', ...
            'swift_all_too_well.wav', 'swift_anti_hero.wav', 'swift_bad_blood.wav', 'swift_blank_space.wav', 'swift_love_story.wav', 'swift_out_of_the_woods.wav', 'swift_shake_it_off.wav', 'swift_style.wav', 'swift_wildest_dreams.wav', 'swift_you_belong_with_me.wav' ...
            'Beyonce_7_11.wav', 'Beyonce_Best Thing I Never Had.wav', 'Beyonce_Countdown.wav', 'Beyonce_Formation.wav', 'Beyonce_Halo.wav', 'Beyonce_If I Were A Boy.wav', 'Beyonce_Love On Top.wav', 'Beyonce_Pretty Hurts.wav', 'Beyonce_Single Ladies.wav', 'Beyonce_Sorry.wav' ...
            'Pitbull - Dont Stop the Party.wav','Pitbull - Feel This Moment.wav', 'Pitbull - Fireball.wav', 'Pitbull - Give Me Everything (Lyrics) Ft. Ne-Yo, Afrojack, Nayer.wav', 'Pitbull - Hotel Room Service.wav', 'Pitbull - I Like It Lyrics.wav', 'Pitbull - International Love .wav', 'Pitbull - On The Floor.wav', 'Pitbull - Timber.wav', 'Pitbull - Time of Our Lives.wav'};

numSongs = length(audioFiles);

%Process each audio file
for i = 1:numSongs
    %Load the audio file
    [y, fs] = audioread(audioFiles{i});
    
    %Extract MFCCs
    windowLength = round(0.03*fs);
    overlapLength = round(0.025*fs);
    
    afe = audioFeatureExtractor(SampleRate=fs, Window=hamming(windowLength,"periodic"), OverlapLength=overlapLength, ...
    zerocrossrate=true,shortTimeEnergy=true,pitch=true,mfcc=true);

    allFeatures = extract(afe, y);
    index = info(afe);

    % Extract only MFCC, pitch, zerocross, and shortTimeEnergy features
    MFCCs = mean(allFeatures(:,index.mfcc),1);
    song_pitch = mean(allFeatures(:,index.pitch),1);
    zerocross = mean(allFeatures(:,index.zerocrossrate),1);
    shortTimeEn = mean(allFeatures(:,index.shortTimeEnergy),1);
    
    
    if(i <= 10)
        artist = 'Drake';
    elseif(i > 10 & i <= 20)
        artist = 'Taylor Swift';
    elseif(i > 20 & i <= 30)
        artist = 'Beyonce';
    else
        artist = 'Pitbull';
    end

    %Store the MFCCs, filename, and artist in the database
    entry = struct('filename', audioFiles{i}, 'MFCC', MFCCs, 'zerocrossrate', zerocross, 'shortTimeEnergy', shortTimeEn, 'pitch', song_pitch, 'artist', artist);
    
    database = [database, entry];
end

% Run decision tree classifier
decision_tree_v3_MFCC(database);
