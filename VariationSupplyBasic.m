% 对供应点变异：随机选择变异点，随机变为另一个可取的值
function [newOrder, newASupplyOrder] = VariationSupplyBasic(Order, SupplyOrder, info)
    nVar = length(Order);
    SupVarNum = randi(nVar);    % 随机生成最大变异的点的个数
    cons = info.cons_MATERIAL; 
    newOrder = Order;
    newASupplyOrder = SupplyOrder;
    % 计算当前各供应点各材料的剩余量
    for i = 1 : length(Order)
        cons(SupplyOrder(i), info.REQUEST(Order(i)).material) = cons(SupplyOrder(i), info.REQUEST(Order(i)).material) - info.REQUEST(Order(i)).material_quantity;
    end
    
    radIndex = randperm(nVar);  % 随机生成变异的顺序
    for j = 1 : SupVarNum
        IndexVari = radIndex(j);    % 选取的任务位置
        allIndex = find(cons(:, info.REQUEST(Order(IndexVari)).material) >= info.REQUEST(Order(IndexVari)).material_quantity);
        radSupIndex = randperm(length(allIndex));   % 随机生成变异时替换的供应点顺序
        for k = 1 : length(allIndex)
            if allIndex(radSupIndex(k)) ~= SupplyOrder(IndexVari)
                cons(SupplyOrder(IndexVari), info.REQUEST(Order(IndexVari)).material) = cons(SupplyOrder(IndexVari), info.REQUEST(Order(IndexVari)).material) + info.REQUEST(Order(IndexVari)).material_quantity;
                cons(allIndex(radSupIndex(k)), info.REQUEST(Order(IndexVari)).material) = cons(allIndex(radSupIndex(k)), info.REQUEST(Order(IndexVari)).material) - info.REQUEST(Order(IndexVari)).material_quantity;
                SupplyOrder(IndexVari) = allIndex(radSupIndex(k));
                break;
            end
        end
    end
    newASupplyOrder = SupplyOrder;
end