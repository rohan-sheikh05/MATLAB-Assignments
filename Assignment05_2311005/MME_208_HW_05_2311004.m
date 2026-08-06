clear; clc; close all;

%SECTION 1: DATA
% Data taken from the given excel file. 
% Column pairs are (True Strain (%), True Stress (MPa)) for each
% heat-treatment condition.

AQ_strain = [0.00899, 0.00899, 0.00899, 0.03838, 0.07044, 0.07044, 0.07044, 0.09983, 0.12922, 0.15861, 0.188, 0.24678, 0.30555, 0.42578, 0.54334, 0.69296, 0.8399, 1.0483, 1.37425, 1.75899, 2.14372, 2.49906, 2.91585, 3.24181, 3.59715, 4.04066, 4.51623, 5.04791, 5.49409, 6.05783, 6.6189, 7.21203, 7.77577, 8.33951, 8.96202, 9.52576, 10.23645, 10.7708, 11.39332, 12.30973, 13.19942];
AQ_stress = [2.08485, 9.91293, 22.5802, 35.24747, 47.77241, 58.87406, 63.57091, 68.41009, 74.67256, 77.80379, 80.93503, 84.06626, 88.90545, 92.03668, 95.16791, 99.86477, 104.70395, 110.96642, 118.7945, 129.89615, 139.43219, 147.26027, 156.79631, 164.62439, 172.45248, 183.55413, 193.09016, 204.04949, 213.58552, 222.97922, 232.51526, 243.47458, 253.01061, 260.8387, 270.37473, 275.07158, 284.60761, 290.87008, 295.56694, 305.10297, 312.93106];

UA_strain = [0.00899, 0.00899, 0.00899, 0.03838, 0.07044, 0.07044, 0.09983, 0.09983, 0.09983, 0.12922, 0.15861, 0.21739, 0.21739, 0.24678, 0.27616, 0.30555, 0.367, 0.367, 0.42578, 0.45517, 0.48456, 0.48456, 0.51395, 0.54334, 0.54334, 0.54334, 0.60212, 0.63151, 0.69296, 0.81051, 0.92807, 1.28341, 1.60937, 1.96738, 2.29334, 2.61929, 2.97463, 3.56776, 4.24906, 4.98913, 5.79066, 6.53073, 7.15325, 7.80516, 8.60668, 9.37614];
UA_stress = [0.51923, 14.75211, 35.24747, 47.77241, 57.30844, 68.41009, 82.50065, 95.16791, 109.4008, 123.63368, 142.56342, 161.49316, 180.4229, 199.35263, 221.41361, 245.04019, 265.67788, 289.30447, 314.49667, 342.96244, 361.89218, 372.99383, 380.82192, 385.51877, 388.65, 391.92357, 395.0548, 396.62042, 398.18604, 399.75165, 402.88289, 410.85331, 413.98454, 421.81263, 426.65181, 432.91428, 437.61113, 447.14716, 454.97525, 464.51128, 470.77375, 475.4706, 483.44102, 486.57225, 491.26911, 494.40034];

PA_strain = [0.00899, 0.00899, 0.03838, 0.07044, 0.09983, 0.15861, 0.21739, 0.24678, 0.30555, 0.33494, 0.39639, 0.42578, 0.48456, 0.54334, 0.60212, 0.63151, 0.6609, 0.69296, 0.69296, 0.72235, 0.75174, 0.81051, 0.92807, 1.07769, 1.28341, 1.55059, 1.87654, 2.2025, 2.55784, 2.88646, 3.32997, 3.59715, 3.98188, 4.36661, 4.75135, 5.16814, 5.61165, 5.96699, 6.29295, 6.6189, 6.85668];
PA_stress = [5.21608, 27.27705, 51.04597, 80.93503, 110.96642, 139.43219, 178.85728, 210.45428, 241.90896, 271.94035, 300.40612, 333.42641, 365.02342, 407.57974, 444.01593, 473.90499, 485.00664, 491.26911, 495.96596, 500.80514, 507.06761, 510.19884, 511.76446, 514.8957, 518.16926, 519.73488, 522.86611, 530.6942, 533.96776, 540.23023, 543.36147, 546.4927, 551.18955, 554.46312, 557.59435, 560.72558, 563.85682, 566.98805, 568.55367, 571.82724, 571.82724];

OA_strain = [0.00899, 0.00899, 0.00899, 0.03838, 0.03838, 0.03838, 0.07044, 0.07044, 0.09983, 0.12922, 0.15861, 0.188, 0.24678, 0.30555, 0.33494, 0.39639, 0.42578, 0.48456, 0.54334, 0.60212, 0.63151, 0.6609, 0.69296, 0.72235, 0.78113, 0.89868, 1.01891, 1.16586, 1.37425, 1.60937, 1.93799, 2.35211, 2.79562, 3.44753, 4.04066, 4.6044, 5.22692, 6.08722, 6.88607, 7.4792];
OA_stress = [5.21608, 17.88335, 32.11623, 41.50994, 51.04597, 60.43968, 69.97571, 87.33983, 104.70395, 123.63368, 148.82589, 177.29166, 202.48387, 234.08087, 263.96993, 300.40612, 330.29518, 361.89218, 406.01412, 440.74236, 451.84401, 456.54087, 464.51128, 470.77375, 472.33937, 473.90499, 475.4706, 477.03622, 478.60184, 481.8754, 489.70349, 494.40034, 502.37076, 510.19884, 518.16926, 521.30049, 527.56296, 535.53338, 537.099, 540.23023];

matNames   = {'As Quenched','Under-aged','Peak-aged','Over-Aged'};
strainData = {AQ_strain, UA_strain, PA_strain, OA_strain};
stressData = {AQ_stress, UA_stress, PA_stress, OA_stress};
nMat = numel(matNames);

%PART 1: Extract properties for each material: 
E_all = zeros(1,nMat); YS_all = zeros(1,nMat); UTS_all = zeros(1,nMat);
Tough_all = zeros(1,nMat); K_all = zeros(1,nMat); n_all = zeros(1,nMat);
Elong_all = zeros(1,nMat); epsYS_all = zeros(1,nMat);

for i = 1:nMat
    [strain_u, stress_u] = dedupData(strainData{i}, stressData{i});
    eps = strain_u/100;      % convert % strain to fraction
    sig = stress_u;          % MPa

    % Young's Modulus E :
    % CURVE FITTING: fit into a straight line 
    % the first 4 (elastic-region) data points will be taken here
    % differentiate that fitted line - for a
    % straight line the derivative is simply its (constant) slope = E.
    pElastic  = polyfit(eps(1:4), sig(1:4), 1);
    dpElastic = polyder(pElastic);
    E = dpElastic(1);

    % UTS :
    [UTS, idxUTS] = max(sig);
    eps_range = eps(1:idxUTS);
    sig_range = sig(1:idxUTS);

    % YS: 0.2% offset method :
    offsetLine = @(e) E.*(e - 0.002);
    curveVal   = @(e) interp1(eps_range, sig_range, e, 'spline');
    objFun     = @(e) (curveVal(e) - offsetLine(e)).^2;
    epsYS = fminbnd(objFun, 0.002 + 1e-6, eps(idxUTS));
    YS = curveVal(epsYS);

    % Toughness :
    % Integration: area under the true stress-strain curve from 0 to UTs
    Tough = trapz(eps_range, sig_range);

    % K and n after yielding, 
    % Curve fitting; fit sigma_T = K*eps_T^n --> log(sigma) = log(K)+n*log(eps)
    % which is a straight line on a log-log plot; use polyfit on the
    % log-transformed post-yield data (from YS to UTS).
    mask = eps >= epsYS & eps <= eps(idxUTS);
    logEps = log(eps(mask));
    logSig = log(sig(mask));
    pKN = polyfit(logEps, logSig, 1);
    n = pKN(1);
    K = exp(pKN(2));

    % Elongation:
    Elong = strain_u(idxUTS);   % in %, strain at UTS 

    E_all(i) = E; YS_all(i) = YS; UTS_all(i) = UTS; Tough_all(i) = Tough;
    K_all(i) = K; n_all(i) = n; Elong_all(i) = Elong; epsYS_all(i) = epsYS;
end

disp('--- Extracted properties (Part 1) ---');
T1 = table(matNames', E_all', YS_all', UTS_all', Tough_all', K_all', n_all', Elong_all', ...
    'VariableNames', {'Material','E_MPa','YS_MPa','UTS_MPa','Toughness_MJm3','K_MPa','n','Elongation_pct'});
disp(T1);

%figure -01:
% Five bar-chart subplots (YS, UTS, Toughness, K, n) - one subplot per
% property, each showing all 4 heat treatments.

figure('Name','Figure 1 - Mechanical Properties by Heat Treatment','Color','w');

subplot(2,3,1);
bar(categorical(matNames), YS_all, 'FaceColor',[0.2 0.5 0.8]);
ylabel('YS (MPa)'); title('Yield Strength (0.2% offset)'); grid on;

subplot(2,3,2);
bar(categorical(matNames), UTS_all, 'FaceColor',[0.8 0.3 0.3]);
ylabel('UTS (MPa)'); title('Ultimate Tensile Strength'); grid on;

subplot(2,3,3);
bar(categorical(matNames), Tough_all, 'FaceColor',[0.3 0.7 0.4]);
ylabel('Toughness (MJ/m^3)'); title('Toughness (\int\sigma_T d\epsilon_T up to UTS)'); grid on;

subplot(2,3,4);
bar(categorical(matNames), K_all, 'FaceColor',[0.6 0.4 0.8]);
ylabel('K (MPa)'); title('Strength Coefficient (post-yield fit)'); grid on;

subplot(2,3,5);
bar(categorical(matNames), n_all, 'FaceColor',[0.9 0.6 0.2]);
ylabel('n (-)'); title('Strain-Hardening Exponent (post-yield fit)'); grid on;

sgtitle('Figure 1: Mechanical Properties of Al AA2198 Alloy (4 heat treatments)');

%PART 2: Log - log pair analysisi:
% Check, on a log-log scale, which pair among (YS,UTS), (YS,Toughness),
% (UTS,Toughness) best follows a straight line (i.e. a power law
% Y = a*X^b). Goodness of fit is measured with R^2 of the log-log
% curve fitting:

pairs = {
    'YS','UTS',       YS_all,    UTS_all;
    'YS','Toughness', YS_all,    Tough_all;
    'UTS','Toughness',UTS_all,   Tough_all
    };

R2_pairs = zeros(1,3);
figure('Name','Figure 2 - Log-Log Property Relationships','Color','w');
for k = 1:3
    xname = pairs{k,1}; yname = pairs{k,2};
    x = pairs{k,3}; y = pairs{k,4};

    % Curve fitting: linear fit of log10(y) vs log10(x)  ->  y = a*x^b
    logx = log10(x); logy = log10(y);
    p = polyfit(logx, logy, 1);
    b = p(1); a = 10^p(2);

    yFit = polyval(p, logx);
    SSres = sum((logy - yFit).^2);
    SStot = sum((logy - mean(logy)).^2);
    R2 = 1 - SSres/SStot;
    R2_pairs(k) = R2;

    subplot(1,3,k);
    loglog(x, y, 'o', 'MarkerFaceColor','b', 'MarkerSize',7); hold on;
    xx = linspace(min(x), max(x), 100);
    yy = a .* xx.^b;
    loglog(xx, yy, 'r-', 'LineWidth', 1.5);
    grid on;
    xlabel(xname); ylabel(yname);
    title(sprintf('%s vs %s (log-log)', xname, yname));
    eqnStr = sprintf('y = %.3g x^{%.3g}\nR^2 = %.4f', a, b, R2);
    text(0.05, 0.90, eqnStr, 'Units','normalized', 'FontSize', 9, ...
        'BackgroundColor','w', 'EdgeColor','k');
    legend({'Data','Power-law fit'}, 'Location','southeast');
end
sgtitle('Figure 2: Which property pair best fits a straight line on log-log scale?');

[~, bestIdx] = max(R2_pairs);
fprintf('\n--- Part 2 conclusion ---\n');
fprintf('R^2 values: YS-UTS = %.4f, YS-Toughness = %.4f, UTS-Toughness = %.4f\n', R2_pairs);
fprintf('Best straight-line fit on log-log scale: %s vs %s (R^2 = %.4f)\n', ...
    pairs{bestIdx,1}, pairs{bestIdx,2}, R2_pairs(bestIdx));


% PART 3: OPTIMUM YS FOR MAXIMUM TOUGHNESS 

[YS_opt, Tough_opt, p_YS_Tough] = polyOptimizeMax(YS_all, Tough_all);
fprintf('\n--- Part 3: optimum YS for maximum toughness ---\n');
fprintf('YS_opt = %.4f MPa  ->  max predicted Toughness = %.4f MJ/m^3\n', YS_opt, Tough_opt);

% Now fit each remaining property (UTS, Elongation, E, K, n) as a
% function of YS, ONE AT A TIME (CURVE FITTING: exact cubic polynomial
% through the 4 data points), then predict ("evaluate") each fit at
% YS_opt.
UTS_pred_YS   = cubicFitEval(YS_all, UTS_all,   YS_opt);
Elong_pred_YS = cubicFitEval(YS_all, Elong_all, YS_opt);
E_pred_YS     = cubicFitEval(YS_all, E_all,     YS_opt);
K_pred_YS     = cubicFitEval(YS_all, K_all,     YS_opt);
n_pred_YS     = cubicFitEval(YS_all, n_all,     YS_opt);

fprintf('Predicted properties at YS_opt:\n');
fprintf('  UTS   = %.4f MPa\n', UTS_pred_YS);
fprintf('  Elong = %.4f %%\n', Elong_pred_YS);
fprintf('  E     = %.4f MPa\n', E_pred_YS);
fprintf('  K     = %.4f MPa\n', K_pred_YS);
fprintf('  n     = %.4f\n', n_pred_YS);

%PART 4a: build the "YS-based" full stress-strain curve (Curve 1):
[eps_curve1, sig_curve1, Tough_curve1] = buildStressStrainCurve( ...
    YS_opt, E_pred_YS, K_pred_YS, n_pred_YS, Elong_pred_YS);

fprintf('Toughness of generated YS-based curve (Curve 1) = %.4f MJ/m^3\n', Tough_curve1);

%PART 4b: repeat the whole process using UTS as independent var :
% "Maximum toughness" curve: same fitting/optimization process as above,
% but now (UTS, Toughness) are the 4 discrete points and UTS is the
% primary independent variable.

[UTS_opt, Tough_opt2, p_UTS_Tough] = polyOptimizeMax(UTS_all, Tough_all);
fprintf('\n--- Part 4b: optimum UTS for maximum toughness ---\n');
fprintf('UTS_opt = %.4f MPa  ->  max predicted Toughness = %.4f MJ/m^3\n', UTS_opt, Tough_opt2);

YS_pred_UTS    = cubicFitEval(UTS_all, YS_all,    UTS_opt);
Elong_pred_UTS = cubicFitEval(UTS_all, Elong_all, UTS_opt);
E_pred_UTS     = cubicFitEval(UTS_all, E_all,     UTS_opt);
K_pred_UTS     = cubicFitEval(UTS_all, K_all,     UTS_opt);
n_pred_UTS     = cubicFitEval(UTS_all, n_all,     UTS_opt);

fprintf('Predicted properties at UTS_opt:\n');
fprintf('  YS    = %.4f MPa\n', YS_pred_UTS);
fprintf('  Elong = %.4f %%\n', Elong_pred_UTS);
fprintf('  E     = %.4f MPa\n', E_pred_UTS);
fprintf('  K     = %.4f MPa\n', K_pred_UTS);
fprintf('  n     = %.4f\n', n_pred_UTS);

[eps_curve2, sig_curve2, Tough_curve2] = buildStressStrainCurve( ...
    YS_pred_UTS, E_pred_UTS, K_pred_UTS, n_pred_UTS, Elong_pred_UTS);

fprintf('Toughness of generated UTS-based curve (Curve 2) = %.4f MJ/m^3\n', Tough_curve2);

%%  FIGURE 3 :
% Plot both hypothetical, fully-continuous stress-strain curves together,
% and annotate each with its (optimization-predicted) maximum toughness.

figure('Name','Figure 3 - Predicted Ideal Stress-Strain Curves','Color','w');
plot(eps_curve1*100, sig_curve1, 'b-', 'LineWidth', 2); hold on;
plot(eps_curve2*100, sig_curve2, 'r--', 'LineWidth', 2);
grid on;
xlabel('True Strain (%)');
ylabel('True Stress (MPa)');
title('Figure 3: Ideal Stress-Strain Curves at Maximum-Toughness Conditions');

legend({ ...
    sprintf('Curve from YS_{opt} = %.1f MPa  (max Toughness = %.2f MJ/m^3)', YS_opt, Tough_opt), ...
    sprintf('Curve from UTS_{opt} = %.1f MPa (max Toughness = %.2f MJ/m^3)', UTS_opt, Tough_opt2) ...
    }, 'Location', 'southeast');

% Explicit annotations on the plot itself
text(eps_curve1(end)*100*0.55, sig_curve1(end)*0.55, ...
    sprintf('YS-based curve\nMax Toughness = %.2f MJ/m^3', Tough_opt), ...
    'Color','b', 'FontWeight','bold', 'BackgroundColor','w');
text(eps_curve2(end)*100*0.55, sig_curve2(end)*0.20, ...
    sprintf('UTS-based curve\nMax Toughness = %.2f MJ/m^3', Tough_opt2), ...
    'Color','r', 'FontWeight','bold', 'BackgroundColor','w');


%LOCAL FUNCTIONS :

function [xu, yu] = dedupData(x, y)
% dedupData - merges duplicate x-values (averaging the corresponding y
% values) so the data become strictly monotonic, as required by
% spline/interp1. (Housekeeping utility; no Lecture-6 method itself.)
    xu = unique(x);
    yu = zeros(size(xu));
    for k = 1:numel(xu)
        yu(k) = mean(y(x == xu(k)));
    end
end

function [xOpt, yOpt, p] = polyOptimizeMax(x, y)

    [xs, order] = sort(x(:)); ys = y(:); ys = ys(order);
    p  = polyfit(xs, ys, 3);        % CURVE FITTING
    dp = polyder(p);                % DIFFERENTIATION (1st derivative)
    crit = roots(dp);
    crit = crit(imag(crit) == 0);   % keep real critical points
    crit = crit(crit >= min(xs) & crit <= max(xs));

    candidates = [crit(:); min(xs); max(xs)];
    vals = polyval(p, candidates);
    [yOpt, idx] = max(vals);
    xOpt = candidates(idx);
end

function yq = cubicFitEval(x, y, xq)
% cubicFitEval - CURVE FITTING: fit a cubic polynomial exactly through
% the 4 given (x,y) data points (one property vs YS or UTS, "one at a
% time") and evaluate ("predict") it at the query point xq.
    [xs, order] = sort(x(:)); ys = y(:); ys = ys(order);
    p = polyfit(xs, ys, 3);
    yq = polyval(p, xq);
end

function [epsCurve, sigCurve, Tough] = buildStressStrainCurve(YSv, Ev, Kv, nv, Elongv)
    epsY  = YSv / Ev;
    eps_e = linspace(0, epsY, 50);
    sig_e = Ev .* eps_e;
    eps_p = linspace(epsY, Elongv/100, 200);
    sig_p = Kv .* eps_p.^nv;

    epsCurve = [eps_e, eps_p(2:end)];
    sigCurve = [sig_e, sig_p(2:end)];
    Tough    = trapz(epsCurve, sigCurve);   % INTEGRATION
end
