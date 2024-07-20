function [newA, newAS, newB, newBS] = Variation(A,AS,B,BS,method, info)
    if strcmp(method,'RM') %重置变异
        newA = randperm(length(A));
        newAS = GenerateSupplyOrder(newA, info.REQUEST, info.cons_MATERIAL);
        newB = randperm(length(A));
        newBS = GenerateSupplyOrder(newB, info.REQUEST, info.cons_MATERIAL);
    elseif strcmp(method,'TPM') %两点换位
        % 生成变异的位置
        pos1 = ceil((length(A)-1)*rand());         % -1是为了规避插入原位置
        pos2 = ceil((length(A)-pos1)*rand()+pos1);
        % 进行变异
        newA = swap(pos1, pos2, A);
        newB = swap(pos1, pos2, B);
        newAS = swap(pos1, pos2, AS);
        newBS = swap(pos1, pos2, BS);
    elseif strcmp(method,'PRM') % 倒序变异 随机选两个不同位置之间的基因反过来
        newA = A;
        newB = B;
        newAS = AS;
        newBS = BS;
        APos1 = ceil((length(A)-1)*rand());         % -1是为了规避插入原位置
        APos2 = ceil((length(A)-APos1)*rand()+APos1);
        BPos1 = ceil((length(B)-1)*rand());
        BPos2 = ceil((length(B)-BPos1)*rand()+BPos1);
        newA(APos1:APos2) = A(APos2:-1:APos1);
        newB(BPos1:BPos2) = B(BPos2:-1:BPos1);
        newAS(APos1:APos2) = AS(APos2:-1:APos1);
        newBS(BPos1:BPos2) = BS(BPos2:-1:BPos1);
    elseif strcmp(method,'OIM') % 单点插入变异
        newA = A;
        newB = B;
        newAS = AS;
        newBS = BS;
        APos1 = ceil((length(A)-1)*rand());         % -1是为了规避插入原位置
        APos2 = ceil((length(A)-APos1)*rand()+APos1);
        BPos1 = ceil((length(B)-1)*rand());
        BPos2 = ceil((length(B)-BPos1)*rand()+BPos1);
        tmp1 = A(APos2);
        tmp2 = AS(APos2);
        for i = APos2 - 1 : -1 : APos1
            newA(i+1) = newA(i);
            newAS(i+1) = newAS(i);
        end
        newA(APos1) = tmp1;
        newAS(APos1) = tmp2;

        tmp1 = B(BPos2);
        tmp2 = BS(BPos2);
        for i = BPos2 - 1 : -1 : BPos1
            newB(i+1) = newB(i);
            newBS(i+1) = newBS(i);
        end
        newB(BPos1) = tmp1;              
        newBS(BPos1) = tmp2;
    end

    % 交换函数，两点换位变异中使用
    function newVector = swap(pos1, pos2, vector)
        newVector = vector;
        newVector(pos1) = vector(pos2);
        newVector(pos2) = vector(pos1);
    end
end