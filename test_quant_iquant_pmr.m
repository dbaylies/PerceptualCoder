function test_quant_iquant_pmr()

    N = 5;
    x = linspace(0, N, 100);
    qs = 1.0;
    [~, ~, y, ~] =  quant_iquant_pmr(x, qs);
    
    ns = x;
    plot(ns, x, 'b', ns, y, 'r');
    grid
    title('Positive Mid-Rise Quantizer');
    ylabel('Reconstructed Value');
    xlabel('Input value');
end