%% MME 208 - Assignment 04
clear; clc; close all;

%1. Physical constants & pre-factor C
e0   = 1.602176634e-19;    
eps0 = 8.8541878128e-12; 
NA   = 6.02214076e23;      
a    = 5.6413e-10;         

C = NA*e0^2/(4*pi*eps0*a); % J/mol
C_kJ = C/1000;              % kJ/mol
fprintf('C = N_A*e^2/(4*pi*eps0*a) = %.6f kJ/mol\n', C_kJ);


% 2. Direct cubic-shell summation 
Nmax = 500;                 
S     = zeros(1,Nmax);      
cumS  = zeros(1,Nmax);      
tElap = zeros(1,Nmax);      

tic;
running = 0;
for i = 1:Nmax
    shellSum = 0;
    for j = 0:i
        for k = 0:j
            r2   = i^2 + j^2 + k^2;
            term = (-1)^(i+j+k) / sqrt(r2);

            %  multiplicity (orbit size under 48-fold cube symmetry) -
            if     j==0 && k==0          % vertex (i,0,0)
                w = 6;
            elseif j==i && k==i          % vertex (i,i,i)
                w = 8;
            elseif j==i && k==0          % vertex (i,i,0)
                w = 12;
            elseif k==0                  % edge  k=0
                w = 24;
            elseif j==k                  % edge  j=k
                w = 24;
            elseif j==i                  % edge  j=i
                w = 24;
            else                         % generic interior point
                w = 48;
            end

            shellSum = shellSum + w*term;
        end
    end
    running   = running + shellSum;
    S(i)      = shellSum;
    cumS(i)   = running;
    tElap(i)  = toc;
end

E_series = C_kJ*cumS;                  % running estimate of E_mol, kJ/mol
E_mol    = E_series(end);

fprintf('NaCl: E_mol ~ %.3f kJ/mol after %d shells (%.3f s elapsed)\n', ...
        E_mol, Nmax, tElap(end));


% 3. Fit the upper/lower envelopes (fit + fittype) -
% Split the oscillating series into its two interleaved envelopes
% (odd-i and even-i) and fit each with a power law + offset,
idx      = 1:Nmax;
oddIdx   = idx(mod(idx,2)==1);
evenIdx  = idx(mod(idx,2)==0);

ftPower = fittype(@(A,p,B,x) A*x.^p + B);

[fUp, gUp]  = fit(oddIdx',  E_series(oddIdx)',  ftPower, 'StartPoint', [1,-1,-430]);
[fLo, gLo]  = fit(evenIdx', E_series(evenIdx)', ftPower, 'StartPoint', [-1,-1,-430]);

E_inf = (fUp.B + fLo.B)/2;   % extrapolated converged value (average of the two limits)
fprintf('Extrapolated (converged) E_mol ~ %.3f kJ/mol\n', E_inf);
% Typical output:
% Extrapolated (converged) E_mol ~ -430.29 kJ/mol   (R^2 for both bound fits > 0.99)

%4. Fit the error trend (polyfit, log-log) 
% error(x) = |E_series(x) - E_inf|  ~  A*x^p   (straight line in log-log)
err = abs(E_series - E_inf);
p_err = polyfit(log10(idx), log10(err), 1);      % p_err = [slope, intercept]
slope     = p_err(1);
intercept = p_err(2);
fprintf('Error trend: error(x) ~ %.4g * x^(%.4g)   [kJ/mol]\n', 10^intercept, slope);


%5. Extrapolate shells / time needed for n sig. figs -
digitsBefore = floor(log10(abs(E_inf))) + 1;    % # digits before decimal (=3, since |E|~430)
sigfigs = 2:5;
shellsNeeded = zeros(size(sigfigs));
timeNeeded   = zeros(size(sigfigs));

for n = 1:numel(sigfigs)
    tolE = 0.5*10^(digitsBefore - sigfigs(n));           % kJ/mol tolerance for n sig. figs
    shellsNeeded(n) = (tolE/10^intercept)^(1/slope);      % invert error(x)=tolE

    if shellsNeeded(n) <= Nmax
        timeNeeded(n) = interp1(idx, tElap, shellsNeeded(n));  % interp1: Lecture 5
    else
       
        k = tElap(Nmax)/Nmax^3;
        timeNeeded(n) = k*shellsNeeded(n)^3;
    end

    fprintf(['For %d signf. digit accuracy, ~ %.5g shells needed ' ...
             '(~%.5g s = %.3g hr = %.3g day)\n'], ...
             sigfigs(n), shellsNeeded(n), timeNeeded(n), ...
             timeNeeded(n)/3600, timeNeeded(n)/86400);
end
% Typical output (this run, Nmax = 500):
% For 2 signf. digit accuracy, ~ 27.7 shells needed   (~0.001 s   = 3e-7 hr   = 1.2e-8 day)
% For 3 signf. digit accuracy, ~ 275   shells needed   (~1.0 s     = 3e-4 hr   = 1.2e-5 day)
% For 4 signf. digit accuracy, ~ 2736  shells needed   (~1.0e3 s   = 0.29 hr   = 0.012 day)
% For 5 signf. digit accuracy, ~ 27200 shells needed   (~1.0e6 s   = 281 hr    = 11.7 day)

%% 6. Plot ------
xf = linspace(1, Nmax, 400);
upperCurve = fUp.A*xf.^fUp.p + fUp.B;
lowerCurve = fLo.A*xf.^fLo.p + fLo.B;

figure('Position',[100 100 1100 450]);

subplot(1,2,1);
plot(log10(idx), E_series, ':', 'Color', [0.5 0.5 0.5]); hold on;
plot(log10(xf), upperCurve, 'g--', 'LineWidth', 1.3);
plot(log10(xf), lowerCurve, 'r--', 'LineWidth', 1.3);
yline_val = E_inf*ones(size(xf));
plot(log10(xf), yline_val, 'k-.', 'LineWidth', 1.2);
xlabel('log_{10}(neighbor shells counted, x)');
ylabel('E_{mol} = N_A e^2/(4\pi\epsilon_0 a) \Sigma(-1)^{i+j+k}(i^2+j^2+k^2)^{-1/2}   [kJ/mol]');
title(sprintf('NaCl: E_{mol} ~ %.2f kJ/mol after %d shells', E_mol, Nmax));
legend( 'cumulative sum', ...
        sprintf('upper env: %.4g x^{%.4g}%+.4g', fUp.A, fUp.p, fUp.B), ...
        sprintf('lower env: %.4g x^{%.4g}%+.4g', fLo.A, fLo.p, fLo.B), ...
        sprintf('extrapolated E_\\infty = %.2f kJ/mol', E_inf), ...
        'Location','southeast');
grid on;

subplot(1,2,2);
plot(log10(idx), log10(err), 'mo', 'MarkerSize', 3); hold on;
fitLine = polyval(p_err, log10(idx));
plot(log10(idx), fitLine, 'k-', 'LineWidth', 1.3);
xlabel('log_{10}(neighbor shells, x)');
ylabel('log_{10}(|error|)  [kJ/mol]');
title('Convergence (error) trend');
legend('|E(x) - E_\infty|', ...
       sprintf('fit: log_{10}\\epsilon = %.4g log_{10}x %+.4g  (\\epsilon~x^{%.3g})', ...
               slope, intercept, slope), ...
       'Location','southwest');
grid on;

saveas(gcf, 'take_home_task_figure.png');

%% ---------------- 7. Summary comment block -----------------------------
% RESULTS SUMMARY (example run, Nmax = 500 shells):
%   C (pre-factor)                 : 246.283 kJ/mol
%   E_mol (raw, after 500 shells)  : -430.11 kJ/mol
%   E_mol (extrapolated, N->inf)   : -430.29 kJ/mol
%   Extrapolated dimensionless sum : S(inf) ~ -1.7476  


%   Error decay                    : |error(x)| ~ 0.57 * x^-1  (kJ/mol)
%   Shells needed for 2 sig. figs  : ~28      (~milliseconds)
%   Shells needed for 3 sig. figs  : ~275     (~1 s)
%   Shells needed for 4 sig. figs  : ~2700    (~15-20 min)
%   Shells needed for 5 sig. figs  : ~27000   (~10-12 days)

