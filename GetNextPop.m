% 对亚种群进行交叉变异选择操作
function [DivPop, F, paramsdiv] = GetNextPop(popNum, DivPop, paramsdiv, empty_individual, info)
	nPop = paramsdiv.nPop;
    paramsdiv.cross_method = 'PMX'; % 交叉策略先选MPX
    
    filialgeneration = repmat(empty_individual, length(DivPop), 1);  % 初始化 存储子代 的变量
    indivOrder = randperm(length(DivPop));    % 随机组合
    for j = 1 : 2 : length(DivPop) - 1
        A = DivPop(indivOrder(j)).Order;
        ASupply = DivPop(indivOrder(j)).SupplyOrder;
        B = DivPop(indivOrder(j + 1)).Order;
        BSupply = DivPop(indivOrder(j + 1)).SupplyOrder;
        newA = A;
        newASupply = ASupply;
        newB = B;
        newBSupply = BSupply;
        
        % 根据比例更换策略
        if j > paramsdiv.crossOne * nPop && j <= (paramsdiv.crossOne + paramsdiv.crossTwo) * nPop
            paramsdiv.cross_method = 'OX';
        elseif j > (paramsdiv.crossOne + paramsdiv.crossTwo) * nPop
            paramsdiv.cross_method = 'MPX';
        end
        
        % 交叉
        thisProbability = rand(); 
        if thisProbability < paramsdiv.cross
            [newA, newASupply, newB, newBSupply] = Cross(A, ASupply, B, BSupply, paramsdiv.cross_method);
        end
        
        % 变异
        thisProbability = rand();      
        if thisProbability < paramsdiv.variation
            [newA, newASupply, newB, newBSupply] = Variation(newA, newASupply, newB, newBSupply, paramsdiv.variation_method, info);
        end
        
        % 工序修复
        [newA, newASupply]= CorrectAndJudge(newA, newASupply, info.cons_PROCESS);
        [newB, newBSupply]= CorrectAndJudge(newB, newBSupply, info.cons_PROCESS);
        
        % 供应点变异
        thisProbability = rand();
        if thisProbability < paramsdiv.variation
            [newA, newASupply] = VariationSupply(newA, newASupply, info);
            [newB, newBSupply] = VariationSupply(newB, newBSupply, info);
        end

        filialgeneration(j).Order = newA;   % 记录子代的编码
        filialgeneration(j).SupplyOrder = newASupply;
        filialgeneration(j + 1).Order = newB;
        filialgeneration(j + 1).SupplyOrder = newBSupply;
        filialgeneration(j).Cost = GSSP_MOP2(newA, newASupply, info);
        filialgeneration(j + 1).Cost = GSSP_MOP2(newB, newBSupply, info); % 计算子代的适应度值
        filialgeneration(j).PopNum = popNum; % 记录子代所属亚种群编号
        filialgeneration(j + 1).PopNum = popNum; 
    end
    if mod(length(DivPop),2) == 1
        filialgeneration(end) = DivPop(indivOrder(end));
    end
    DivPop = [DivPop
        filialgeneration];      % 合并父代和子代
    [DivPop, F, paramsdiv] = SortAndSelectPopulation(DivPop, paramsdiv); % 非支配排序和选择
end