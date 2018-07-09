function [Xmdct, Xfft] = mdct_fft2(x1)

[r,c] = size(x1);
if c>1
    fprintf('Must be Mx1 column vector\n');
    return
end
if mod(r,2) ~= 0
    fprintf('Length of x must be even\n')
end

N = r/2;

tw_1 = exp(-1j*pi/(2*N)*(0:2*N-1)');
tw_2 = exp((-1j*pi/N)*(1/2 + N/2)*((0:N-1)' + 1/2));

x2 = x1.*tw_1;

Xfft = fft(x2);
Xfft = Xfft(1:N);

X3 = Xfft.*tw_2;

Xmdct = real(X3);

