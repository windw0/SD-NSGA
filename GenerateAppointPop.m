% ����ָ�������Ⱥ��     �������Ⱥ��  ���룺�����������������ڵ���Ⱥ��š��ո���Ľṹ��ָ���ı��뼯�ϡ����ڼ�������Ӧ��ֵ�Ĳ���
function AppointNewPop = GenerateAppointPop(nPop, popNum, empty_individual, order, info)
    AppointNewPop = repmat(empty_individual, nPop, 1);
    for i = 1 : nPop
        individual = empty_individual;
        individual.Order = order(i, 1 : length(order) / 2);     % ָ������
        individual.SupplyOrder = order(i, length(order) / 2 + 1 : end);
        individual.Cost = GSSP_MOP2(individual.Order, individual.SupplyOrder, info);
        individual.PopNum = popNum;
        AppointNewPop(i) = individual;
    end
end
         