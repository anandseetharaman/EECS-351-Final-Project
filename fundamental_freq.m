% Specify the path to your snare drum audio file
filePath = 'hotline_bling.wav';

% Read the audio file
[y, Fs] = audioread(filePath);

% Plot the waveform (optional)
time = (0:length(y)-1) / Fs;
figure;
plot(time, y);
xlabel('Time (seconds)');
ylabel('Amplitude');
title('Snare Drum Audio Waveform');

% Perform FFT to find the frequency content
N = length(y); % Length of the signal
frequencies = (0:N-1) * Fs / N; % Frequency axis

% Compute the FFT
Y = fft(y, N);
Y_mag = abs(Y(1:N/2+1)); % Take the magnitude of the positive frequencies

% Plot the frequency spectrum (optional)
figure;
plot(frequencies(1:N/2+1), 20*log10(Y_mag));
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Frequency Spectrum');

% Find the index of the peak in the frequency spectrum
[~, idx] = max(Y_mag);

% Find the corresponding frequency
fundamentalFrequency = frequencies(idx);

fprintf('Fundamental Frequency: %.2f Hz\n', fundamentalFrequency);