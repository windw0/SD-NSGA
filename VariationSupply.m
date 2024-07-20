% �Թ�Ӧ����죺���ѡ�����㣬�����Ϊ��һ����ȡ��ֵ
function [newOrder, newASupplyOrder] = VariationSupply(Order, SupplyOrder, info)
    global Tem;
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
                if IndexVari == 1
                    dE = info.T_noload(SupplyOrder(1), info.ini.tower_init_pos_in_demand) + info.T_load(SupplyOrder(1), info.REQUEST(Order(1)).demand)...
                        - (info.T_noload(allIndex(radSupIndex(k)), info.ini.tower_init_pos_in_demand) + info.T_load(allIndex(radSupIndex(k)), info.REQUEST(Order(1)).demand));
                    if dE > 0   % �½����
                        cons(SupplyOrder(IndexVari), info.REQUEST(Order(IndexVari)).material) = cons(SupplyOrder(IndexVari), info.REQUEST(Order(IndexVari)).material) + info.REQUEST(Order(IndexVari)).material_quantity;
                        cons(allIndex(radSupIndex(k)), info.REQUEST(Order(IndexVari)).material) = cons(allIndex(radSupIndex(k)), info.REQUEST(Order(IndexVari)).material) - info.REQUEST(Order(IndexVari)).material_quantity;
                        SupplyOrder(IndexVari) = allIndex(radSupIndex(k));
                    else
                        if rand() < exp(dE / Tem)
                            cons(SupplyOrder(IndexVari), info.REQUEST(Order(IndexVari)).material) = cons(SupplyOrder(IndexVari), info.REQUEST(Order(IndexVari)).material) + info.REQUEST(Order(IndexVari)).material_quantity;
                            cons(allIndex(radSupIndex(k)), info.REQUEST(Order(IndexVari)).material) = cons(allIndex(radSupIndex(k)), info.REQUEST(Order(IndexVari)).material) - info.REQUEST(Order(IndexVari)).material_quantity;
                            SupplyOrder(IndexVari) = allIndex(radSupIndex(k));
                        end
                    end
                else 
                    dE = info.T_noload(SupplyOrder(IndexVari), info.REQUEST(Order(IndexVari - 1)).demand) + info.T_load(SupplyOrder(IndexVari), info.REQUEST(Order(IndexVari)).demand)...
                        - (info.T_noload(allIndex(radSupIndex(k)), info.REQUEST(Order(IndexVari - 1)).demand) + info.T_load(allIndex(radSupIndex(k)), info.REQUEST(Order(IndexVari)).demand));
                    if dE > 0
                        cons(SupplyOrder(IndexVari), info.REQUEST(Order(IndexVari)).material) = cons(SupplyOrder(IndexVari), info.REQUEST(Order(IndexVari)).material) + info.REQUEST(Order(IndexVari)).material_quantity;
                        cons(allIndex(radSupIndex(k)), info.REQUEST(Order(IndexVari)).material) = cons(allIndex(radSupIndex(k)), info.REQUEST(Order(IndexVari)).material) - info.REQUEST(Order(IndexVari)).material_quantity;
                        SupplyOrder(IndexVari) = allIndex(radSupIndex(k));
                    else
                        if rand() < exp(dE / Tem)
                            cons(SupplyOrder(IndexVari), info.REQUEST(Order(IndexVari)).material) = cons(SupplyOrder(IndexVari), info.REQUEST(Order(IndexVari)).material) + info.REQUEST(Order(IndexVari)).material_quantity;
                            cons(allIndex(radSupIndex(k)), info.REQUEST(Order(IndexVari)).material) = cons(allIndex(radSupIndex(k)), info.REQUEST(Order(IndexVari)).material) - info.REQUEST(Order(IndexVari)).material_quantity;
                            SupplyOrder(IndexVari) = allIndex(radSupIndex(k));
                        end
                    end
                end
                break;
            end
        end
    end
    newASupplyOrder = SupplyOrder;
end