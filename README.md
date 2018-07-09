# PerceptualCoder
A Basic perceptial coder for audio compression.

This coder uses several techniques to optimizes its audio compression, including:
-dynamic quantization
-transient detection
-perceptual model

To code an audio file, call mdct_coder(ifile,quantmode), where:
ifile is input *.wav file
quant_mode is:
   0   no quantization
   1   quantize Thr and MDCT coefs
