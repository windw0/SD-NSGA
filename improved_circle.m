% 改良圈算法
function no_bad_indiv = improved_circle(empty_individual,Order,SupplyOrder,info)
    for i = 1:length(Order)-1
        for j = i+1:length(Order)
            mid_Order = [Order(1:i-1), Order(j:-1:i), Order(j+1:end)];
            mid_SupplyOrder = [SupplyOrder(1:i-1), SupplyOrder(j:-1:i), SupplyOrder(j+1:end)];
            Cost1 = GSSP_MOP2(mid_Order, mid_SupplyOrder, info);
            Cost2 = GSSP_MOP2(Order, SupplyOrder, info);
            % 任意适应度函数 %
            if sum(Cost1 > Cost2) > 0   % Cost1中有对应位置的值大于Cost2中对应位置的值
                continue;
            elseif sum(Cost1 < Cost2) == 0  % Cost1中没有对应位置的值小于Cost2中对应位置的值
                continue;
            else
                Order = mid_Order;    % mid_individual支配individual，替换掉
                SupplyOrder = mid_SupplyOrder;
            end
        end
    end
    no_bad_indiv = empty_individual;
    no_bad_indiv.Order = Order;
    no_bad_indiv.SupplyOrder = SupplyOrder;
    no_bad_indiv.Cost = GSSP_MOP2(Order, SupplyOrder, info);
end