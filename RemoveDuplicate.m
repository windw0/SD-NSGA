% ��Ⱥȥ�غ�����   ���룺��Ⱥ��ȥ����־������Ϊ���������Ӧ��ֵ�� ���������Ⱥ
function newPop = RemoveDuplicate(Pop, flag)
    if strcmp(flag, 'Order')
        allOrder = zeros(length(Pop), 2 * length(Pop(1).Order));
        for i = 1 : length(Pop)
            allOrder(i,:) = [Pop(i).Order Pop(i).SupplyOrder];    % a������Ⱥ��ı���
        end
        [~, ia, ~] = unique(allOrder, 'rows');
        newPop = Pop(ia);
    elseif strcmp(flag, 'Cost')
        [~, ia, ~] = unique([Pop.Cost]', 'rows');
        newPop = Pop(ia);
    else
        newPop = Pop;
    end
end