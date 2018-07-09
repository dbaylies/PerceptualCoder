%common parameters

N = 2048;   %long window length
N2 = N/2;   %coder block length, half window length
N4 = N/4;   %quarter long window
NShort = 8; %number of short windows
NS = N/NShort; %short window length
NS2= NS/2;  %short block length, half short window length
NS4= NS/4;  %quarter short window

Nbins = N2;

W_LONG  = 1;
W_START = 2;
W_SHORT = 3;
W_STOP  = 4;

L_IDX = 1;    %index for long block structure parameters
S_IDX = 2;    %index for short block structure parameters

l_fb_per_cb = 3; %long block freq_bands per critical band
s_fb_per_cb = 1; %short block freq_bands per critical band
freq_max = 18000; %highest frequency to code

WIN_HP_THR = 10; %threshold for window resolution switching

TMN = 15;   %tones masking noise
NMT = 3;    %noise masking tones
SSMR = 20;  %SMR for short blocks

FS_dB = 56; %power of bin centered tone, dB
p0_level_dB = FS_dB - 6*16; %1/2 lsb of 16-bit PCM input

QSS_BITS = 4; %bits for quantization of step sizes

MIN_SPEC_MAG = 10^(-100/20);

