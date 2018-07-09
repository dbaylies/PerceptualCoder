function [x_idx, q_bits, x_hat, max_x_idx] = quant_iquant_pmr(x, q_stepsize)
%quantize using positive-only mid-rise quantizer
%that is, there can be no zero or negative quantized values 
% 
%x is signal to quantize 
%q_stepsize is quantization stepsize 
% 
%x_idx is quantizer indexes 
%q_bits is number of bits needed for quantizer indices 
%x_hat is quantized signal
%max_x_idx is maximum index value

% To get QSS_BITS
common;

% Subtract half-stepsize offset from input
x = x - (q_stepsize/2);

% quantize all values of x to given stepsize
x_idx = round(x./q_stepsize);


% find number of channels
[~, num_chan] = size(x);

% some values will be -1 - push these to 0
% Also push values greater than max to the max value
for j = 1:num_chan
    for i = 1:length(x_idx(:,j))
        if x_idx(i,j) < 0
            x_idx(i,j) = 0;
        elseif x_idx(i,j) > 2^QSS_BITS
            % This did not work. Need code here to prevent clipping!
            % x_idx(i,j) = 2^QSS_BITS;
        end 
    end
end

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

% Add back half-stepsize
x_hat = x_hat + q_stepsize/2;

end

