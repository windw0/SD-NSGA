% 创建指定编码的群体     输出：新群体  输入：个体数量、个体属于的种群编号、空个体的结构、指定的编码集合、用于计算是适应度值的参数
function AppointNewPop = GenerateAppointPop(nPop, popNum, empty_individual, order, info)
    AppointNewPop = repmat(empty_individual, nPop, 1);
    for i = 1 : nPop
        individual = empty_individual;
        individual.Order = order(i, 1 : length(order) / 2);     % 指定编码
        individual.SupplyOrder = order(i, length(order) / 2 + 1 : end);
        individual.Cost = GSSP_MOP2(individual.Order, individual.SupplyOrder, info);
        individual.PopNum = popNum;
        AppointNewPop(i) = individual;
    end
end
         