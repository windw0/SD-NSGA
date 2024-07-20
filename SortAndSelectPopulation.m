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
% Mostapha Kalami Heris, NSGA-III: Non-dominated Sorting Genetic Algorithm, the Third Version 鈥? MATLAB Implementation (URL: https://yarpiz.com/456/ypea126-nsga3), Yarpiz, 2016.
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

function [pop, F, params] = SortAndSelectPopulation(pop, params)

    [pop, params] = NormalizePopulation(pop, params);   % 标准化种群。


    [pop, F] = NonDominatedSorting(pop);    % 非支配排序。

    
    nPop = params.nPop;
    % 主循环运行前的一次是相等直接return。
    % 主循环运行后到Merge时pop的数量会变成2*nPop，所以会向下进行。
%     if numel(pop) == nPop
%         return;
%     end
    
    [pop, d] = AssociateToReferencePoint(pop, params); % 与参考点关联。

    
    % 确定待选择层LastFront，以及已经选择的个体newpop
    newpop = [];
    for l = 1:numel(F)
        if numel(newpop) + numel(F{l}) > nPop
            LastFront = F{l};
            break;
        end
        newpop = [newpop; pop(F{l})];   %#ok
        if numel(newpop) == nPop
            [pop, F] = NonDominatedSorting(newpop);
            return;
        end
    end
    
    % 当种群规模小于需要选择的规模时
    if ~exist('LastFront','var')
        params.error = params.error + 1;
        return
    end
    
    % 更新rho
    nZr = params.nZr;
    rho = zeros(1, nZr);
    for i = 1:numel(newpop)
        rho(newpop(i).AssociatedRef) = rho(newpop(i).AssociatedRef) + 1;
    end
    % 
    
    % 从待选层选择个体
    while true
        
        % 选择最少被关联的参考点（此处有问题，上面获得的是整个种群的，应该获取前l个前沿面上个体的）
        [~, j] = min(rho);  % 返回j=（rho的第二个参数的最小值）。
            % 【~：忽略函数返回的某个参数。min(A)：返回一个由每一列中最小元素构成的行向量。】
        
        % 获取待选择前沿上与j参考点（上一步获得的关联个体最少的参考点）关联的个体
        AssocitedFromLastFront = [];
        for i = LastFront   % LastFront是一个行向量，i=表示依次等于LastFront中的元素。
            if pop(i).AssociatedRef == j
                AssocitedFromLastFront = [AssocitedFromLastFront i]; %#ok
            end
        end
        
        % 如果待选择前沿上没有与j参考点关联的，则删除该参考点（此处将该参考点关联个体的个数设置为inf，
        % 可以达到类似的效果，即之后不会再考虑此参考点）
        if isempty(AssocitedFromLastFront)
            rho(j) = inf;
            continue;
        end
        
        % 如果以选择种群中关联该参考点的个体数为0，则获取最近的个体的编号,否则，随机选一个个体
        if rho(j) == 0
            ddj = d(AssocitedFromLastFront, j);
            [~, new_member_ind] = min(ddj);
        else
            new_member_ind = randi(numel(AssocitedFromLastFront));
        end
        
        MemberToAdd = AssocitedFromLastFront(new_member_ind);
        
        % 在待选择前沿去掉已被选的个体
        LastFront(LastFront == MemberToAdd) = [];
        % 已选的个体加入种群
        newpop = [newpop; pop(MemberToAdd)]; %#ok
        % 关联j参考点的个数加1
        rho(j) = rho(j) + 1;
        
        if numel(newpop) >= nPop
            break;
        end
        
    end
    
    [pop, F] = NonDominatedSorting(newpop);
    
end

