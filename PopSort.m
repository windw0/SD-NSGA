% �����������Ⱥ��ռ�ŷ���,������������ǰ�صĸ���      ���룺���ۼ��ϡ���֧������Ĳ���������Ⱥ��Ŀ���������� 
function  [DS, best, NF] = PopSort(estimatePop, params, popQuantity, alphaK)   
    params.nPop = length(estimatePop);
    [estimatePop, F, ~] = SortAndSelectPopulation(estimatePop, params);
    NF = length(F);
	DS = zeros(1, popQuantity);     % ����Ⱥ��ռ�ŷ���
	NO = zeros(1, length(F));       % ��֧����и������Ŀ
    ND = zeros(popQuantity, length(F)); % �����ڼ�������Ⱥ���д�������Ⱥ�ڵڼ�����֧���ĸ���
    for i = 1 : NF                  % i��ʾ֧���ĵȼ���j��ʾ��i��֧����еĸ������
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