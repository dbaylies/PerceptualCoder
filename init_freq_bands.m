function [freq_band_top, top_band, z_max] = init_freq_bands(fs, N, fb_per_cb, freq_max)
%samp_freq is sampling frequency
%
%freq_band_top is mapping from bins to Bark
%top_band is top Bark band to code
%z_max is maximum critical band 


% Define bin width
bin_width = fs/N;

% Create vector of values equal to the center of the MDCT/FFT bins
f = linspace(bin_width/2, fs/2-bin_width/2, N/2); %center of bin

% Calculate equivalent Bark values
z = 13*atan(0.76*f/1000)+3.5*atan((f/7500).^2);

%{
% Plot z(f)
if (1)
    figure(1);
    plot(z); grid       
    xlabel('FFT bins');
    ylabel('Bark');         
    pause;
end
%}

% find max bark value rounded to nearest integer (should be 25)
z_max = round(max(z));

% Define number of bands - equal to the number of original bins (25) times
% the number by which each bin is divided (3 - since we're doing one-thrid
% bark bins)
num_bands = z_max*fb_per_cb; % fb_per_cb defined in common.m

% Initialize vector
freq_band_top = zeros(1,num_bands);

% Compute freq_band_top - values in z that are nearest to the 1/fb_per_cb
% divisions of 25-Bark scale
for i=1:num_bands         
    bark_i = i/fb_per_cb;
    % j is the index of the minimum value in the vector
    [~, j] = min(abs(z - bark_i));         
    freq_band_top(i) = j;      
    % j/N2 is the fraction of the max FFT bin, and fs/2 is the frequency
    % represented by the max FFT bin. When multiplied, we obtain the
    % frequency represented by j
    % fprintf('%2d %6.2f %4d %6.0f\n', i, z(j), j, j/N2*fs/2);
end

% Convert inidices to frequencies
freq_band_top_inds = freq_band_top/(N/2)*fs/2;

% Compute index of band in freq_band_top whose corresponding frequency is
% closest to freq_max (from common.m)
[~, top_band] = min(abs(freq_band_top_inds - freq_max));

end

