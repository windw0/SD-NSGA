% ������Ⱥ���н������ѡ�����
function [DivPop, F, paramsdiv] = GetNextPop(popNum, DivPop, paramsdiv, empty_individual, info)
	nPop = paramsdiv.nPop;
    paramsdiv.cross_method = 'PMX'; % ���������ѡMPX
    
    filialgeneration = repmat(empty_individual, length(DivPop), 1);  % ��ʼ�� �洢�Ӵ� �ı���
    indivOrder = randperm(length(DivPop));    % ������
    for j = 1 : 2 : length(DivPop) - 1
        A = DivPop(indivOrder(j)).Order;
        ASupply = DivPop(indivOrder(j)).SupplyOrder;
        B = DivPop(indivOrder(j + 1)).Order;
        BSupply = DivPop(indivOrder(j + 1)).SupplyOrder;
        newA = A;
        newASupply = ASupply;
        newB = B;
        newBSupply = BSupply;
        
        % ���ݱ�����������
        if j > paramsdiv.crossOne * nPop && j <= (paramsdiv.crossOne + paramsdiv.crossTwo) * nPop
            paramsdiv.cross_method = 'OX';
        elseif j > (paramsdiv.crossOne + paramsdiv.crossTwo) * nPop
            paramsdiv.cross_method = 'MPX';
        end
        
        % ����
        thisProbability = rand(); 
        if thisProbability < paramsdiv.cross
            [newA, newASupply, newB, newBSupply] = Cross(A, ASupply, B, BSupply, paramsdiv.cross_method);
        end
        
        % ����
        thisProbability = rand();      
        if thisProbability < paramsdiv.variation
            [newA, newASupply, newB, newBSupply] = Variation(newA, newASupply, newB, newBSupply, paramsdiv.variation_method, info);
        end
        
        % �����޸�
        [newA, newASupply]= CorrectAndJudge(newA, newASupply, info.cons_PROCESS);
        [newB, newBSupply]= CorrectAndJudge(newB, newBSupply, info.cons_PROCESS);
        
        % ��Ӧ�����
        thisProbability = rand();
        if thisProbability < paramsdiv.variation
            [newA, newASupply] = VariationSupply(newA, newASupply, info);
            [newB, newBSupply] = VariationSupply(newB, newBSupply, info);
        end

        filialgeneration(j).Order = newA;   % ��¼�Ӵ��ı���
        filialgeneration(j).SupplyOrder = newASupply;
        filialgeneration(j + 1).Order = newB;
        filialgeneration(j + 1).SupplyOrder = newBSupply;
        filialgeneration(j).Cost = GSSP_MOP2(newA, newASupply, info);
        filialgeneration(j + 1).Cost = GSSP_MOP2(newB, newBSupply, info); % �����Ӵ�����Ӧ��ֵ
        filialgeneration(j).PopNum = popNum; % ��¼�Ӵ���������Ⱥ���
        filialgeneration(j + 1).PopNum = popNum; 
    end
    if mod(length(DivPop),2) == 1
        filialgeneration(end) = DivPop(indivOrder(end));
    end
    DivPop = [DivPop
        filialgeneration];      % �ϲ��������Ӵ�
    [DivPop, F, paramsdiv] = SortAndSelectPopulation(DivPop, paramsdiv); % ��֧�������ѡ��
end