[y,fs1]=audioread('wildest_dreams_instr.wav'); % This will give you audio samples is y (It should be in row vector).
[x,fs] = audioread('wildest_dreams.wav');
x = x./max(max(x));
y = y./max(max(y));
% sound(x,fs);
% sound(y,fs);
% z = x-y;
% sound(z,fs);
% sound(y,fs);
% y3 = y.*-1;
y1 = fft(y);
x1 = fft(x);
[numRows,numCols] = size(y1);
mag = abs(y1);
theta = angle(y1);
for i=1:numRows
    for j=1:numCols
%     if theta(1,j) >= pi/2
%         theta(1,j) = theta(1,j)-(pi/2);
%     else
%         theta(1,j) = theta(1,j)+(pi/2);
%     end
        y1(i,j) = y1(i,j).*-1;
    end
end
z = x1+y1;
% FreqDomain = mag.*exp(1i.*theta);
z1 = ifft(z);
% y3 = y+y2;
% sound(y3,fs);
% g = zeros([120582,2]);
% y2 = [y2;g];
% [x,fs1] = audioread('best_I_ever_had_2.wav');
% x = x./max(max(x));
% y2 = y2./max(max(y2));
% x = normalize(x);
% y2 = normalize(y2);
% z = x+y2;
% plot(x);
% hold on;
% plot(y2);
% sound(z,fs); % Now, lest listen to your reverse audio.
% sound(y2,fs);
% sound(x,fs);
sound(z1,fs);