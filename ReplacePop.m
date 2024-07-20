% 替换种群的函数，用于新陈代谢和生态占位
% 输入：
% 输出：
function [newPop, params] = ReplacePop(params, popNum, empty_individual, nVar, improved_circle_flag, info, F_s, F_sSum)
    newPop = GenerateNewPop(params.nPop,  popNum, empty_individual, nVar, improved_circle_flag, info);
    [newPop, ~, ~] = SortAndSelectPopulation(newPop, params); 
    onlyS = zeros(1, nVar);
    onlySnum = 0;
    for j = 1 : size(F_s, 1)
        cnt = 0;    % 出现的次数
        for k = 1 : size(F_sSum, 1)
            equal_judge = isequal(F_s(j, :), F_sSum(k, :));
            cnt = cnt + equal_judge;
        end
        if cnt == 1
            onlySnum = onlySnum + 1;
            onlyS(onlySnum, :) = F_s(j, :);
        end
    end
    if onlySnum >= 1
        newPop(end - onlySnum + 1 : end) = GenerateAppointPop(onlySnum, popNum, empty_individual, onlyS, info);
    end
    params.di = 1;
    params.dd = 0;
    params.do = 1;
end