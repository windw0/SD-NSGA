% 种群去重函数。   输入：种群、去除标志（可以为编码或者适应度值） 输出：新种群
function newPop = RemoveDuplicate(Pop, flag)
    if strcmp(flag, 'Order')
        allOrder = zeros(length(Pop), 2 * length(Pop(1).Order));
        for i = 1 : length(Pop)
            allOrder(i,:) = [Pop(i).Order Pop(i).SupplyOrder];    % a中所有群体的编码
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