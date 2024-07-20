% �����Ӧ��ֵ���깤ʱ�� �� ����㹩Ӧ��������
function Cost = GSSP_MOP2(Order, SupplyOrder, info)
    n = length(Order);
    demandEndTim = zeros(1, info.ini.num_DEMAND);  % ������㵱ǰ����Ľ���ʱ��
    Cost_tim = 0;   % һ������ʼ��ʱ�䣨���Ϸ��µ�ʱ�䣩
    % �������������㲢�������ϵ�ʱ�� = max(��һ�����Ϸ��µ�ʱ�� + ��������Ϲ�Ӧ���ʱ�� + װ��ʱ�� + ��Ӧ�㵽��������ʱ��, ���������һ������Ľ���ʱ�䣩 + ж��ʱ��
    Cost_tim = max(Cost_tim + info.T_noload(SupplyOrder(1), info.ini.tower_init_pos_in_demand) + info.REQUEST(Order(1)).loadTime + info.T_load(SupplyOrder(1), info.REQUEST(Order(1)).demand),...
        demandEndTim(info.REQUEST(Order(1)).demand)) + info.REQUEST(Order(1)).unloadTime;
    % �������Ľ���ʱ�� = �����������ʼʱ�� + ����ִ��ʱ��
    demandEndTim(info.REQUEST(Order(1)).demand) = Cost_tim + info.REQUEST(Order(1)).time;
    endTim(Order(1)) = demandEndTim(info.REQUEST(Order(1)).demand);
    
    for i = 2 : n
        % �����Ϸ��µ�ʱ�䣨������ʼ��ʱ�䣩 = max(���������������ʱ�䣬 ���������һ������Ľ���ʱ��) + �������ж��ʱ��
        Cost_tim = max(Cost_tim + info.T_noload(SupplyOrder(i), info.REQUEST(Order(i-1)).demand) + info.REQUEST(Order(i)).loadTime + info.T_load(SupplyOrder(i), info.REQUEST(Order(i)).demand), demandEndTim(info.REQUEST(Order(i)).demand)) + info.REQUEST(Order(i)).unloadTime;	%�м���������
        demandEndTim(info.REQUEST(Order(i)).demand) = Cost_tim + info.REQUEST(Order(i)).time;
        endTim(Order(i)) = demandEndTim(info.REQUEST(Order(i)).demand);
    end
    
    makespan = max(endTim); % �깤ʱ��
    
    weight = 2;
    sameLen = 1;
    score = 0;
    for i = 1 : n - 1
        % ����㼰��������һ��
        if info.REQUEST(Order(i)).demand == info.REQUEST(Order(i + 1)).demand && info.REQUEST(Order(i)).material == info.REQUEST(Order(i + 1)).material
            sameLen = sameLen + 1;
            continue;
        end
        % �õ�����㼰����������ͬ�ĳ��Ⱥ���д���
        if sameLen ~= 1
            for j = 1 : sameLen
                score = score + 2 + weight ^ j;
            end
            sameLen = 1;
        end
        % �����һ�������ϲ�һ��
        if info.REQUEST(Order(i)).demand == info.REQUEST(Order(i + 1)).demand
            score = score + 2;
        % ����㲻һ����Ӧ��Ҳ��һ��
        elseif SupplyOrder(i) ~= SupplyOrder(i + 1)
            score = score + 1;
        end
    end
	score = 100000 / score;
    % ���ʱҪ�����ۺ�����ֵ�ϲ�Ϊһ��������
	Cost = [makespan score]';  
    Cost = roundn(Cost,-8);    % ����С�������λ���֣���ֹ���ھ������⵼��������ȵ������ȡ�
end