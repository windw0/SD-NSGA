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

function [pop, F, params] = SortAndSelectPopulation(pop, params)

    [pop, params] = NormalizePopulation(pop, params);   % ��׼����Ⱥ��


    [pop, F] = NonDominatedSorting(pop);    % ��֧������

    
    nPop = params.nPop;
    % ��ѭ������ǰ��һ�������ֱ��return��
    % ��ѭ�����к�Mergeʱpop����������2*nPop�����Ի����½��С�
%     if numel(pop) == nPop
%         return;
%     end
    
    [pop, d] = AssociateToReferencePoint(pop, params); % ��ο��������

    
    % ȷ����ѡ���LastFront���Լ��Ѿ�ѡ��ĸ���newpop
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
    
    % ����Ⱥ��ģС����Ҫѡ��Ĺ�ģʱ
    if ~exist('LastFront','var')
        params.error = params.error + 1;
        return
    end
    
    % ����rho
    nZr = params.nZr;
    rho = zeros(1, nZr);
    for i = 1:numel(newpop)
        rho(newpop(i).AssociatedRef) = rho(newpop(i).AssociatedRef) + 1;
    end
    % 
    
    % �Ӵ�ѡ��ѡ�����
    while true
        
        % ѡ�����ٱ������Ĳο��㣨�˴������⣬�����õ���������Ⱥ�ģ�Ӧ�û�ȡǰl��ǰ�����ϸ���ģ�
        [~, j] = min(rho);  % ����j=��rho�ĵڶ�����������Сֵ����
            % ��~�����Ժ������ص�ĳ��������min(A)������һ����ÿһ������СԪ�ع��ɵ�����������
        
        % ��ȡ��ѡ��ǰ������j�ο��㣨��һ����õĹ����������ٵĲο��㣩�����ĸ���
        AssocitedFromLastFront = [];
        for i = LastFront   % LastFront��һ����������i=��ʾ���ε���LastFront�е�Ԫ�ء�
            if pop(i).AssociatedRef == j
                AssocitedFromLastFront = [AssocitedFromLastFront i]; %#ok
            end
        end
        
        % �����ѡ��ǰ����û����j�ο�������ģ���ɾ���òο��㣨�˴����òο����������ĸ�������Ϊinf��
        % ���Դﵽ���Ƶ�Ч������֮�󲻻��ٿ��Ǵ˲ο��㣩
        if isempty(AssocitedFromLastFront)
            rho(j) = inf;
            continue;
        end
        
        % �����ѡ����Ⱥ�й����òο���ĸ�����Ϊ0�����ȡ����ĸ���ı��,�������ѡһ������
        if rho(j) == 0
            ddj = d(AssocitedFromLastFront, j);
            [~, new_member_ind] = min(ddj);
        else
            new_member_ind = randi(numel(AssocitedFromLastFront));
        end
        
        MemberToAdd = AssocitedFromLastFront(new_member_ind);
        
        % �ڴ�ѡ��ǰ��ȥ���ѱ�ѡ�ĸ���
        LastFront(LastFront == MemberToAdd) = [];
        % ��ѡ�ĸ��������Ⱥ
        newpop = [newpop; pop(MemberToAdd)]; %#ok
        % ����j�ο���ĸ�����1
        rho(j) = rho(j) + 1;
        
        if numel(newpop) >= nPop
            break;
        end
        
    end
    
    [pop, F] = NonDominatedSorting(newpop);
    
end

