Welcome to the Cepstrum repository

This is a sample application which aim is to transform a signal by modifying its Cepstrum.
The Cepstrum is the iFFT of the natural Log of the FFT of the original signal. The Cepstrum is complex.

The original signal in this project is a decreasing sinus to which echos are applied. The aim of this project is to eliminate
the echos:
the original signal is to be considered as a decreasing sinus convoluted by some diracs. The FFT will transform the convolution to
a multiplication of the spectrums. The Cepstrum, being a Log, will tansform the multiplcation into an addition. The Cepstrum
domain is a kind of time domain called quefrency domain. A filter in the spectrum domain is called a lifter in the quefrency
domain. By lifting the echos (kind of high quefrency lifter), it should be possible to reconstruct the original decreasing
sinus which is what I am trying do achieve. 

I am looking for some help to achieve this.

The application have yet:
the original signal construction
some displays
a delay slider which helps to move the time when the echo(s) occur(s)
a lifter slider which apply the lifter filter base on the value

at the launch of the project, there is no echo (delay slider is set to 0) and the lifter is at its maximum value which mean the
that the Cepstrum is not modified. Therefore, by reconstruction (which does not work yet), the modified signal should be the
same as the input data.

Please help if you find this project interesting for you

Patrick

here are some screenshots

![Alt text](https://github.com/PatrickMuringer/Cepstrum/blob/master/Cepstrum/images/signal.png?raw=true "Original Signal")

![Alt text](https://github.com/PatrickMuringer/Cepstrum/blob/master/Cepstrum/images/app%20startup.png?raw=true "Startup of the project")

![Alt text](https://github.com/PatrickMuringer/Cepstrum/blob/master/Cepstrum/images/app%20startup%20with%20echo.png?raw=true "When adding echo")

