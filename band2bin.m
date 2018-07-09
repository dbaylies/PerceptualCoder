function X_pow_bins = band2bin(X_pow_bands, freq_band_top, map_mode)
%function X_pow_bins = band2bin(X_pow_bands, freq_band_top, map_mode)
%
%convert power from bands (Bark) to bins (Hz)
%
%X_pow_bands is signal power in Bark bands
%freq_band_top is Bark bands
%if map_mode is
%   0   value in band is equal to value in bin (SMR)
%   1   power in band is distributed over all bins in band
%
%X_pow_bins is signal power in bins

    [~, num_chan] = size(X_pow_bands);
    num_bands = length(freq_band_top);
    num_bins = freq_band_top(end);
    X_pow_bins = zeros(num_bins, num_chan);
    
    for j=1:num_chan
        bottom_bin = 1;
        for i=1:num_bands
            top_bin = freq_band_top(i);
            if (map_mode == 0)
                %assign value to all bins within band
                num_bins = 1; 
            else
                %distribute power across bins within band
                num_bins = top_bin - bottom_bin + 1;
            end
            X_pow_bins(bottom_bin:top_bin, j) = X_pow_bands(i, j)/num_bins;
            bottom_bin = top_bin + 1;
        end
    end
end