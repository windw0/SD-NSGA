% ���ɹ�Ӧ��ѡ��ı���   ���룺������롢������Ϣ�����ϴ洢Լ��  �������Ӧ��ѡ�����
function supplyOrder = GenerateSupplyOrder(order, REQUEST, cons_MATERIAL)
    n = length(order);
    supplyOrder = zeros(1, n);
    for i = 1 : n
        needMater = REQUEST(order(i)).material;    % �������ϵı��
        needQuanti = REQUEST(order(i)).material_quantity;  % �������ϵ�����
        index = find(cons_MATERIAL(:, needMater) > 0);    % �ҵ���Ÿ����ϵĹ�Ӧ��
        sele = randperm(length(index));     % ����������
        for j = 1 : length(index)
            if cons_MATERIAL(index(sele(j)), needMater) >= needQuanti
                selectIndex = index(sele(j));
                supplyOrder(i) = selectIndex;   % ȷ����Ӧ��
                % ʣ�����ϵ�����
                cons_MATERIAL(index(sele(j)), needMater) = cons_MATERIAL(index(sele(j)), needMater) - needQuanti;
                break;
            end
        end
    end
end