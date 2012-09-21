function Sh = SobolRefine(S, nb)
% QUASIREFINE  Sample quasi-uniformly a parameter set 
% 
% Synopsis:  Ph = QuasiRefine(S, nb)
%  
% Example: 
%
%   CreateSystem;
%   P = CreateSampling(Sys); % Create default parameter set for system Sys
%   Ph = SobolRefine(P, 1000); % Sample with 1000 points
%  
%   SplotBoxPts(P); % Parameter set before sampling 
%   SplotPts(Ph);   % plots the generated points
%
% TODO optionalize the sequence used - so far Sobol
%  
  
  Sh = SobolRefine(S,nb);
  
  X = Sh.pts(1:Sh.DimP,:)'; 
  [C,IA,IC] = unique(X,'rows');
  
  Sh.traj_ref= IC';
  Sh.traj_to_compute = IA';
  
  if (isfield(S,'traj'))     
      Sh.traj = S.traj;
      Sh.Xf = S.Xf;
      if ~isequal(S.pts(1:S.DimP,IA), vertcat(S.traj.param))
          S.traj_to_compute = IA';
      end
  else
      S.traj_to_compute = IA';
  end