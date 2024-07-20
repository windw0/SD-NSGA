function [order, SupplyOrder] = CorrectAndJudge(inspected_order, SupplyOrder, constraint)
    order = inspected_order;
    n = length(order);
    for i=1:n-1
        for j=i+1:n
            if constraint(order(i), order(j)) == 0
                tmp = order(i);
                order(i) = order(j);
                order(j) = tmp;
                tmp = SupplyOrder(i);
                SupplyOrder(i) = SupplyOrder(j);
                SupplyOrder(j) = tmp;
            end
        end
    end
end