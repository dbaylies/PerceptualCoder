function sf = LS_init_spread_ftn(z_max)

    common;
    
    sf(L_IDX)  = struct( 'sf_pow_band', init_spread_ftn(z_max, l_fb_per_cb) );
    sf(S_IDX)  = struct( 'sf_pow_band', init_spread_ftn(z_max, s_fb_per_cb) );
end
