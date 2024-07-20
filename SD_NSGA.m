%% ������
dbstop if error;  % �����á�
% clc;
% clear;
% close all;
tic     %��¼ʱ��
%% Problem Definition
bianli = true;
info = input_info8();
info.calcu(info.SUPPLY_x, info.SUPPLY_y, info.SUPPLY_z);
nVar = info.ini.num_REQUEST;
CostFunction = @(x, y, info) GSSP_MOP2(x, y, info);  % Cost Function���ۺ���������MOP2�����á�����������Ըġ�
    % ��fhandle = @(arglist)body,
    % ����һ�����������͸ú����ľ��������@�Ƕ��������������body���庯�������壬arglist�������Դ��ݸ������Ĳ����б�
VarSize = [1 nVar]; % Size of Decision Variables Matrix���߱�������Ĵ�С
% Number of Objective FunctionsĿ�꺯���ĸ���
a = randperm(nVar);
b = GenerateSupplyOrder(a, info.REQUEST, info.cons_MATERIAL);
nObj = numel(CostFunction(a, b, info));
    % ��numel(A������):��������������ָ��������Ԫ�ظ�������

%% NSGA Parameters
% Generating Reference Points���ɲο���
nDivision = 71; % ����ÿһά�����ɲο��������
Zr = GenerateReferencePoints(nObj, nDivision);  % �����ʾ���вο�������ľ���
    
% ��Ⱥ���ܲ���
params = struct(...
	'maxGen', 200,...           % ������
    'Pmax', 120,...             % ����Ⱥ������Ŀ�ʹ�С����Դ�㶨����
	'popDivNum', 3,...          % Эͬ������Ⱥ��
    'Smax',0.6,...              % ����Ⱥ�Ĺ�ģ���ޱ���
    'Smin',0.2,...              % ����Ⱥ�Ĺ�ģ���ޱ���
    'alphaK',10,...             % ������Ⱥʱ�ĵ�������
    'Dd',10,...                 % ��������Ĳ���������������������
    'DI',20,...                 % ���ױ����Ĳ�������ȺDI���ڲ������
    'Do',10,...                 % �³´�л����Ĳ���������Do�����ֲ���ʱ��ȡ������Ⱥ��
    'keepNum',1,...             % ���ֱ�������Ⱥ��
    'New',false);               % �����Ƿ�������Ⱥ���ɣ������ж��Ƿ�����³´�л����̬ռλ   

SmaxNum = ceil(params.Smax * params.Pmax);   % ����Ⱥ�Ĺ�ģ���ޱ���
SminNum = ceil(params.Smin * params.Pmax);   % ����Ⱥ�Ĺ�ģ���ޱ���


paramsdivDefault.nPop = ceil(params.Pmax / params.popDivNum); % ����Ⱥ��С
paramsdivDefault.cross = 0.9;                           % �������
paramsdivDefault.variation = 0.02;                      % �������
paramsdivDefault.cross_method = 'OX';                    % ����ƥ�佻�棨PMX����˳�򽻲棨OX������������棨MPX��
paramsdivDefault.crossOne = 0.6;
paramsdivDefault.crossTwo = 0.3;
paramsdivDefault.crossThree = 0.1;
paramsdivDefault.variation_method = 'TPM';                % ���㻻λ���죨TPM�������ñ��죨RSM�������������죨OIM����������죨ARM��
paramsdivDefault.maxTimes = 2;                          % ��Ⱥ�������������ֳ�жȷ��򣬿��ǵ��������Ӵ���ͬѡ��ȡ1-2
paramsdivDefault.dd = 0;                             % �������Ĵ���
paramsdivDefault.di = 0;                                % ����Ⱥ���ڵĴ���
paramsdivDefault.do = 1;                                % ����Ⱥ���ֲ���Ĵ���
paramsdivDefault.Zr = Zr;       
paramsdivDefault.nZr = size(Zr, 2);                     % �õ����ɵĲο����������
paramsdivDefault.zmin = [];
paramsdivDefault.zmax = [];
paramsdivDefault.smin = [];
% ��Ⱥʵ�ʹ�ģС����Ҫѡ��ĵĹ�ģ
paramsdivDefault.error = 0;

paramsdiv = repmat(paramsdivDefault, 1, params.popDivNum);

for i = 1 : params.popDivNum                            % ����ÿ����Ⱥ��Ĳ���
    paramsdiv(i) = paramsdivDefault;
end
paramsdiv(end).nPop = params.Pmax - sum([paramsdiv.nPop]) + paramsdiv(end).nPop;

F_f = cell(1, params.popDivNum);                            % ������Ⱥ������������������ǰ�ص���Ӧ��ֵ
F_s = cell(1, params.popDivNum);                            % ������Ⱥ������������������ǰ�صĽ�
DS = zeros(1, params.popDivNum);                            % ����Ⱥ��ռ�ŷ���
NF = zeros(1, params.maxGen);                           % ���ÿ��������Ⱥ�������в���
% ���ŵ����������ÿһ��Ⱥ������ǰ�ظ��岢����ѡ��
elite_pool = [];
% ���ŵ���������
params_elite = struct(...
    'nPop', 40,...              % ��Ⱥ��С,������ȡ���һǰ�ص����и���
    'Zr', Zr,...
    'nZr',size(Zr, 2),...       % �õ����ɵĲο����������
    'zmin', [],...
    'zmax', [],...
    'smin', []);       

DivPop = cell(1, params.popDivNum); % ÿ������Ⱥ
F = cell(1, params.popDivNum);  % ÿ������Ⱥ�Ĳ�
uniqueIndiv = cell(params.popDivNum, 2);    % ���ÿ����Ⱥ�Ķ������壨�������Ӧ��ֵ��

improved_circle_flag = false;  %�Ƿ�ʹ�ø���Ȧ

% �洢��������Ⱥ�Ĺ�ģ
divPopQuantity = zeros(params.popDivNum + 1, params.maxGen + 1);
divPopQuantity(1,:) = 0 : params.maxGen;

lineNum = 0;    % ��¼�����Ⱥ�Ĵ���
lineDefault.it = 0;     % ��¼�ߵĴ���
lineDefault.popNum = 0; % ��¼���������Ⱥ�ı��
lineDefault.flag = 0;   % ��¼���������ԭ��1��ʾ�����2��ʾ�³´�л��3��ʾ��̬ռλ��
replaceLine = repmat(lineDefault, 1, ceil(params.maxGen / params.DI * params.popDivNum));    % ����DI����ÿDI������滻����
sBestNum = zeros(1, params.maxGen + 1);     % ���ÿһ�����ŵ������и������Ŀ  
fBestNum = zeros(1, params.maxGen + 1); 

FParetoBest = []; % ��¼ǰһ��������ǰ��
FPareto = []; % ��¼��ǰ��������ǰ��

global Tem; % ��Ӧ��������ʱ�Ĳ���
Tem = 2000;     % ÿһ�����¶�
TStart = 2000;  % ��ʼʱ���¶�
Tend = 1e-2;    % ����ʱ���¶�
deltaT = (Tend / TStart) ^ (1 / params.maxGen);


%% ���ر�����
if bianli == true
    load('design10task.mat', 'external_set')
    % ����һ����Ӧ��ֵ����
    [~, orderFt] = sort(external_set(:, 2 * nVar + 1));
    external_set(:, 1 : end) = external_set(orderFt, 1 : end);

    % ��⣺ǰһ������򣬺�һ�����Ӧ��ѡ��
    realS = external_set(:, 1 : 2 * nVar);
    % ��ֵ
    realF = external_set(:, 2 * nVar + 1 : 2 * nVar + 2);   % ������Ӧ��ֵ
    realF = unique(realF, 'row');       % ȥ��

    % ͳ�Ʊ�����ÿһ��Ӧ��ֵ�н�ĸ���
    eachSNum = zeros(1, size(realF, 1));   % ��ʾ�����õ��ĸ�����Ӧ��ֵ�ĸ���
    k_er = 1;
    for i = 1 : size(realF, 1)
        while k_er <= size(external_set, 1)
            if external_set(k_er, 2 * nVar + 1) == realF(i, 1)
                eachSNum(i) = eachSNum(i) + 1;
                k_er = k_er + 1;
            else
                break;
            end
        end
    end

    everyGenFindF = zeros(1, params.maxGen + 1);    % ��¼ÿһ�����ҵ�����Ӧ��ֵ�ĸ���
    everyGenFindS = zeros(1, params.maxGen + 1);    % ��¼ÿһ�����ҵ�����Ӧ��ֵ�ĸ���
end

%% Initialization
disp('Starting NSGA-III ...');
% ��ÿ��������й���Ϣ�������Ϊempty_individual�Ľṹ����
empty_individual.Order = [];
empty_individual.SupplyOrder = [];
empty_individual.Cost = [];
empty_individual.Rank = [];
empty_individual.DominationSet = [];
empty_individual.DominatedCount = [];
empty_individual.NormalizedCost = [];
empty_individual.AssociatedRef = [];
empty_individual.DistanceToAssociatedRef = [];
empty_individual.PopNum = [];
% ��ʼ����Ⱥ
thisGeneration = GenerateNewPop(params.Pmax, 0, empty_individual, nVar, improved_circle_flag, info);

% ��Ϊ������Ⱥ
for i = 1 : params.popDivNum
    DivPop{i} = thisGeneration((i - 1) *  paramsdiv(i).nPop + 1 : i * paramsdiv(i).nPop); % ��ʼ��ʱ��Ϊparams.nPop / params.popDivNum��
    for j = 1 : paramsdiv(i).nPop
        DivPop{i}(j).PopNum = i;    % ��¼ÿ��������������Ⱥ��
    end
	[DivPop{i}, F{i}, paramsdiv(i)] = SortAndSelectPopulation(DivPop{i}, paramsdiv(i));     % �Ը�������Ⱥ���з�֧�����򣬴˴�δѡ��
    divPopQuantity(i + 1, 1) = paramsdiv(i).nPop;
end

% �������ŵ�����
for i = 1 : params.popDivNum
    elite_pool = [elite_pool; DivPop{i}(F{i}{1})];  %#ok      % ÿ����Ⱥ�������ǰ�ؽ������ŵ�������
end
elite_pool = RemoveDuplicate(elite_pool, 'Order');      % ȥ�ظ���
params_elite.nPop = length(elite_pool);
[elite_pool, F_elite, params_elite] = SortAndSelectPopulation(elite_pool, params_elite);    % ���ŵ��������з�֧������
elite_pool = elite_pool(F_elite{1});            % ȡ������ǰ�صĸ���
sBestNum(1, 1) = length(elite_pool);           % ���ż����еĸ��壨�⣩��Ŀ

Cost = [elite_pool.Cost]';      % ��Ӧ��ֵ
[~, ia, ~] = unique(Cost, 'rows');
fBestNum(1, 1) = length(ia);    % ��Ӧ��ֵ�ĸ���

% ��¼����ǰ��(��Ӧ��ֵ)�Լ����ֵĴ�����ʱ��
FParetoBest = Cost(ia);
bestFIt = 0;
bestFTime = toc;

% ��¼����ǰ���Լ����ֵĴ�����ʱ��
best_Pareto_front = elite_pool;
best_it = 0;
best_time = toc;
oneMin = [];
twoMin = [];
weightSum = [];  % �洢��Ȩ�͵���Сֵ

F_best = elite_pool;          % ����Ⱥ���е����Ž� 
Cost = [F_best.Cost];
[~,order] = sort(Cost(2,:));   % ���յ�һ�����ۺ���ֵ����
F_best = F_best(order);
twoMin(1) = F_best(1).Cost(2);

F_best = elite_pool;          % ����Ⱥ���е����Ž� 
Cost = [F_best.Cost];
[~,order] = sort(Cost(1,:));   % ���յ�һ�����ۺ���ֵ����
F_best = F_best(order);
oneMin(1) = F_best(1).Cost(1);

weightSum(1) = min((Cost(1, :) + Cost(2, :)) / 2);  % ��Ȩ�͵���Сֵ

if bianli == true
    Cost = Cost';
    independF = unique(Cost, 'row'); 
	everyGenFindF(1) = sum(ismember(independF, realF, 'row'));
    independS = zeros(length(elite_pool), 2 * nVar);
    for i = 1 : length(elite_pool)
        independS(i, :) = [elite_pool(i).Order elite_pool(i).SupplyOrder];
    end
	everyGenFindS(1) = sum(ismember(independS, realS, 'row'));
end

%% NSGA Main Loop������������
for it = 1 : params.maxGen
    disp(['Iteration ' num2str(it)]);
    % ��ÿ����Ⱥ������������
    estimatePop = [];
    for i = 1 : params.popDivNum
        paramsdiv(i).di =  paramsdiv(i).di + 1;  % ����Ⱥ���ڴ�����1
        estimatePop = [estimatePop; RemoveDuplicate(DivPop{i}(F{i}{1}), 'Order')];  %#ok % ÿ������Ⱥ����ǰ�صĶ����������������
    end
    [DS, estimBestPop, NF(it)] = PopSort(estimatePop, paramsdivDefault, params.popDivNum, params.alphaK);   
    [~,popRank] = sort(DS,'descend');    % �õ�����ȺȺ����
    
    % ��������ȷ����Ⱥ��ѡ���������Եı����Լ�ѡ�������Ե�����
    paramsdiv(popRank(1)).crossOne = 0.6;
    paramsdiv(popRank(1)).crossTwo = 0.3;
    paramsdiv(popRank(1)).crossThree = 0.1;
    paramsdiv(popRank(1)).variation_method = 'TPM'; 
    paramsdiv(popRank(2)).crossOne = 0.3;
    paramsdiv(popRank(2)).crossTwo = 0.4;
    paramsdiv(popRank(2)).crossThree = 0.3;
    paramsdiv(popRank(2)).variation_method = 'PRM'; 
    paramsdiv(popRank(3)).crossOne = 0.1;
    paramsdiv(popRank(3)).crossTwo = 0.3;
    paramsdiv(popRank(3)).crossThree = 0.6;
    paramsdiv(popRank(3)).variation_method = 'RM'; 
    
  
    F_fLast = F_f;F_sLast = F_s;    % ������Ⱥ��һ����������������ǰ�صı������Ӧ��ֵ
    [F_f, F_s] = GetDivPopBest(estimBestPop, params.popDivNum);     % �õ�������Ⱥ��������������ǰ�صı������Ӧ��ֵ
    F_sSum = [];
    for i = 1 : params.popDivNum
        F_sSum = [F_sSum; F_s{i}];  %#ok
    end
    
	% ���ݷ���ȷ����Ⱥ��һ���Ĺ�ģ�͸��壬��ʤ��̭����
    DS_sum = sum(DS);
    for i = 1 : params.popDivNum - 1
        if ceil(params.Pmax * DS(i) / DS_sum) < paramsdiv(i).maxTimes * paramsdiv(i).nPop
            paramsdiv(i).nPop = ceil(params.Pmax * DS(i) / DS_sum);
        else
            paramsdiv(i).nPop = ceil(paramsdiv(i).maxTimes * paramsdiv(i).nPop);
        end
    end
    paramsdiv(params.popDivNum).nPop = params.Pmax - sum([paramsdiv(1 : end - 1).nPop]);
    
	% ��ģ���Ʒ���
    num = 0;
    for i = 1 : params.popDivNum
        if paramsdiv(i).nPop > SmaxNum
            num = num + paramsdiv(i).nPop - SmaxNum;
            paramsdiv(i).nPop = SmaxNum;
        elseif paramsdiv(i).nPop < SminNum
            num = num + paramsdiv(i).nPop - SminNum;
            paramsdiv(i).nPop = SminNum;
        end
    end
    % num��Ϊż������������ʱȡż��,��������Ⱥ�����趨ֵ������ָ�����СȺ�����򣬴�Ⱥ�����
    if num > 0 
        paramsdiv(popRank(3)).nPop = paramsdiv(popRank(3)) + num / 2 - mod(num / 2, 2);
        paramsdiv(popRank(2)).nPop = paramsdiv(popRank(2)) + num / 2 + mod(num / 2, 2);
    elseif num < 0
        paramsdiv(popRank(1)).nPop = paramsdiv(popRank(1)).nPop + num;
    end
    
    % ���п�����Ҫ����Ⱥ������������³´�л����̬ռλ�����ж�
    params.New = false;            % ���˴��Ƿ�������Ⱥ���ɵĲ���������Ϊfalse    
    % ��Ⱥ�������ӵĴ����������������
    for i = 1 : params.popDivNum - 1
        paramsdiv(popRank(i)).dd = 0;
    end
    paramsdiv(popRank(end)).dd = paramsdiv(popRank(end)).dd + 1;    % �������Ĵ�����1
    if paramsdiv(popRank(end)).dd >= params.Dd && paramsdiv(popRank(end)).di >= params.DI
        disp(['��' num2str(it) '����' num2str(popRank(end)) '��Ⱥ��� ' ' ���������' num2str(paramsdiv(popRank(end)).di) ' ��������' num2str(paramsdiv(popRank(end)).dd)]);
        DivPop{popRank(end)} = GenerateNewPop(paramsdiv(popRank(end)).nPop, popRank(end), empty_individual, nVar, improved_circle_flag, info);  % ��������Ⱥ
        F_f{popRank(end)} = [];F_s{popRank(end)} = [];
        n = paramsdiv(popRank(end)).nPop;      
        paramsdiv(popRank(end)) = paramsdivDefault; % ��Ⱥ������ΪĬ��
        paramsdiv(popRank(end)).nPop = n;           % ��Ⱥ��ģ����
        paramsdiv(popRank(end)).di = 1;
        params.New = true;  % �˴��Ѳ�������Ⱥ
        lineNum = lineNum + 1;  % �ߵ���Ŀ��1
        replaceLine(lineNum) = struct('it', it, 'popNum', popRank(end), 'flag', 1);   % �������Ϊit����Ⱥ���ΪpopRank(end)���滻ԭ��Ϊ���
    end    
    
    % �³´�л�ж�
    for i = 1 : params.keepNum
        if isequal(F_f{popRank(i)}, F_fLast{popRank(i)})    % ���֣���Ӧ��ֵ��û��
            paramsdiv(popRank(i)).do = paramsdiv(popRank(i)).do + 1;
        else
            paramsdiv(popRank(i)).do = 1;
        end
    end
    for i = params.keepNum + 1 : params.popDivNum
        if isequal(F_f{popRank(i)}, F_fLast{popRank(i)})    % ���֣���Ӧ��ֵ��û��
            paramsdiv(popRank(i)).do = paramsdiv(popRank(i)).do + 1;
            if paramsdiv(popRank(i)).do >= params.Do && paramsdiv(popRank(i)).di >= params.DI && params.New ~= true
                disp(['��' num2str(it) '����' num2str(popRank(i)) '��Ⱥ�³´�л��ȡ��' ' ���������' num2str(paramsdiv(popRank(i)).di) ' ����ֲ��Ĵ�����' num2str(paramsdiv(popRank(i)).do)]);
                [DivPop{popRank(i)}, paramsdiv(popRank(i))] = ReplacePop(paramsdiv(popRank(i)), popRank(i), empty_individual, nVar, improved_circle_flag, info, F_s, F_sSum);
                F_f{popRank(i)} = [];F_s{popRank(i)} = [];
                params.New = true;
                lineNum = lineNum + 1;  % �ߵ���Ŀ��1
                replaceLine(lineNum) = struct('it', it, 'popNum', popRank(i), 'flag', 2);   % �滻����Ϊit����Ⱥ���ΪpopRank(i)���滻ԭ��Ϊ�³´�л
            end
        else
            paramsdiv(popRank(i)).do = 1;
        end
    end
     
    % ��̬ռλ
    if params.New ~= true
        Content_DI = [paramsdiv.di] >= params.DI;    % �������ױ�����λ����Ϊ1    
        [~, num] = find(Content_DI == 1);       % �ҵ��������ױ�������Ⱥ���
        if length(num) >= 2
            mid = randperm(length(num));        % ����������
             % �ж��Ƿ�����̬ռλ
             numReplace = 0;    % ������ռλ,ȡ������mid(1),����Ϊ1��ȡ������mid(2),��Ϊ2,������ռλ,��Ϊ0
             if size(F_f{num(mid(1))}, 1) == 0
                 DivPop{num(mid(1))} = GenerateNewPop(paramsdiv(num(mid(1))).nPop, num(mid(1)), empty_individual, nVar, improved_circle_flag, info);
                 numReplace = 1;
                 paramsdiv(num(mid(1))).di = 0;
                 paramsdiv(num(mid(1))).dd = 0;
                 paramsdiv(num(mid(1))).do = 1;
             elseif size(F_f{num(mid(2))}, 1) == 0
                 DivPop{num(mid(2))} = GenerateNewPop(paramsdiv(num(mid(2))).nPop, num(mid(2)), empty_individual, nVar, improved_circle_flag, info);
                 numReplace = 2;
                 paramsdiv(num(mid(2))).di = 0;
                 paramsdiv(num(mid(2))).dd = 0;
                 paramsdiv(num(mid(2))).do = 1;
             else
                [judge, numReplace] = IncludeJudge(F_f{num(mid(1))}, F_f{num(mid(2))}, DS(num(mid(1))), DS(num(mid(2))));
                if judge == true    % ������̬ռλ����Ҫ�滻Ⱥ��
                    [DivPop{num(mid(numReplace))}, paramsdiv(num(mid(numReplace)))] = ReplacePop(paramsdiv(num(mid(numReplace))), num(mid(numReplace)), empty_individual, nVar, improved_circle_flag, info, F_s, F_sSum);
                end
             end
             if numReplace ~= 0
                disp(['��' num2str(it) '����' num2str(num(mid(numReplace))) '��Ⱥռλ��ȡ�� ' num2str(num(mid(3 - numReplace))) '��Ⱥ����']);
                F_f{num(mid(numReplace))} = [];F_s{num(mid(numReplace))} = [];
                lineNum = lineNum + 1;  % �ߵ���Ŀ��1
                replaceLine(lineNum) = struct('it', it, 'popNum', num(mid(numReplace)), 'flag', 3);   % �滻����Ϊit����Ⱥ���ΪpopRank(i)���滻ԭ��Ϊ�³´�л
             end
        end
    end    
    
    % ��������Ⱥ�ֱ����
    for i = 1 : params.popDivNum
        [DivPop{i}, F{i}, paramsdiv(i)] = GetNextPop(i, DivPop{i}, paramsdiv(i), empty_individual, info);
        divPopQuantity(i + 1,it + 1) = paramsdiv(i).nPop;   % �洢����Ⱥ�Ĺ�ģ
    end
    
    Tem = Tem * deltaT;
    % �������ŵ�����
    for i = 1 : params.popDivNum
        elite_pool = [elite_pool; DivPop{i}(F{i}{1})];  %#ok      % ÿ����Ⱥ�������ǰ�ؽ������ŵ�������
    end
    elite_pool = RemoveDuplicate(elite_pool, 'Order');      % ȥ�ظ���
    params_elite.nPop = length(elite_pool);
    [elite_pool, F_elite, params_elite] = SortAndSelectPopulation(elite_pool, params_elite);    % ���ŵ��������з�֧������
    elite_pool = elite_pool(F_elite{1});            % ȡ������ǰ�صĸ���
	sBestNum(1, it + 1) = length(elite_pool);           % ���ż����еĸ�����Ŀ
    
    Cost = [elite_pool.Cost]';      % ��Ӧ��ֵ
    [~, ia, ~] = unique(Cost, 'rows');
    fBestNum(1, it + 1) = length(ia);    % ��Ӧ��ֵ�ĸ���
    FPareto = Cost(ia);
    
    % ��¼����ǰ�أ���Ӧ��ֵ������ǰ�ر仯����õ����ŵ�ǰ��
	if ~isequal(FPareto, FParetoBest)
        bestFIt = it;
        bestFTime = toc;
        FParetoBest = FPareto;
	end
    
    % ��¼����ǰ�أ���ǰ�ر仯����õ����ŵ�ǰ��
    if ~Pareto_Compare(best_Pareto_front,elite_pool)
        best_Pareto_front = elite_pool;
        best_it = it;
        best_time = toc;
    end

    
    F_best = elite_pool;          % ����Ⱥ���е����Ž� 
    Cost = [F_best.Cost];
    [~,order] = sort(Cost(2,:));   % ���յ�һ�����ۺ���ֵ����
    F_best = F_best(order);
    twoMin(it + 1) = F_best(1).Cost(2);
    
    F_best = elite_pool;          % ����Ⱥ���е����Ž� 
    Cost = [F_best.Cost];
    [~,order] = sort(Cost(1,:));   % ���յ�һ�����ۺ���ֵ����
    F_best = F_best(order);
    oneMin(it + 1) = F_best(1).Cost(1);
    
    CostNor = [F_best.NormalizedCost]';
    CostNorWeight = [];
    CostNorWeight(1,:) = 0.5 * CostNor(:,1) + 0.5 * CostNor(:,2);
    [~,order] = sort(CostNorWeight);   % ����
    CostNorWeight = CostNorWeight(order);
    
    weightSum(it + 1) = min((Cost(1, :) + Cost(2, :)) / 2);  % ��Ȩ�͵���Сֵ

    if bianli == true
        Cost = Cost';
        independF = unique(Cost, 'row'); 
        everyGenFindF(it + 1) = sum(ismember(independF, realF, 'row'));
        independS = zeros(length(elite_pool), 2 * nVar);
        for i = 1 : length(elite_pool)
            independS(i, :) = [elite_pool(i).Order elite_pool(i).SupplyOrder];
        end
        everyGenFindS(it + 1) = sum(ismember(independS, realS, 'row'));
    end

end
endtime = toc;
