function mdct_coder(ifile, quant_mode)
%function mdct_coder(ifile, quant_mode)
%
%mdct analysis/synthesis with 50% overlap that
%   is multi-channel
%   has adaptive block length switching
%
%ifile in input *.wav file
%quant_mode is:
%   0   no quantization
%   1   quantize Thr and MDCT coefs
%
%ofile is ifile_out.wav

    %coder parameters
    common;

    %output flags
    output_flags;
    %set desired output flags
    op_flg = zeros(32,1);
    op_flg(wav_idx) = 1;
    op_flg(qss_idx) = 1;
    op_flg(pss_idx) = 1;
    op_flg(brt_idx) = 1;
    
    %read input file
    if ( ~exist(ifile, 'file') )
        fprintf('File %s not found\n', ifile);
        return
    end
    [s, samp_freq] = audioread(ifile);
    fprintf('Sampling rate is %d\n', samp_freq);
    if ( ~(samp_freq == 44100 || samp_freq == 48000) )
        fprintf('Sampling rate must be 44100 or 48000\n');
        return
    end
    [num_samp, num_chan] = size(s);
    %get additional audio info
    audio_info = audioinfo(ifile);

    %set up for time-aligned output
    n = mod(num_samp, N2);
    %padd with 1 block before
    %padd after to fill to full block plus one more block plus
    %two more block-switching look-ahead blocks
    nla = 2*N2;
    s1 = [zeros(N2,num_chan);s;zeros(N2-n + N2 + nla, num_chan)];
    [num_samp_1, ~] = size(s1);
    num_block = (num_samp_1-N-nla)/N2;

    %output file
    n = length(ifile);
    base = ifile(1:n-4); %remove '.wav' extension 
    ofile = [base,'_out.wav'];

    %
    %initialize parameters
    %
    %create windows
    windows = init_windows();
    
    %frequency band Bark parameters for Long and Short
    %fb is structure for Long and Short
    [fb, z_max] = LS_init_freq_bands(samp_freq);
    
    %spreading function for Long and Short
    %sf is structure for Long and Short
    sf = LS_init_spread_ftn(z_max);
    
    %create threshold of hearing
    %at is structure for Long and Short 
    %comment out next line if you don't use absolute threshold
%     at = LS_init_abs_thr(samp_freq, p0_level_dB, fb);

    %pre-allocate arrays
    win_seq = [W_LONG, 0, 0];
    onset_idx = zeros(1, 3);
    s_out = zeros(num_samp, num_chan); %decoded signal
    yprev = zeros(N2,num_chan); %prev block for overlap-add
    %bit rate arrays (averaged over all channels)
    qb_qss = zeros(num_block, 1); %coef quant step sizes
    qb_coef = zeros(num_block, 1); %coefs
    %initialize input and output sample indexes
    n1 = 0;
    n2 = 0;
    win_seq(1) = W_LONG;
    fprintf('%d blocks\n', num_block);
    for bno = 0:num_block
        %fprintf('block %d window %d\n', bno, win_seq(1));
        if (mod(bno, 50)==0); fprintf('block %d\n', bno); end
        
        %get this block
        x1 = s1(n1+1:n1+N, :);

        %get look ahead for block switching
        x2 = s1(n1+N+1:n1+N+nla, :);
        %detect possible transient in look-ahead buffer
        [win_seq, onset_idx(3)] = mc_transient_detect(x2, win_seq);

        if (op_flg(wav_idx))
            %plot window sequence and waveform
            figure(1)
            subplot(1,1,1);
            plot(1:2*N, [x1;x2], 'b'); 
            hold on
            m = 0;
            for i=1:3
                plot_windows(windows, N, m, 0.9, win_seq(i)); 
                m=m+N2;
            end
            hold off
            grid
            if (win_seq(3) ~= W_SHORT)
                str = sprintf('Waveform for block %d', bno);
            else
                str = sprintf('Waveform for block %d, Onset Index %d',...
                    bno, onset_idx(3));
            end
            title(str)
            ylabel('Amplitude')
            xlabel('Sample')
            v = axis();
            axis([v(1), v(2), -1, 1]);
            pause
        end
        
        %window and compute mdct and FFT
        [X, Xfft] = mc_mdct_fft2(x1, windows, win_seq(1));
        
        %set parameters for short or long block
        if (win_seq(1) == W_SHORT)
            ls_idx = S_IDX; %index for data structures
            num_win = NShort; %number of windows
            Nc = NS2; %number of FFT/MDCT coefs in a window
        else
            ls_idx = L_IDX; %index for data structures
            num_win = 1;  %number of windows
            Nc = N2; %number of FFT/MDCT coefs in a window
        end
        %set Bark frequency band parameters for this window type
        freq_band_top = fb(ls_idx).freq_band_top;
        fb_per_cb = fb(ls_idx).fb_per_cb;
        num_bands = fb(ls_idx).num_bands;
%         top_band = fb(ls_idx).top_band;
        top_bin = fb(ls_idx).top_bin;
        %set spreading function parameters
        sf_pow_band = sf(ls_idx).sf_pow_band;

        k = 0; %MDCT/FFT coef index
        for widx = 1:num_win
            %
            %perceptual model for each window
            %
            %power spectrum
            X_pow_bins = (abs(Xfft(k+1:k+Nc,:))).^2; 
            
            %spread spectrum
            Xs_pow_bands = ...
                mc_spread(X_pow_bins, sf_pow_band, z_max, fb_per_cb,...
                freq_band_top);
            %convert to dB
            Xs_dB_bands = 10*log10(Xs_pow_bands + realmin);
            
            %SMR based on signal tonality and SFM
            SMR_dB_bands = mc_tonality(X_pow_bins, freq_band_top);
            
            %Masked Noise power
            MN_dB_bands = Xs_dB_bands - SMR_dB_bands;
            %amplitude
            MN_mag_bands = 10.^(MN_dB_bands/20);
            
            %MDCT quantization stepsize
            %quantization step fudge factor
            qs_ff = 1.0;%0.5;
            mdct_qs_bands = qs_ff * MN_mag_bands;
       
            %quantize stepsizes using one-sided (positive) mid-riser quant
            [~, ~, mdct_qs_bands_hat, ~] =...
                quant_iquant_pmr(mdct_qs_bands, 1/(2^QSS_BITS));
            if (bno>0); qb_qss(bno) = num_bands*num_chan*QSS_BITS; end
            %expand to bins
            mdct_qs_bins_hat = band2bin(mdct_qs_bands_hat, freq_band_top, 0);
         
            %quantize MDCT coefficients
            [~, q_bits, X_hat(k+1:k+Nc,:), ~] = ...
                quant_iquant(X(k+1:k+Nc,:), mdct_qs_bins_hat);
            %zero bins past top_bin

            %ERROR
            %   X(k+top_bin+1:k+Nc,:) = MIN_SPEC_MAG*ones(Nc-top_bin, num_chan);
            %CORRECT
                X_hat(k+top_bin+1:k+Nc,:) = MIN_SPEC_MAG*ones(Nc-top_bin, num_chan);
            
            %count bits
            if (bno>0); qb_coef(bno) = sum(q_bits)*Nc; end
            
            %
            %diagnostic plots
            %
            %plot stepsize and quantized stepsize
            if (op_flg(qss_idx) && bno > 1)
                figure(2)
                ns = 1:num_bands;
                plot(ns, mdct_qs_bands, 'b', ns, mdct_qs_bands_hat, 'r-x');
                grid;
                xlabel('Band');
                ylabel('Magnitude');
                title('MDCT stepsize');
                pause
            end
            if (op_flg(pss_idx) && bno > 1)
                %only channel 1
                figure(3)
                subplot(num_win,1,widx); 
                fseq = linspace(0, samp_freq/2, Nc)';
                X1 = X(k+1:k+Nc,:);
                Xfft1 = Xfft(k+1:k+Nc,:);
                Xs_pow_bins = band2bin(Xs_pow_bands, freq_band_top, 1);
                MN_pow_bands = 10.^(MN_dB_bands/10);
                MN_pow_bins = band2bin(MN_pow_bands, freq_band_top, 1);
                semilogx(fseq, 20*log10(abs(X1(:,1))+realmin), 'k',...
                    fseq, 20*log10(abs(Xfft1(:,1))+realmin), 'b', ...
                    fseq, 10*log10(Xs_pow_bins(:,1)+realmin), 'm',...
                    fseq, 10*log10(MN_pow_bins(:,1)+realmin), 'r');
                xlabel('Frequency')
                ylabel('dB')
                grid
                if (widx==1)
                    title(['Spectrum for block ', num2str(bno)])
                    legend('MDCT Spectrum', 'Power Spectrum', 'Spread Spectrum', 'Qstepsize',...
                        'Location', 'northeast');
                end
            end
            k = k+Nc; %advance to next window set of coefficients
        end
        if (op_flg(pss_idx) && bno > 1)
            reply = input('CR for more plots, else 0: ');
            if ~isempty(reply)
                op_flg(wav_idx) = 0;
                op_flg(qss_idx) = 0;
                op_flg(pss_idx) = 0;
            end
        end    
       
        %
        %use quantized coefficients (or not)
        %
        if (quant_mode == 0)
            %no quantization
            Y = X;
        else
            %quantize
            Y = X_hat;
        end
 
        %
        %apply inverse mdct, window and overlap-add
        %
        [y, yprev] = mc_imdct_fft2(Y, windows, win_seq(1), yprev);

        if bno > 0
            %save output so it is time-aligned with input
            s_out(n2+1:n2+N2,:) = y;
            %advance output sample counter
            n2 = n2+N2; 
        end

        %advance window state and onset index
        for i=1:2
            win_seq(i) = win_seq(i+1);
            onset_idx(i) = onset_idx(i+1);
        end
        onset_idx(3) = 0;
        %advance input sample counter
        n1 = n1+N2;
    end

    %clip off last fraction of a block in coded output
    s_out = s_out(1:num_samp,:);

    %write out coded result
    audiowrite(ofile, s_out, samp_freq);

    %calcualate SNR
    e = s - s_out;
    spow = sum(s'*s);
    epow = sum(e'*e);
    %fprintf('%f %f',epow, spow);
    snr = 10*log10(spow/epow);
    fprintf('SNR is %f dB\n', snr);

    %calcluate bit rate
    fprintf('Average bits per block for:\n');
    fprintf('  QSS  %8.2f\n', mean(qb_qss));
    fprintf('  Coef %8.2f\n', mean(qb_coef));
    total_qb = sum(qb_qss) + sum(qb_coef);
    bits_sample = total_qb/(num_samp*num_chan);
    bit_rate = bits_sample*samp_freq*num_chan;
    fprintf('Bits per sample: %6.2f, Bit rate: %6.3f kb/s\n',...
        bits_sample, bit_rate/1000 );
    fprintf('Compression ratio: %6.2f\n', audio_info.BitsPerSample/bits_sample);
    
    if (op_flg(brt_idx))
        %plot bit rate over time
        ns = 1:num_block;
        figure(4)
        subplot(2,1,1);
        plot(ns, qb_qss);
        title('QSS Bit Rate');
        ylabel('Bits');
        xlabel('Blocks');
        subplot(2,1,2);
        plot(ns, qb_coef);
        title('Coef Bit Rate');
        ylabel('Bits');
        xlabel('Blocks');
    end
        
    if (op_flg(out_idx))
        %plot original and reconstructed waveform
        figure(5)
        ns = 1:num_samp;
        for i=1:num_chan
            subplot(num_chan, 1, i);
            plot(ns, s(:,i), 'b', ns, s_out(:,i), 'r');
            legend('Original', 'Reconstructed');
            str = sprintf('Channel %d\n', i);
            title(str);
            %title('Analysis/Synthesis for MDCT and 50% overlap')
            ylabel('Amplitude')
            xlabel('Sample')
            grid
        end
        
        figure(6)
        %plot difference waveform
        ns = 1:num_samp;
        for i=1:num_chan
            subplot(num_chan, 1, i);
            plot(ns, s(:,i)-s_out(:,i));
            str = sprintf('Difference: Channel %d\n', i);
            title(str);
            ylabel('Amplitude')
            xlabel('Sample')
            grid
        end
    end
end