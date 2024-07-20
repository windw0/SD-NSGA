% �Թ�Ӧ����죺���ѡ�����㣬�����Ϊ��һ����ȡ��ֵ
function [newOrder, newASupplyOrder] = VariationSupplyBasic(Order, SupplyOrder, info)
    nVar = length(Order);
    SupVarNum = randi(nVar);    % �������������ĵ�ĸ���
    cons = info.cons_MATERIAL; 
    newOrder = Order;
    newASupplyOrder = SupplyOrder;
    % ���㵱ǰ����Ӧ������ϵ�ʣ����
    for i = 1 : length(Order)
        cons(SupplyOrder(i), info.REQUEST(Order(i)).material) = cons(SupplyOrder(i), info.REQUEST(Order(i)).material) - info.REQUEST(Order(i)).material_quantity;
    end
    
    radIndex = randperm(nVar);  % ������ɱ����˳��
    for j = 1 : SupVarNum
        IndexVari = radIndex(j);    % ѡȡ������λ��
        allIndex = find(cons(:, info.REQUEST(Order(IndexVari)).material) >= info.REQUEST(Order(IndexVari)).material_quantity);
        radSupIndex = randperm(length(allIndex));   % ������ɱ���ʱ�滻�Ĺ�Ӧ��˳��
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