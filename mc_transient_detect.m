function [win_seq, onset_idx] = mc_transient_detect(x, win_seq)

    %coder parameters
    common;

    [~, num_chan] = size(x);

    %high-pass filter
    persistent hp_b hp_a
    if isempty(hp_b)
        load('hp_filt.mat');
    end

    %detect transients in each channel
    flag = zeros(num_chan,1);
    os_idx = zeros(num_chan, 1);
    for j = 1:num_chan
        [flag(j), os_idx(j)] = transient_detect(x(:,j), hp_b, hp_a);
    end

    %switch if any channel indicates switch
    if (sum(flag) > 0) 
        sw_flag = 1;
        onset_idx = min(os_idx);
    else
        sw_flag = 0;
        onset_idx = 0;
    end

    %allocate next two windows
    switch (win_seq(1)) %current block's window type
        case W_LONG
            if (sw_flag)
                win_seq(2) = W_START; 
                win_seq(3) = W_SHORT;
            else
                win_seq(2) = W_LONG;
                win_seq(3) = W_LONG;
            end
        case W_START
            win_seq(2) = W_SHORT;
            if (sw_flag)
               win_seq(3) = W_SHORT;
            else
               win_seq(3) = W_STOP; 
            end
       case W_SHORT
           if (sw_flag)
               win_seq(2) = W_SHORT; 
               win_seq(3) = W_SHORT; 
           else
               win_seq(2) = W_STOP; 
               win_seq(3) = W_LONG;
           end
        case W_STOP
            if (sw_flag)
                win_seq(2) = W_START;
                win_seq(3) = W_SHORT; 
            else
                win_seq(2) = W_LONG;
            end
    end
%     if (win_seq(2) ~= W_LONG)
%         fprintf('Win type is %d\n', win_seq(2));
%     end
end
