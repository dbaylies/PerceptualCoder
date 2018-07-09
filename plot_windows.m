function plot_windows(windows, N, m, scale, mode)

    common;

    switch (mode) 
        case 0 %plot all windows
            j = 0;
            plot(j+1:j+N, scale*windows(W_LONG).window, 'k'); 
            j = j+N2;
            grid
            title('Window')
            xlabel('Samples')
            ylabel('Amplitude')
            hold on
            plot(j+1:j+N, scale*windows(W_START).window, 'k');
            j = j+N2 + N4-NS4; %offset to first short window
            for i=1:NShort
                plot(j+1:j+NS, scale*windows(W_SHORT).window, 'k');
                j = j+NS2;
            end
            j = 3*N2;
            plot(j+1:j+N, scale*windows(W_STOP).window, 'k');
            j = 4*N2;
            plot(j+1:j+N, scale*windows(W_LONG).window, 'k'); 
            hold off
        case 1 %long in block starting at m
            j=m;
            plot(j+1:j+N, scale*windows(W_LONG).window, 'k');
        case 2 %start in block starting at m
            j=m;
            plot(j+1:j+N, scale*windows(W_START).window, 'k');
        case 3 %short set in block starting at m
            j = m+N4-NS4; %offset to first short window
            for i=1:NShort
                plot(j+1:j+NS, scale*windows(W_SHORT).window, 'k');
                j = j+NS2;
            end
        case 4 %stop in block starting at m
            j=m;%+N4-NS4; %don't need this since win has leading zeros
            plot(j+1:j+N, scale*windows(W_STOP).window, 'k');
        otherwise
            fprintf('ERROR: unknown window plot mode\n');
    end
    grid
end