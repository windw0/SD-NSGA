function [newA, newAS, newB, newBS] = Cross(A,AS,B,BS,method)
    n = length(A);
    if strcmp(method,'PMX') % 部分匹配交叉
        % 生成交叉位置
        startPos = ceil(rand() * n);
        endPos  = ceil(rand() * n);
        if startPos > endPos
            tmp = startPos;
            startPos = endPos;
            endPos = tmp;
        end
        % 从向量 A 中选择需要被交叉的元素
        toCrossFromA = A(startPos:endPos);
        toCrossFromB = B(startPos:endPos);
        frontA = A(1:startPos-1);
        frontB = B(1:startPos-1);
        backA = A(endPos+1:end);
        backB = B(endPos+1:end);
        % 检测A中冲突基因并修复，至没有冲突为止
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
        % 检测B中冲突基因并修复，至没有冲突为止
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

    elseif strcmp(method, 'OX')  %顺序交叉
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
        % 生成newA
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
        % 生成newB
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
    elseif strcmp(method,'MPX') % 部分匹配交叉
        startPos = ceil(n * rand());    % 交叉起始位置，取小值
        endPos = ceil(n * rand());      % 交叉终止位置，取大值
        if startPos > endPos
            tmp = startPos;
            startPos = endPos;
            endPos = tmp;
        end
        offspringA = B(startPos : endPos);  % 以A为reciever的子代
        offspringB = A(startPos : endPos);  % 以B为reciever的子代
        Apos = 1;
        Bpos = 1;
        % 补充offspringA
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
        % 补充offspringB
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
        
    % 供应点编码的对应位置跟随移动
	for i = 1 : length(newA)
        index(i) = find(A == newA(i));
	end
	newAS = AS(index);
	for i = 1 : length(newB)
        index(i) = find(B == newB(i));
	end
	newBS = BS(index);
end
