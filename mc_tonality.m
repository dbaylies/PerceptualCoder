function [SMRbands, SMRbins] = mc_tonality(xw, freq_band_top)
%xw is windowed signal block 
%freq_band_top is mapping from bins to Bark 
% 
%SMRbands is Signal to Mask Ratio on Bark scale 
%SMRbins is Signal to Mask Ration on Hz scale 
% 
%from common.m 
%N2, TMN and NMT

% Define common variables
common;

% Determine number of channels
[~, num_chan] = size(xw);

% Calculate FFT of windowed signal block
% **Don't because FFT was already computed in parent code here
% xw_spect = fft(xw);

% Take only positive FFT values (is this necessary?)
% ** Got rid of this too
% xw_spect_pos = xw_spect(length(xw)/2+1:end,:);

% Calculate power spectrum
% Actually don't because power is already passed in as argument in this
% code
%xw_pow_spect = abs(xw_spect_pos).^2;

% Added this during integration
xw_pow_spect = xw;

% Compute spectral flatness, protecting against division by zero
% **You didn't implement multichannel here**
sfm = zeros(1,num_chan);
for j = 1:num_chan
    if mean(xw_pow_spect(:,j))==0
        sfm(j) = 0;
    else
        sfm(j) = geomean(xw_pow_spect(:,j))/mean(xw_pow_spect(:,j));
    end
end

% Calculate num_bands
num_bands = length(freq_band_top);

% Interpolate signal to mask ratio (SMR)
SMRbands = zeros(num_bands,num_chan);
for j = 1:num_chan
    SMRbands(:,j) = ( (1-sfm(j)).*(TMN) + sfm(j).*NMT )*ones(num_bands, 1);
end

%{
% Print average(guessing here) SMR
for j = 1:num_chan
    fprintf("Channel %i SMR is %.2f\n",j,mean(mean(SMRbands(:,j))));
end
%}

% Convert SMR from Bark to Hz frequency scale
% Evenly distribute power in each Bark band to corresponding bins
SMRbins = zeros(freq_band_top(num_bands),num_chan);
bottom_bin = 1;
for i = 1:num_bands
    top_bin = freq_band_top(i);
    for j = 1:num_chan
        SMRbins(bottom_bin:top_bin,j) = SMRbands(i,j);
    end
    bottom_bin = top_bin + 1;
end

end