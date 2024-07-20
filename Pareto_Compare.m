%% 判断两个帕累托前沿是否相等
function judge = Pareto_Compare(a,b)
    judge = true;
    a_wait_comp_order = zeros(length(a),length(a(1).Order));
    b_wait_comp_order = zeros(length(b),length(b(1).Order));
    for i = 1 : length(a)
        a_wait_comp_order(i,:) = a(i).Order;    % a中所有群体的编码
    end
    for i = 1 : length(b)
        b_wait_comp_order(i,:) = b(i).Order;    % b中所有群体的编码
    end
    
    [c,~,~] = unique(a_wait_comp_order,'rows');
    [d,~,~] = unique(b_wait_comp_order,'rows');
    if ~isequal(c,d)
        judge = false;
    end       
%         for i = 1 : numel(a)
% %           if (~isequal(a(i).Order,b(i).Order) || ~isequal(a(i).Cost, b(i).Cost))
%             编码不同，但是结果相同，7-5-8-10、7-8-5-10
%             if ~isequal(a(i).Cost, b(i).Cost)
%             只有两种解，但数量不同
end