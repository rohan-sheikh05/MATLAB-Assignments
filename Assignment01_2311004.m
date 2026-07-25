clear; clc; close all;

%% -----------------------------------------------------------------------
%  0. GIVEN DATA
%  -----------------------------------------------------------------------
a_latt    = 2.47;     % lattice parameter a = b                 [Angstrom]
c_latt    = 7.80;     % lattice parameter c                     [Angstrom]
gamma_deg = 120;      % angle between the a and b axes          [deg]
% (Angstrom is fine here: a,c are only ever used to build a UNIT vector,
%  so any common length unit cancels out in the normalization.)

k_sum     = 800;      % kxx + kyy + kzz                         [W/(m.K)]
k_geomean = 225;      % (kxx*kyy*kzz)^(1/3)                     [W/(m.K)]
q_mag     = 3000;     % magnitude of heat flux                  [W/m^2]
uvw       = [2 0 1];  % crystallographic direction of heat flow, [201]

%% -----------------------------------------------------------------------
%  1. SOLVE FOR THE THERMAL CONDUCTIVITY TENSOR COMPONENTS
%  -----------------------------------------------------------------------
%  Graphite is hexagonal, so by Neumann's principle a 2nd-rank property
%  tensor must be symmetric about the unique (c) axis: kxx = kyy != kzz.
%  Let p = kxx = kyy, q = kzz. Then:
%     2p + q = k_sum              ->  q = k_sum - 2p
%     p^2*q  = k_geomean^3        ->  2p^3 - k_sum*p^2 + k_geomean^3 = 0
fprintf('=========================================================\n');
fprintf(' STEP 1: Thermal conductivity tensor components\n');
fprintf('=========================================================\n');

poly_coeffs = [2, -k_sum, 0, k_geomean^3];
r = roots(poly_coeffs);
r_real = r(abs(imag(r)) < 1e-9);           % discard complex roots
q_real = k_sum - 2*r_real;
is_physical = (r_real > 0) & (q_real > 0);  % both components must be positive

p_opts = r_real(is_physical);
q_opts = q_real(is_physical);

fprintf('Mathematically valid (kxx=kyy , kzz) pairs:\n');
for i = 1:length(p_opts)
    fprintf('  Option %d:  kxx=kyy = %8.4f,   kzz = %8.4f  W/(m.K)\n', ...
            i, p_opts(i), q_opts(i));
end

% PHYSICAL SELECTION: in graphite, in-plane covalent bonding conducts
% heat much better than the weak van der Waals bonding along c, so
% kxx = kyy must be the LARGER of the two options.
[kxx, sel] = max(p_opts);
kyy = kxx;
kzz = q_opts(sel);
k_diag = [kxx, kyy, kzz];

fprintf('\nPhysically correct choice (kxx=kyy is the larger root):\n');
fprintf('  kxx = kyy = %.4f W/(m.K)   (in-plane, a-b, strong covalent bonds)\n', kxx);
fprintf('  kzz       = %.4f W/(m.K)   (cross-plane, c, weak van der Waals)\n\n', kzz);

fprintf('Check -> sum = %.4f (target 800), geometric mean = %.4f (target 225)\n\n', ...
        sum(k_diag), prod(k_diag)^(1/3));

%% -----------------------------------------------------------------------
%  2. ROOT-MEAN-SQUARE OF THE NON-ZERO THERMAL CONDUCTIVITIES
%  -----------------------------------------------------------------------
fprintf('=========================================================\n');
fprintf(' STEP 2: RMS of kxx, kyy, kzz\n');
fprintf('=========================================================\n');

k_rms = sqrt(mean(k_diag.^2));
fprintf('RMS = sqrt((kxx^2+kyy^2+kzz^2)/3) = %.4f W/(m.K)\n\n', k_rms);

%% -----------------------------------------------------------------------
%  3. CONVERT THE [201] DIRECTION TO A TRUE CARTESIAN UNIT VECTOR
%  -----------------------------------------------------------------------
%  Because gamma = 120 deg (a and b are NOT orthogonal) and a != c, the
%  Miller-type direction [uvw] must be built from the real lattice
%  vectors -- simply reading (2,0,1) off as an orthogonal Cartesian
%  vector would silently mix a 2.47 A step with a 7.80 A step as if they
%  were equal. Convention used: x || a, z || c (as stated in the prompt).
fprintf('=========================================================\n');
fprintf(' STEP 3: Convert crystallographic [201] to Cartesian\n');
fprintf('=========================================================\n');

gamma = deg2rad(gamma_deg);
a1 = a_latt*[1, 0, 0];                    % lattice vector a, along x
a2 = a_latt*[cos(gamma), sin(gamma), 0];  % lattice vector b, 120 deg from a
a3 = c_latt*[0, 0, 1];                    % lattice vector c, along z

dir_cart = uvw(1)*a1 + uvw(2)*a2 + uvw(3)*a3;   % true real-space vector
n_hat    = dir_cart / norm(dir_cart);           % unit vector [nx ny nz]

fprintf('[201] in real Cartesian space = [%.4f  %.4f  %.4f] Angstrom\n', dir_cart);
fprintf('Unit vector n_hat             = [%.4f  %.4f  %.4f]\n', n_hat);

n_hat_naive = uvw / norm(uvw);
fprintf('\n(For comparison, WRONGLY treating [201] as already Cartesian,\n');
fprintf(' i.e. ignoring that a ~= c, would instead give n_hat = [%.4f %.4f %.4f].\n', ...
        n_hat_naive);
fprintf(' Note b (a2) never enters here anyway, since v = 0 in [201].)\n\n');

%% -----------------------------------------------------------------------
%  4. HEAT FLUX AND TEMPERATURE GRADIENT ALONG [201], FOR |q| = 3000 W/m^2
%  -----------------------------------------------------------------------
fprintf('=========================================================\n');
fprintf(' STEP 4: Temperature gradient driving 3000 W/m^2 along [201]\n');
fprintf('=========================================================\n');

q_vec = q_mag * n_hat;                 % heat flux vector [qx qy qz]

% Fourier's law: q = -K*grad(T). K is diagonal, so this is elementwise:
gradT = -q_vec ./ k_diag;

fprintf('Heat flux vector   q = [%.4f  %.4f  %.4f] W/m^2\n', q_vec);
fprintf('dT/dx = %.4f K/m\n', gradT(1));
fprintf('dT/dy = %.4f K/m\n', gradT(2));
fprintf('dT/dz = %.4f K/m\n', gradT(3));
fprintf('|grad(T)| = %.4f K/m\n', norm(gradT));
fprintf(['Note: grad(T) is NOT parallel to q (or to [201]) -- this is\n' ...
         'expected in an anisotropic medium; the two only stay parallel\n' ...
         'when the flux points along a principal axis (x, y, or z).\n\n']);

%% -----------------------------------------------------------------------
%  5. FIX |q|, VARY ITS DIRECTION: MAXIMUM AND MINIMUM |grad(T)|
%  -----------------------------------------------------------------------
%  |grad(T)|^2 = q0^2*(nx^2/kxx^2 + ny^2/kyy^2 + nz^2/kzz^2).
%  Since kxx = kyy, this depends only on nz (i.e. only on the polar
%  angle from z): the extremes occur exactly along a principal axis.
fprintf('=========================================================\n');
fprintf(' STEP 5: Extrema of |grad(T)| as the flux DIRECTION is varied\n');
fprintf('=========================================================\n');

[k_min, i_min] = min(k_diag);   % smallest conductivity -> largest gradient
[k_max, i_max] = max(k_diag);   % largest conductivity  -> smallest gradient
axis_names = {'x', 'y', 'z'};

gradT_max = q_mag / k_min;
gradT_min = q_mag / k_max;

fprintf('MAXIMUM |grad(T)| = %.4f K/m, when q is along the %s-axis (k = %.4f)\n', ...
        gradT_max, axis_names{i_min}, k_min);
fprintf('MINIMUM |grad(T)| = %.4f K/m, when q is along any direction in the\n', gradT_min);
fprintf('   plane spanned by the axes with equal, larger conductivity (k = %.4f)\n\n', k_max);

% Independent, vectorized (no-loop) brute-force check over the full
% sphere of directions, confirming the analytical extrema above:
theta_full = linspace(0, pi, 181);      % polar angle from z,   0:1:180 deg
phi_full   = linspace(0, 2*pi, 361);    % azimuth from x,       0:1:360 deg
[PH_f, TH_f] = meshgrid(phi_full, theta_full);
NXf = sin(TH_f).*cos(PH_f);  NYf = sin(TH_f).*sin(PH_f);  NZf = cos(TH_f);
magGT_f = sqrt((q_mag*NXf/kxx).^2 + (q_mag*NYf/kyy).^2 + (q_mag*NZf/kzz).^2);
fprintf('Brute-force check over full sphere -> min = %.4f, max = %.4f K/m (matches above)\n\n', ...
        min(magGT_f(:)), max(magGT_f(:)));

fprintf('UNIQUENESS OF DIRECTIONS:\n');
fprintf(['  Maximum-gradient direction (c-axis, +/-z): UNIQUE as an axis --\n' ...
         '  it is the single direction of lowest conductivity.\n']);
fprintf(['  Minimum-gradient direction (the x-y basal plane): NOT unique --\n' ...
         '  because kxx = kyy (hexagonal in-plane isotropy), EVERY direction\n' ...
         '  lying in the basal plane gives the identical minimum gradient,\n' ...
         '  i.e. a whole continuous family (a full plane) of directions.\n\n']);

%% -----------------------------------------------------------------------
%  6. TABLE: |grad(T)| vs ANGLE OF THE HEAT-FLUX VECTOR FROM THE TWO
%     DIRECTIONS FOUND ABOVE (meshgrid of two 6-length vectors, NO loops)
%  -----------------------------------------------------------------------
%  theta = angle from the MAX-gradient direction (the c/z axis)
%  phi   = azimuth within the basal plane, i.e. rotation among the
%          (infinitely many, equivalent) MIN-gradient directions
fprintf('=========================================================\n');
fprintf(' STEP 6: |grad(T)| table vs angle from the max/min directions\n');
fprintf('=========================================================\n');

theta_deg = linspace(0, 90, 6);   % angle from MAX-direction (z-axis)
phi_deg   = linspace(0, 90, 6);   % angle within the MIN-direction (x-y) plane

[PHd, THd] = meshgrid(phi_deg, theta_deg);   % rows ~ theta, cols ~ phi

Nx = sind(THd).*cosd(PHd);
Ny = sind(THd).*sind(PHd);
Nz = cosd(THd);

GTx = -q_mag*Nx/kxx;
GTy = -q_mag*Ny/kyy;
GTz = -q_mag*Nz/kzz;
gradT_table = sqrt(GTx.^2 + GTy.^2 + GTz.^2);      % 6x6, fully vectorized

RowNames = arrayfun(@(t) sprintf('theta_%g', t), theta_deg, 'UniformOutput', false);
ColNames = arrayfun(@(p) sprintf('phi_%g',   p), phi_deg,   'UniformOutput', false);
T = array2table(gradT_table, 'VariableNames', ColNames, 'RowNames', RowNames);

fprintf('|grad(T)| [K/m]  (rows = theta, angle from c-axis/MAX-direction;\n');
fprintf('                  cols = phi,   azimuth in the basal/MIN-direction plane)\n');
disp(T)

fprintf(['Every ROW is constant across phi: rotating the flux direction\n' ...
         'within the basal plane never changes |grad(T)| -- this is the\n' ...
         'numerical confirmation that the minimum-gradient direction is\n' ...
         'NOT unique. Moving down the rows (increasing theta, tilting\n' ...
         'toward the c-axis) steadily raises |grad(T)| from the basal-\n' ...
         'plane minimum (%.4f K/m) up to the c-axis maximum (%.4f K/m).\n\n'], ...
         gradT_table(1,1), gradT_table(end,1));

%% -----------------------------------------------------------------------
%  7. QUICK VISUAL: |grad(T)| vs theta (bonus, confirms phi-independence)
%  -----------------------------------------------------------------------
figure('Name', 'Thermal gradient magnitude vs direction');
theta_fine = linspace(0, 90, 200);
gradT_vs_theta = sqrt((q_mag*sind(theta_fine)/kxx).^2 + (q_mag*cosd(theta_fine)/kzz).^2);
plot(theta_fine, gradT_vs_theta, 'LineWidth', 2);
xlabel('\theta, angle from c-axis / max-gradient direction (deg)');
ylabel('|grad(T)|  (K/m)');
title('|grad(T)| depends only on \theta (basal-plane azimuth \phi is irrelevant)');
grid on;
yline(gradT_min, '--', 'min (basal plane)');
yline(gradT_max, '--', 'max (c-axis)');


