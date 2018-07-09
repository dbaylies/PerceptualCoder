function [xout, xprev] = mc_imdct_fft2(X, windows, win_type, xprev)
%windows struct
%windows(i).window

    common;
    
    [~, num_chan] = size(X); 
    xout = zeros(N2, num_chan);
    for i=1:num_chan
        if (win_type ~= W_SHORT)
            %long, start, stop windows
            %inverse transform
            x = 2 * imdct_fft2(X(:,i));
            %window
            wx = x.*windows(win_type).window;
            %overlap-add
            if (win_type ~= W_STOP)
                %long or start windows
                xout(:,i) = xprev(:,i) + wx(1:N2);
                %save second half of this block to use next block
                xprev(:,i) = wx(N2+1:N); 
            else
                %stop window
                n1 = N4-NS4; %offset to begining of stop window
                %from previous short block
                xout(1:n1,i) = xprev(1:n1,i);
                %leading "short window" of stop window
                ns = n1+1:n1+NS2;
                xout(ns,i) = xprev(ns,i) + wx(ns);
                %"flat top" of stop window
                ns = n1+NS2+1:N2;
                xout(ns,i) = wx(ns);
                %save second half of this block to use next block
                xprev(:,i) = wx(N2+1:N); 
            end
        else
            %short window
            xoutx = zeros(N, 1);
            n1 = N4-NS4; %offset to first short window in block
            n2 = 0;
            %"flat top" of start window
            xoutx(1:n1) = xprev(1:n1, i);
            %trailing "short window" of start window
            xprev(1:NS2, i) = xprev(n1+1:n1+NS2, i);
            %for each short window
            for j=1:NShort
                %inverse transform
                x = 2 * imdct_fft2(X(n2+1:n2+NS2,i));
                %window
                wx = x.*windows(win_type).window;
                %overlap-add
                xoutx(n1+1:n1+NS2) = xprev(1:NS2, i) + wx(1:NS2);
                xprev(1:NS2, i) = wx(NS2+1:NS);
                n1 = n1+NS2;
                n2 = n2+NS2;
            end
            %output block
            xout(:,i) = xoutx(1:N2);
            %xprev for next stop window
            %fully reconstructed from short block
            ns = 1:N4-NS4;
            xprev(ns,i) = xoutx(N2+ns);
            %last half short window
            ns = N4-NS4+1:N4+NS4;
            xprev(ns, i) = wx(NS2+1:NS);
        end
    end
end
