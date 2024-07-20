% 输出：各亚种群的占优分数,评估集合最优前沿的个体      输入：评价集合、非支配排序的参数、亚种群数目、调节因子 
function  [DS, best, NF] = PopSort(estimatePop, params, popQuantity, alphaK)   
    params.nPop = length(estimatePop);
    [estimatePop, F, ~] = SortAndSelectPopulation(estimatePop, params);
    NF = length(F);
	DS = zeros(1, popQuantity);     % 亚种群的占优分数
	NO = zeros(1, length(F));       % 非支配层中个体的数目
    ND = zeros(popQuantity, length(F)); % 横代表第几个亚种群，列代表亚种群在第几个非支配层的个数
    for i = 1 : NF                  % i表示支配层的等级，j表示第i个支配层中的个体序号
        NO(i) = length(F{i});
        for j = 1 : NO(i)
            ND(estimatePop(F{i}(j)).PopNum, i) = ND(estimatePop(F{i}(j)).PopNum, i) + 1;
        end
    end
    for i = 1 : popQuantity
        for k = 1 : NF
            DS(i) = DS(i) + ND(i, k) * alphaK^(NF - k) / NO(k);
        end
    end
    DS = log(DS + 1) / log(alphaK);
    best = estimatePop(F{1});
end