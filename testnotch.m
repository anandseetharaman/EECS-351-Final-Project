function Hd = testnotch(fund_freq)
%TESTNOTCH Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 9.11 and Signal Processing Toolbox 8.7.
% Generated on: 27-Nov-2023 23:11:01

% Butterworth Bandstop filter designed using FDESIGN.BANDSTOP.

% All frequency values are in Hz.
Fs = 48000;  % Sampling Frequency

Fpass1 = fund_freq - 10;        % First Passband Frequency
Fstop1 = fund_freq - 5;        % First Stopband Frequency
Fstop2 = fund_freq + 5;        % Second Stopband Frequency
Fpass2 = fund_freq + 10;        % Second Passband Frequency
Apass1 = 0.5;         % First Passband Ripple (dB)
Astop  = 60;          % Stopband Attenuation (dB)
Apass2 = 1;           % Second Passband Ripple (dB)
match  = 'stopband';  % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.bandstop(Fpass1, Fstop1, Fstop2, Fpass2, Apass1, Astop, ...
                      Apass2, Fs);
Hd = design(h, 'butter', 'MatchExactly', match);

% [EOF]
