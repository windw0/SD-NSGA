% 
% Copyright (c) 2016, Mostapha Kalami Heris & Yarpiz (www.yarpiz.com)
% All rights reserved. Please read the "LICENSE" file for license terms.
% 
% Project Code: YPEA126
% Project Title: Non-dominated Sorting Genetic Algorithm III (NSGA-III)
% Publisher: Yarpiz (www.yarpiz.com)
% 
% Implemented by: Mostapha Kalami Heris, PhD (member of Yarpiz Team)
% 
% Cite as:
% Mostapha Kalami Heris, NSGA-III: Non-dominated Sorting Genetic Algorithm, the Third Version �? MATLAB Implementation (URL: https://yarpiz.com/456/ypea126-nsga3), Yarpiz, 2016.
% 
% Contact Info: sm.kalami@gmail.com, info@yarpiz.com
% 
% Base Reference Paper:
% K. Deb and H. Jain, "An Evolutionary Many-Objective Optimization Algorithm 
% Using Reference-Point-Based Nondominated Sorting Approach, Part I: Solving
% Problems With Box Constraints, "
% in IEEE Transactions on Evolutionary Computation, 
% vol. 18, no. 4, pp. 577-601, Aug. 2014.
% 
% Reference Paper URL: http://doi.org/10.1109/TEVC.2013.2281535
% 

function [pop, params] = NormalizePopulation(pop, params)

    params.zmin = UpdateIdealPoint(pop, params.zmin);
    
    fp = [pop.Cost] - repmat(params.zmin, 1, numel(pop));
    
    params = PerformScalarizing(fp, params);
    
    a = FindHyperplaneIntercepts(params.zmax);
    
%     a = a - repmat(params.zmin, 1, numel(pop));
    
    for i = 1:numel(pop)
        pop(i).NormalizedCost = roundn(fp(:, i)./ a, -7);
    end
    
end

function a = FindHyperplaneIntercepts(zmax)

    w = ones(1, size(zmax, 2))/(zmax + 0.000001 * [1 0;0 1]);
    
    a = (1./w)';

end