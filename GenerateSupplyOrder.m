% 生成供应点选择的编码   输入：工序编码、任务信息、物料存储约束  输出：供应点选择编码
function supplyOrder = GenerateSupplyOrder(order, REQUEST, cons_MATERIAL)
    n = length(order);
    supplyOrder = zeros(1, n);
    for i = 1 : n
        needMater = REQUEST(order(i)).material;    % 所需物料的编号
        needQuanti = REQUEST(order(i)).material_quantity;  % 所需物料的数量
        index = find(cons_MATERIAL(:, needMater) > 0);    % 找到存放该物料的供应点
        sele = randperm(length(index));     % 随机生成序号
        for j = 1 : length(index)
            if cons_MATERIAL(index(sele(j)), needMater) >= needQuanti
                selectIndex = index(sele(j));
                supplyOrder(i) = selectIndex;   % 确定供应点
                % 剩余物料的数量
                cons_MATERIAL(index(sele(j)), needMater) = cons_MATERIAL(index(sele(j)), needMater) - needQuanti;
                break;
            end
        end
    end
end