[y1, Fs1] = audioread("Pitbull - Timber.wav");
[y2, Fs2] = audioread("Pitbull - Dont Stop the Party.wav");

% Read the third WAV file
[y3, Fs3] = audioread("Pitbull - Feel This Moment.wav");

% Read the fourth WAV file
[y4, Fs4] = audioread("Pitbull - Hotel Room Service.wav");

% Read the fifth WAV file
[y5, Fs5] = audioread("Pitbull - On The Floor.wav");

% Check if sample rates match with the third file
if Fs3 ~= Fs1
    y3_resampled = resample(y3, commonFs, Fs3);
else
    y3_resampled = y3;
end

% Check if sample rates match with the fourth file
if Fs4 ~= Fs1
    y4_resampled = resample(y4, commonFs, Fs4);
else
    y4_resampled = y4;
end

% Check if sample rates match with the fifth file
if Fs5 ~= Fs1
    y5_resampled = resample(y5, commonFs, Fs5);
else
    y5_resampled = y5;
end

% Concatenate the audio data
y_combined = [y1_resampled; y2_resampled; y3_resampled; y4_resampled; y5_resampled];

% Time vector for the concatenated signal
t_combined = (0:length(y_combined)-1) / commonFs;

% Apply FFT to the concatenated signal
N = length(y_combined);
frequencies = linspace(0, commonFs, N);
y_combined_fft = fft(y_combined);

% Plot the magnitude spectrum
figure(1);
plot(frequencies, abs(y_combined_fft));
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Frequency Spectrum of Pitbull');
axis([0 2000 0 50000]);

