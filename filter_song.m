% Specify the path to your snare drum audio file
filePath = 'best_I_ever_had_2.wav';

% Read the audio file
[y, Fs] = audioread(filePath);

% Perform FFT to find the frequency content
N = length(y); % Length of the signal
frequencies = (0:N-1) * Fs / N; % Frequency axis

% Compute the FFT
Y = fft(y, N);
Y_mag = abs(Y(1:N/2+1)); % Take the magnitude of the positive frequencies

% Find the index of the peak in the frequency spectrum
[~, idx] = max(Y_mag);

% Find the corresponding frequency
fundamentalFrequency = frequencies(idx);

filteredSignal = filter(testnotch(fundamentalFrequency),y);

audiowrite("filtered_"+filePath,filteredSignal,Fs);
