function [fb, z_max] = LS_init_freq_bands(samp_freq)
%function [fb, z_max] = LS_init_freq_bands(samp_freq)
%
%samp_freq is sampling frequency
%
%fb is structure of Bark frequency band parameters
%bp().freq_band_top
%number of bands in freq_band_top
%bp().num_bands
%Coding upper frequency limit parameter
%bp().top_bin %bin
%bp().top_band %band
%frequency bands per Critial Band
%bp().fb_per_cb
    
    common;
     
    %Long windows: frequency bands as 1/3 critical bands
    [freq_band_top, top_band, z_max] = ...
        init_freq_bands(samp_freq, N, l_fb_per_cb, freq_max);
    %top bin
    top_bin = round(N2*freq_max/(samp_freq/2));
    %save in struct
    fb(L_IDX)  = struct('freq_band_top', freq_band_top, ...
        'num_bands', length(freq_band_top), 'top_band', top_band,...
        'fb_per_cb', l_fb_per_cb, 'top_bin', top_bin);
    
     %Short windows: frequency bands as 1 critical bands
    [freq_band_top, top_band, ~] = ...
        init_freq_bands(samp_freq, NS, s_fb_per_cb, freq_max);
    %top bin
    top_bin = round(NS2*freq_max/(samp_freq/2));
    %save in struct
    fb(S_IDX)  = struct('freq_band_top', freq_band_top, ...
        'num_bands', length(freq_band_top), 'top_band', top_band, ...
        'fb_per_cb', s_fb_per_cb, 'top_bin', top_bin);
    
end
