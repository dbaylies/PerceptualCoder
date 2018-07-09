function [x_idx, q_bits, x_hat, max_x_idx] = quant_iquant(x, q_stepsize)
% Quantizes a given signal to a given step size
    
    % quantize all values of x to given stepsize (in this case 16-bit PCM)
    x_idx = round(x./q_stepsize);
    
    % find number of channels
    [~, num_chan] = size(x);
    
    %Initialize
    max_x_idx = zeros(num_chan,1);
    q_bits = zeros(num_chan,1);
    
    % find max number of bits needed to represent the signal
    for j = 1:num_chan
        max_x_idx(j) = max(abs(x_idx(:,j)));
        if (max_x_idx(j) > 0)
            q_bits(j) = ceil(log2(max_x_idx(j)) + 1);
        else
            % an all-zero signal only needs one bit
            q_bits(j) = 1;
        end
    end
    
    % inverse quantize to get back original signal, but in digital realm
    x_hat = x_idx.*q_stepsize;
    
end