% ��ȡ��������Ⱥ������Ⱥ���еı������Ӧ��ֵ
function [F_f, F_s] = GetDivPopBest(estimBestPop, popDivNum)
	F_f = cell(1, popDivNum);   % ��Ӧ��ֵ
    F_s = cell(1, popDivNum);   % ��
	a = ones(1, popDivNum); % ��¼���ʱ�ı��,a(i)����һ�ε�i������Ⱥ��ŵ��к�
	for i = 1 : length(estimBestPop)
       F_s{estimBestPop(i).PopNum}(a(estimBestPop(i).PopNum), :) = [estimBestPop(i).Order estimBestPop(i).SupplyOrder];
       F_f{estimBestPop(i).PopNum}(a(estimBestPop(i).PopNum), :) = estimBestPop(i).Cost';
       a(estimBestPop(i).PopNum) = a(estimBestPop(i).PopNum) + 1;
	end
end