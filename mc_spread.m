function Xs_pow_bands =  mc_spread(Xfft, sf_pow_band, z_max, fb_per_cb, freq_band_top)
% ** This was most annoying to debug... ** (correcting old format)
%    OLD FORMAT: [Xpow_bands, Xs_pow_bands, Xs_pow_bins] =  mc_spread(Xfft, sf_pow_band, z_max, fb_per_cb, freq_band_top)
%Xfft is FFT spectrum from bin 1 to N2 
%sf_pow_band is spread spectrum 
%z_max is maximum critical band 
%freq_band_top is mapping from bins to Bark 
% 
%Xpow_bands is FFT power spectrum on Bark scale 
%Xs_pow_bands is spread power spectrum on Bark scale 
%Xs_pow_bins is spread power spectrum on Hz scale

% Determine number of channels
[~, num_chan] = size(Xfft);

%Convert Xfft to power spectrum
% ** DON'T SQUARE HERE BECAUSE MDCT_CODER.M ALREADY PASSES XPOW_BINS AS AN
% ARGUMENT**
Xpow_bins = Xfft; %abs(Xfft).^2;

% Calculate number of Bark bands
num_bands = length(freq_band_top);

% Initialize Xpow_bands
Xpow_bands = zeros(num_bands, num_chan);

%Xpow_bins is power spectrum from FFT
%Xpow_bands is power spectrum in Bark bands

%fprintf("%i  %i\n",size(Xpow_bands),size(Xpow_bins));
bottom_bin = 1;
for i=1:num_bands
    top_bin = freq_band_top(i);
    for j = 1:num_chan
        Xpow_bands(i, j) = sum(Xpow_bins(bottom_bin:top_bin, j));
    end
    bottom_bin = top_bin + 1;
end

% Add zeros to end of filter input
zero_pad = zeros(z_max*fb_per_cb, num_chan);
Xpow_bands_pad = [Xpow_bands; zero_pad];

% Convolve Bark power spectrum with spreading function sf_pow_band
Xs_pow_bands = filter(sf_pow_band,1,Xpow_bands_pad);

%Remove values from beginning of filter output to align Xpow_bands and
%Xs_pow_bands on frequency scale
Xs_pow_bands = Xs_pow_bands(z_max*fb_per_cb+1:end,:);

%{
% Preallocate Xs_pow_bins
% N2 here isn't accurate - should change with window size. This is probably
% why Schuyler chose not to use the Xs_pow_bins output by this functionm,
% but instead calculate it later in the code.
Xs_pow_bins = zeros(N2,num_chan);

% Evenly distribute power in each Bark band to corresponding bins 
bottom_bin = 1;
for i=1:num_bands
    top_bin = freq_band_top(i);
    for j = 1:num_chan
        Xs_pow_bins(bottom_bin:top_bin, j) = Xs_pow_bands(i,j)/length(Xs_pow_bins(bottom_bin:top_bin,j));
    end
    bottom_bin = top_bin + 1;
end
%}

%{
figure(4);
cb = linspace(1/3, 25, num_bands); 
plot(cb, 10*log10(Xpow_bands(:,j)+realmin), 'b',...
    cb, 10*log10(Xs_pow_bands(:,j)+realmin), 'r');
title("Power and Spread Spectrum on Bark Scale");
xlabel("Bark");
ylabel("dB");
grid on;
legend("Power Spectrum","Spread Spectrum");
%}

end

