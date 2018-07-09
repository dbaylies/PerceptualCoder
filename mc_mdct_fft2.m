function [X, Xfft] = mc_mdct_fft2(x, windows, win_type)
%windows struct
%windows(i).window

    common;
    
    [~, num_chan] = size(x);
    X = zeros(N2, num_chan);
    for i=1:num_chan
        if (win_type ~= W_SHORT)
            %window
            wx = x(:,i).*windows(win_type).window;
            %transform
            [X(:, i), Xfft(:, i)] = mdct_fft2(wx);
        else
            n1 = N4-NS4; %offset to first short window in block
            n2 = 0;
            for j=1:NShort
                %window
                wx = x(n1+1:n1+NS,i).*windows(win_type).window;
                %transform
                [X(n2+1:n2+NS2,i), Xfft(n2+1:n2+NS2,i)] = mdct_fft2(wx);
                %next window's data
                n1 = n1+NS2;
                n2 = n2+NS2;
            end
        end
    end
end
