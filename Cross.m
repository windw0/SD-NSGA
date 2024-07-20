function [newA, newAS, newB, newBS] = Cross(A,AS,B,BS,method)
    n = length(A);
    if strcmp(method,'PMX') % ����ƥ�佻��
        % ���ɽ���λ��
        startPos = ceil(rand() * n);
        endPos  = ceil(rand() * n);
        if startPos > endPos
            tmp = startPos;
            startPos = endPos;
            endPos = tmp;
        end
        % ������ A ��ѡ����Ҫ�������Ԫ��
        toCrossFromA = A(startPos:endPos);
        toCrossFromB = B(startPos:endPos);
        frontA = A(1:startPos-1);
        frontB = B(1:startPos-1);
        backA = A(endPos+1:end);
        backB = B(endPos+1:end);
        % ���A�г�ͻ�����޸�����û�г�ͻΪֹ
        flag1=1;
        while(flag1)
            flag2=1;
            for i=1:length(toCrossFromB)
                tmp=find(frontA==toCrossFromB(i));
                if tmp
                    frontA(tmp)=toCrossFromA(i);
                    flag2=0;
                    break;
                end
                tmp=find(backA==toCrossFromB(i));
                if tmp
                    backA(tmp)=toCrossFromA(i);
                    flag2=0;
                    break;
                end
            end
            if(i==length(toCrossFromB) && flag2==1)
                    flag1=0;
            end
        end
        % ���B�г�ͻ�����޸�����û�г�ͻΪֹ
        flag1=1;
        while(flag1)
            flag2=1;
            for i=1:length(toCrossFromA)
                tmp=find(frontB==toCrossFromA(i));
                if tmp
                    frontB(tmp)=toCrossFromB(i);
                    flag2=0;
                    break;
                end
                tmp=find(backB==toCrossFromA(i));
                if tmp
                    backB(tmp)=toCrossFromB(i);
                    flag2=0;
                    break;
                end
            end
            if(i==length(toCrossFromA) && flag2==1)
                    flag1=0;
            end
        end
        newA = [frontA,toCrossFromB,backA];
        newB = [frontB,toCrossFromA,backB];

    elseif strcmp(method, 'OX')  %˳�򽻲�
        startPos = ceil(rand() * n);
        endPos  = ceil(rand() * n);
        if startPos > endPos
            tmp = startPos;
            startPos = endPos;
            endPos = tmp;
        end
        toCrossFromA = A(startPos:endPos);
        toCrossFromB = B(startPos:endPos);
        leftnewA = [];
        leftnewB = [];
        % ����newA
        for i = 1 : length(B)
            tmp = find(toCrossFromA == B(i));
            if tmp
            else
                leftnewA(end+1) = B(i);
            end
        end
        if startPos ~= 1
            newA = [leftnewA(1:startPos-1),toCrossFromA,leftnewA(startPos:end)];
        else
            newA = [toCrossFromA,leftnewA(startPos:end)];
        end
        % ����newB
        for i = 1 : length(A)
            tmp = find(toCrossFromB == A(i));
            if tmp
            else
                leftnewB(end+1) = A(i);
            end
        end
        if startPos ~= 1
            newB = [leftnewB(1:startPos-1),toCrossFromB,leftnewB(startPos:end)];
        else
            newB = [toCrossFromB,leftnewB(startPos:end)];
        end
    elseif strcmp(method,'MPX') % ����ƥ�佻��
        startPos = ceil(n * rand());    % ������ʼλ�ã�ȡСֵ
        endPos = ceil(n * rand());      % ������ֹλ�ã�ȡ��ֵ
        if startPos > endPos
            tmp = startPos;
            startPos = endPos;
            endPos = tmp;
        end
        offspringA = B(startPos : endPos);  % ��AΪreciever���Ӵ�
        offspringB = A(startPos : endPos);  % ��BΪreciever���Ӵ�
        Apos = 1;
        Bpos = 1;
        % ����offspringA
        while length(offspringA) < n
            Apos = find(A == offspringA(end)) + 1;
            if Apos <= n && isempty(find(offspringA == A(Apos)))
                offspringA(end + 1) = A(Apos);
            else
                Bpos = find(B == offspringA(end)) + 1;
                if Bpos <= n && isempty(find(offspringA == B(Bpos)))
                    offspringA(end + 1) = B(Bpos);
                else
                    for Apos = 1 : n
                        if isempty(find(offspringA == A(Apos)))
                            offspringA(end + 1) = A(Apos);
                            break;
                        end
                    end
                end
            end
        end
        % ����offspringB
        while length(offspringB) < n
            Bpos = find(B == offspringB(end)) + 1;
            if Bpos <= n && isempty(find(offspringB == B(Bpos)))
                offspringB(end + 1) = B(Bpos);
            else
                Apos = find(A == offspringB(end)) + 1;
                if Apos <= n && isempty(find(offspringB == A(Apos)))
                    offspringB(end + 1) = A(Apos);
                else
                    for Bpos = 1 : n
                        if isempty(find(offspringB == B(Bpos)))
                            offspringB(end + 1) = B(Bpos);
                            break;
                        end
                    end
                end
            end
        end
        newA = offspringA;
        newB = offspringB;
    end
        
    % ��Ӧ�����Ķ�Ӧλ�ø����ƶ�
	for i = 1 : length(newA)
        index(i) = find(A == newA(i));
	end
	newAS = AS(index);
	for i = 1 : length(newB)
        index(i) = find(B == newB(i));
	end
	newBS = BS(index);
end
