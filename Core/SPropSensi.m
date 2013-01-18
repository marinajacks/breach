function [mu, mustar, sigm] = SPropSensi(Sys, P, phi, opt)
%
% SPROPSENSI estimates the sensitivity of a property wrt some parameters (Morris method)
%
% Synopsis: [mu, mustar, sigm] = SPropSensi(Sys, P, phi, opt)
%
% Input:
%    - P  is a parameter set for Sys. The value of all parameters of P, not
%         in opt.params is defined by the first parameters values in P.
%    - phi is an STL property
%    - opt is an option structure with the following fields :
%
%        - tspan       time domain computation of the trajectories
%        - tprop       time instant (scalar) when to eval prop satisfaction (default tspan(1))
%        - params      variable parameters
%        - lbound      lower bounds for the search domain
%        - ubound      upper bounds for the search domain
%        - p           number of levels (p-grid) (default 4)
%        - k           number of trajectories (default 10)
%        - plot        if 1, plots histograms (default 0)
%        - muGraphOpt      if plot=1, define graphical options for mu graph
%                          (optional)
%        - mustarGraphOpt  if plot=1, graphical options for mu* graph
%                          (optional)
%        - sigmGraphOpt    if plot=1, graphical options for sigm graph
%                          (optional)
%
% Output:
%   - mu      expectation of elementary effects
%   - mustar  expectation of absolute values of elementary effects
%   - sig     variance of elementary effects
%
%  adapted from the strategy described in "Global Sensitivity Analysis, A Primer", Saltelli et al, p113++
%
% Example (Lorentz84):
%   CreateSystem;
%   P = CreateParamSet(Sys);
%   phi = QMITL_Formula('phi','ev (x1[t] > 3)');
%   % P = SetParam(P, {'x1h', 'x1l', 'T'}, [.3, -.3, 5]);
%   % oscil_prop_names = QMITL_ReadFile('oscil_prop.stl');
%   % phi = QMITL_Formula(oscil_prop_names{end});
%   opt.tspan = 2:0.1:5;
%   opt.params = {'a','F'};
%   opt.lbound = [0.15, 5];
%   opt.ubound = [0.35, 25];
%   opt.plot = 1;
%   opt.muGraphOpt = {'XScale','log'};
%   [mu, mustar, sigm] = SPropSensi(Sys, P, phi,  opt);
%
%  See also pRefine, EE_traj, EEffects
%


if isfield(opt, 'tspan')
    tspan = opt.tspan;
elseif isfield(P, 'traj')
    tspan = P.traj(1).time;
elseif isfield(Sys, 'tspan')
    tspan = Sys.tspan;
else
    tspan = 0:.2:10;
end

if isfield(opt, 'tprop')
    tprop = opt.tprop;
else
    tprop = tspan(1);
end

if isfield(opt, 'p')
    p = opt.p;
else
    p = 4;
    opt.p = 4;
end

if ~isfield(opt, 'k')
    opt.k = 10;
end

Sys.p = P.pts(:,1);
Pr = CreateParamSet(Sys, opt.params, [opt.lbound' opt.ubound']);

Pr = pRefine(Pr,opt.p, opt.k);

%NM : we must compute the truth value of phi at time=tprop
if tprop < tspan(1)
    tspan = [tprop,tspan];
%elseif tprop > tspan(end)
%    tspan = [tspan, tprop];
end

Pr = ComputeTraj(Sys, Pr, tspan);

[Pr, Y] = SEvalProp(Sys, Pr, phi, tprop);

[mu, mustar, sigm] = EEffects(Y, Pr.D, p);


if opt.plot
    [Mu, isort] = sort(abs(mu));
    h = figure;
    subplot(3,1,1);
    barh(Mu);
    title('Expectation of elementary effects (mu)')
    set(gca, 'YTick', 1:numel(opt.params), 'YTickLabel', opt.params(isort));
    if isfield(opt,'muGraphOpt')
        set(gca,opt.muGraphOpt{:});
    end
    
    subplot(3,1,2);
    barh(mustar(isort));
    title('Expectation of absolute values of elementary effects (mu*)')
    set(gca, 'YTick', 1:numel(opt.params), 'YTickLabel', opt.params(isort));
    if isfield(opt,'mustarGraphOpt')
        set(gca,opt.mustarGraphOpt{:});
    end
    
    subplot(3,1,3);
    barh(sigm(isort));
    title('Variance of elementary effects (sigm)')
    set(gca, 'YTick', 1:numel(opt.params), 'YTickLabel', opt.params(isort));
    if isfield(opt,'sigmGraphOpt')
        set(gca,opt.sigmGraphOpt{:});
    end
    
    fig_resize(h,1,2.5)
end

end
