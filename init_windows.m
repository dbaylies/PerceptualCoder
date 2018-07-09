function windows = init_windows()
%create all windows
%
%windows struct
%windows(1).window

    common;
    output_flags;

    %long window
    w_long = sin(pi*([1:N]-0.5)'/N);
    %short window
    w_short = sin(pi*([1:NS]-0.5)'/NS);

    %start window
    w_start = [w_long(1:N2); ones(N4-NS4, 1); w_short(NS2+1:NS); zeros(N4-NS4,1)];

    %stop window
    w_stop = flipud(w_start);

    %save in struct
    windows(W_LONG)  = struct('window', w_long);
    windows(W_START) = struct('window', w_start);
    windows(W_SHORT) = struct('window', w_short);
    windows(W_STOP)  = struct('window', w_stop);

    %plot windows
    if (op_flg(iwn_idx))
        subplot(1,1,1);
        plot_windows(windows, N, 0, 0.95, 0); %plot all windows
        pause
    end
end