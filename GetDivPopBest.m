% 获取各个亚种群在评估群体中的编码和适应度值
function [F_f, F_s] = GetDivPopBest(estimBestPop, popDivNum)
	F_f = cell(1, popDivNum);   % 适应度值
    F_s = cell(1, popDivNum);   % 解
	a = ones(1, popDivNum); % 记录存放时的编号,a(i)即下一次第i个亚种群存放的行号
	for i = 1 : length(estimBestPop)
       F_s{estimBestPop(i).PopNum}(a(estimBestPop(i).PopNum), :) = [estimBestPop(i).Order estimBestPop(i).SupplyOrder];
       F_f{estimBestPop(i).PopNum}(a(estimBestPop(i).PopNum), :) = estimBestPop(i).Cost';
       a(estimBestPop(i).PopNum) = a(estimBestPop(i).PopNum) + 1;
	end
end