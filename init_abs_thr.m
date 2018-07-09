function [abs_thr_bin_dB, abs_thr_band_dB] = init_abs_thr(fs, P0_level_dB, freq_band_top, top_band)
%samp_freq is sampling frequency 
%p0_level_dB is noise floor of input signal 
%freq_band_top is mapping from bins to Bark 
%top_band is top freq_band to code 
% 
%abs_thr_bin_dB is absolute threshold in dB on Hz scale 
%abs_thr_band_dB is absolute threshold in dB on Bark scale

% Initialize common variables
common; 

% N2 equally spaced values from 0 to Nyquist
f = linspace(0, fs/2, N2);

% Calculate Absolute Threshold of Hearing function
abs_thr_bin_dB = 3.64*(f/1000).^(-0.8) - 6.5*exp(-0.6*(f/1000-3.3).^2) + (10^(-3))*(f/1000).^4;

% Adjust abs_thr_bin_dB so that the minimum value is equal to the noise floor of the input
% signal
abs_thr_bin_dB = (abs_thr_bin_dB - min(abs_thr_bin_dB)) + P0_level_dB;


bottom_bin = 1;     
for i=1:top_band         
    top_bin = freq_band_top(i);         
    abs_thr_band_dB(i) = min(abs_thr_bin_dB(bottom_bin:top_bin));         
    bottom_bin = top_bin+1;     
end

%{
figure(3);
ns = 1:round(N2*freq_max/(fs/2));         
semilogx(f(ns), abs_thr_bin_dB(ns));
title("Threshold in Quiet");
xlabel("Hz");
ylabel("dB");
grid on;
%}

end

