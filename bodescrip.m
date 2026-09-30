clear; clc; close all;

k = 2*pi*1e3;

num1 = 1e8 * [1 100*k];
den1 = conv([1 0], conv([1 90*k], [1 140*k]));
G1 = tf(num1, den1);

num2 = 5e13 * [1 85*k];
den2 = conv([1 0], conv([1 110*k], [1 120*k (130*k)^2]));
G2 = tf(num2, den2);

sistemas = {G1, G2};
nombres = {'Ejercicio 1', 'Ejercicio 2'};

f_kHz = [80 85 90 95 98 100 102 105 110 115 120 125 130 135 137.5 140 142.5 145 147.5 150];

for i = 1:2
    G = sistemas{i};
    fprintf('\n=========================================================\n');
    fprintf(' %s\n', nombres{i});
    fprintf('=========================================================\n');

    w = 2*pi*f_kHz*1e3;
    H = squeeze(freqresp(G, w));
    magdB = 20*log10(abs(H));
    fase = rad2deg(unwrap(angle(H)));

    fprintf('%8s %14s %12s %12s\n', 'f (kHz)', 'w (rad/s)', '|G| (dB)', 'Fase (deg)');
    for n = 1:numel(w)
        fprintf('%8.1f %14.1f %12.2f %12.2f\n', f_kHz(n), w(n), magdB(n), fase(n));
    end

    [Gm, Pm, Wcg, Wcp] = margin(G);
    fprintf('---------------------------------------------------------\n');
    if isinf(Gm) || isnan(Wcg)
        fprintf('Cruce de fase (-180): NO existe -> GM = Inf dB\n');
    else
        fprintf('Cruce de fase (-180): w_pc = %.2f rad/s (f = %.3f kHz)\n', Wcg, Wcg/(2*pi)/1e3);
        fprintf('  GM = %.2f dB\n', 20*log10(Gm));
    end
    fprintf('Cruce de ganancia (0 dB): w_gc = %.3f rad/s (f = %.3f Hz)\n', Wcp, Wcp/(2*pi));
    fprintf('  PM = %.2f deg\n', Pm);

    if (isinf(Gm) || 20*log10(Gm) > 0) && Pm > 0
        fprintf('DICTAMEN: sistema en lazo cerrado ESTABLE.\n');
    else
        fprintf('DICTAMEN: sistema en lazo cerrado INESTABLE.\n');
    end

    figure('Name', ['Bode - ' nombres{i}], 'Color', 'w');
    margin(G); 
    grid on;

    figure('Name', ['Bode 80-150 kHz - ' nombres{i}], 'Color', 'w');
    opts = bodeoptions; 
    opts.FreqUnits = 'Hz'; 
    opts.Grid = 'on';
    bode(G, {2*pi*80e3, 2*pi*150e3}, opts);
end