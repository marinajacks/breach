classdef stl_monitor < output_gen

    properties
        P
        Sys
        formula
        formula_id
    end
    methods
        function this = stl_monitor(formula)
            if ischar(formula)
                this.formula= STL_Formula(STL_NewID('phi'), formula);
            elseif isa(formula,'STL_Formula')
                this.formula= formula;    
            else
                error('stl_monitor:bad_constructor_arg', ...
                         'stl_monitor constructor requires a string or STL_Formula as argument.')                  
            end                    
            
            % collect signals and params names
            [this.signals_in, this.params, this.p0] = STL_ExtractSignals(this.formula);
          
            % construct legacy structures
            this.Sys = CreateExternSystem([this.formula_id '_Sys'], this.signals_in, this.params, this.p0);
            this.P = CreateParamSet(this.Sys);
           
            traj.param = zeros(1,numel(this.signals_in)+numel(this.params));
            traj.time = [];
            traj.X = [];
            traj.status = 0;
            
            this.P.traj = {traj};
            this.P.traj_ref = 1;
            this.P.traj_to_compute = [];
           
            % outputs
            this.signals = {get_id(this.formula)};
            
            % Init domains
            for vv =  [this.signals_in this.signals this.params]
                this.domains(vv{1}) = BreachDomain();
            end
            
        end
        
        function [tau, val] = computeSignals(this, time, X, p, tau)
            if ~exist('tau', 'var')||isempty(tau)
                tau = time;
            end
            this.P.traj{1}.X = X;
            this.P.traj{1}.time = time;
            if nargin>=4&&~isempty(p)
                P0 = SetParam(this.P, this.params,p); % really? P0 gets traj removed,..., gotta get rid of all this non-sense one day 
            end
            [val, tau] = STL_Eval(this.Sys, this.formula, P0,this.P.traj{1}, tau);  
        end
   end
end