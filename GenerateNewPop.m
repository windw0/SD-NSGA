function NewPop = GenerateNewPop(nPop, popNum, empty_individual, nVar, improved_circle_flag, info)
    NewPop = repmat(empty_individual, nPop, 1);
    for i = 1 : nPop
        individual = empty_individual;
        individual.Order = randperm(nVar);
        individual.SupplyOrder = GenerateSupplyOrder(individual.Order, info.REQUEST, info.cons_MATERIAL);
        individual.Cost = GSSP_MOP2(individual.Order, individual.SupplyOrder, info);
        % ¸ÄÁ¼È¦
        if improved_circle_flag == true
            individual = improved_circle(empty_individual,individual.Order,individual.SupplyOrder,info);
        end
        % ¹¤ÐòÔ¼Êø
        [individual.Order, individual.SupplyOrder] = CorrectAndJudge(individual.Order, individual.SupplyOrder, info.cons_PROCESS);
        individual.Cost = GSSP_MOP2(individual.Order, individual.SupplyOrder, info);
        individual.PopNum = popNum;
        NewPop(i) = individual;
    end
end
        