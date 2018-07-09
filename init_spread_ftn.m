function sf_pow_band = init_spread_ftn(z_max, fb_per_cb)
% z_max is maximum number of Bark bands
%
% sf_pow_band is spreading function as power on Bark scale

% Create vector of Bark values for use with spreading function (masking
% curve)
dz = -z_max:1/fb_per_cb:z_max;

% Calculate spreading function
S = 15.81 + 7.4*(dz+0.474) - 17.5*(1+(dz+0.474).^2).^(1/2);

% Sharpen the function
S_sharp = S * 2;

%{
% Plot the original and sharpened function
figure(2);
hold on;
plot(dz,S);
plot(dz,S_sharp);
xlabel("Bark");
ylabel("dB")
title("Schroeder Spreading Function: 1/3 critical band");
legend("Original","Sharpened");
grid on;
%}

% Convert the spreading function from dB to power
sf_pow_band = 10.^(S_sharp/10); %division by ten gives power instead of magnitude

% normalize sf_pow_band so that the sum of its values is 1.0
sf_pow_band = sf_pow_band/sum(sf_pow_band);

end

