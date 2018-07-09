function [flag, onset_idx] = transient_detect(x, hp_b, hp_a)

    common;
    
    %enumerate sets of short segments within input signal x
    short0 = 1:4;   %before short windows
    short1 = 5:8;   %first 4 short windows
    short2 = 9:12;  %last 4 short windows
    short3 = 13:16; %after short windows
    
    flag = 0;
    onset_idx = 0;
    
    % Check RMS value
    rms_x = rms(x);
    long_thres = 100/32768;
    if rms_x < long_thres
        flag = 0;
        onset_idx = 0;
        return;
    end
    
    % Apply high-pass
    x_filt = filter(hp_b, hp_a, x);
    
    % Compute power per 128 samples
    pow = zeros(1,16);
    for i = 0:15
        interval = x_filt(i*128+1:(i+1)*128);
        sum_int = 0;
        for j=1:128
            interval_sq = interval.^2;
            sum_int = sum_int + interval_sq(j);
        end
        pow(i+1) = sum_int/128;
        %alternate method of computing power
        %pow(i+1) = rms(interval)^2;
    end
    
    % Compute average power in each of four sets
    avgpow_0 = sum(pow(short0))/4;
    avgpow_1 = sum(pow(short1))/4;
    avgpow_2 = sum(pow(short2))/4;
    avgpow_3 = sum(pow(short3))/4;
    
    % Compute power ratios
    if avgpow_0 ~= 0
        rat1_0 = avgpow_1/avgpow_0;
    else
        rat1_0 = 0;
    end
    
    if avgpow_1 ~= 0
        rat2_1 = avgpow_2/avgpow_1;
    else
        rat2_1 = 0;
    end
    
    if avgpow_2 ~= 0
        rat3_2 = avgpow_3/avgpow_2;
    else
        rat3_2 = 0;
    end

    % Check threshold
    if (rat1_0 > WIN_HP_THR || rat2_1 > WIN_HP_THR)
        flag = 1;
        onset_idx = find(pow(5:12) == max(pow(5:12)));
    end
    
    
    
end
