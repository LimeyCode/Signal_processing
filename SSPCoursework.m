clear all;
%read in audio file
[y, fs] = audioread ('heed_m.wav');

%Choose a segement length
y = y(1000:4000);
subplot(3,4,9);
plot(y);

%listen to read in file
sound(y, fs);

%Find fundemental frequency
f0=pitch(y,fs);

%plot the wav file in Amplitude/dB and in Time
dt = 1/fs;
t = 0:dt:(length(y)*dt)-dt;
subplot(3,4,1);
j = 20*log10(abs(y));

%Plot Amplitude(dB) vs Time of original
plot(t(1:2401),j(1:2401)); xlabel('Seconds'); ylabel('Amplitude(dB)'); title('Amplitude in dB of Original Vowel');

%lpc of wav file
y = y(1:2401);
a = lpc(y,30);
est_y = filter([0-a(2:end)],1,y);
subplot(3,4,4);

%plot LPC and Orginal Amplitude vs Sample
plot(1:2401,y(end-2401+1:end),1:2401,est_y(end-2401+1:end),'--')
grid
xlabel('Sample Number')
ylabel('Amplitude')
title('Original Compared to LPC');
legend('Original signal','LPC estimate')

%Spectrum of Original and LPC 
subplot(3,4,2);
plot(psd(spectrum.periodogram,y,'Fs',fs)); ylabel('Amplitude(dB)');title('Amplitude Spectrum of Orginal and Synthesised');
hold on;
second = plot(psd(spectrum.periodogram,est_y,'Fs',fs));  ylabel('Amplitude(dB)');title('Amplitude Spectrum of Orginal and Synthesised');
second.Color = 'r';
hold off;

% Formant frequencies from matlab help
rt = roots(a);%Find the roots of the LPC
rt = rt(imag(rt)>=0);%Take one of the roots from the pair
ang = atan2(imag(rt),real(rt));%Find the angle for the roots
[freqs,indices] = sort(ang.*(fs/(2*pi)));%change the angular frequency to frequency
bandW = -1/2*(fs/(2*pi))*log(abs(rt(indices)));%the bandwidth is the distance of the predictions from unit circle


%Loop through to find matching critera frequencies
n = 1;
for i = 1:length(freqs)
    if (freqs(i) > 90 && bandW(i) <400)
        formants(n) = freqs(i);
        n = n+1;
    end
end
%print to command window
formants


%fast fourier transform on lpc
Y = fft(est_y);
L = 200;
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:(L/2))/L;
subplot(3,4,3);
plot(f,P1) 
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')

%impulse train
f=92; %fundemental frequency of 227.8Hz
fs=f*22; %sample rate is 10 times larger
t=0:1/fs:1;%1 second in length
n=zeros(size(t));
n(1:fs/f:end)=1;%sample in width
subplot(3,4,5);
plot(t,n);
subplot(3,4,7);
plot(n(1:200)); title('First 200 Samples of Impulse Train');ylabel('Amplitude');xlabel('Sample Number');


%filter the impulse train with LPC a
filtn = filter([0-a(2:end)],1,n);

%Swap values from row to coloumn
filtn = filtn';
t = t';

%plot first 200 samples of the filtered impulse train
subplot(3,4,6);
plot(filtn(1:200));title('First 200 Samples of Filtered Impulse Train');ylabel('Amplitude');xlabel('Sample Number');

%write filtered train to a file and play it
audiowrite('SHeed_m.wav',filtn,fs);
[x, filtn] = audioread('SHeed_m.wav');
sound(x,filtn);

%Frequency reponse of LPC
figure
freqz(a); title('Frequency Response of LPC');



