% 求解适应度值，完工时间 和 需求点供应点连续性
function Cost = GSSP_MOP2(Order, SupplyOrder, info)
    n = length(Order);
    demandEndTim = zeros(1, info.ini.num_DEMAND);  % 各需求点当前任务的结束时间
    Cost_tim = 0;   % 一个任务开始的时间（物料放下的时间）
    % 塔吊到达该需求点并放下物料的时间 = max(上一个物料放下的时间 + 到达该物料供应点的时间 + 装货时间 + 供应点到达需求点的时间, 该需求点上一个任务的结束时间） + 卸货时间
    Cost_tim = max(Cost_tim + info.T_noload(SupplyOrder(1), info.ini.tower_init_pos_in_demand) + info.REQUEST(Order(1)).loadTime + info.T_load(SupplyOrder(1), info.REQUEST(Order(1)).demand),...
        demandEndTim(info.REQUEST(Order(1)).demand)) + info.REQUEST(Order(1)).unloadTime;
    % 该需求点的结束时间 = 该需求点任务开始时间 + 任务执行时间
    demandEndTim(info.REQUEST(Order(1)).demand) = Cost_tim + info.REQUEST(Order(1)).time;
    endTim(Order(1)) = demandEndTim(info.REQUEST(Order(1)).demand);
    
    for i = 2 : n
        % 该物料放下的时间（该任务开始的时间） = max(塔吊到达该需求点的时间， 该需求点上一个任务的结束时间) + 该任务的卸货时间
        Cost_tim = max(Cost_tim + info.T_noload(SupplyOrder(i), info.REQUEST(Order(i-1)).demand) + info.REQUEST(Order(i)).loadTime + info.T_load(SupplyOrder(i), info.REQUEST(Order(i)).demand), demandEndTim(info.REQUEST(Order(i)).demand)) + info.REQUEST(Order(i)).unloadTime;	%中间所有任务
        demandEndTim(info.REQUEST(Order(i)).demand) = Cost_tim + info.REQUEST(Order(i)).time;
        endTim(Order(i)) = demandEndTim(info.REQUEST(Order(i)).demand);
    end
    
    makespan = max(endTim); % 完工时间
    
    weight = 2;
    sameLen = 1;
    score = 0;
    for i = 1 : n - 1
        % 需求点及需求物料一样
        if info.REQUEST(Order(i)).demand == info.REQUEST(Order(i + 1)).demand && info.REQUEST(Order(i)).material == info.REQUEST(Order(i + 1)).material
            sameLen = sameLen + 1;
            continue;
        end
        % 得到需求点及物料连续相同的长度后进行处理
        if sameLen ~= 1
            for j = 1 : sameLen
                score = score + 2 + weight ^ j;
            end
            sameLen = 1;
        end
        % 需求点一样但物料不一样
        if info.REQUEST(Order(i)).demand == info.REQUEST(Order(i + 1)).demand
            score = score + 2;
        % 需求点不一样供应点也不一样
        elseif SupplyOrder(i) ~= SupplyOrder(i + 1)
            score = score + 1;
        end
    end
	score = 100000 / score;
    % 输出时要将代价函数的值合并为一个列向量
	Cost = [makespan score]';  
    Cost = roundn(Cost,-8);    % 保留小数点后五位数字，防止由于精度问题导致两个相等的数不等。
end