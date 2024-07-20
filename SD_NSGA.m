%% 程序处理
dbstop if error;  % 调试用。
% clc;
% clear;
% close all;
tic     %记录时间
%% Problem Definition
bianli = true;
info = input_info8();
info.calcu(info.SUPPLY_x, info.SUPPLY_y, info.SUPPLY_z);
nVar = info.ini.num_REQUEST;
CostFunction = @(x, y, info) GSSP_MOP2(x, y, info);  % Cost Function代价函数，进入MOP2中设置。输入参数可以改。
    % 【fhandle = @(arglist)body,
    % 构造一个匿名函数和该函数的句柄，其中@是定义句柄的运算符，body定义函数的主体，arglist是您可以传递给函数的参数列表。
VarSize = [1 nVar]; % Size of Decision Variables Matrix决策变量矩阵的大小
% Number of Objective Functions目标函数的个数
a = randperm(nVar);
b = GenerateSupplyOrder(a, info.REQUEST, info.cons_MATERIAL);
nObj = numel(CostFunction(a, b, info));
    % 【numel(A，条件):计算数组中满足指定条件的元素个数。】

%% NSGA Parameters
% Generating Reference Points生成参考点
nDivision = 71; % 设置每一维上生成参考点的数量
Zr = GenerateReferencePoints(nObj, nDivision);  % 输出表示所有参考点坐标的矩阵。
    
% 种群的总参数
params = struct(...
	'maxGen', 200,...           % 最大代数
    'Pmax', 120,...             % 子种群个体数目和大小，资源恒定法则
	'popDivNum', 3,...          % 协同进化种群数
    'Smax',0.6,...              % 子种群的规模上限比例
    'Smin',0.2,...              % 子种群的规模下限比例
    'alphaK',10,...             % 评估种群时的调节因子
    'Dd',10,...                 % 劣种灭绝的参数（连续最差的最大代数）
    'DI',20,...                 % 弱幼保护的参数（新群DI代内不灭绝）
    'Do',10,...                 % 新陈代谢法则的参数（连续Do代表现不变时，取代亚种群）
    'keepNum',1,...             % 优种保留的种群数
    'New',false);               % 本代是否有新种群生成，用来判断是否进行新陈代谢、生态占位   

SmaxNum = ceil(params.Smax * params.Pmax);   % 子种群的规模上限比例
SminNum = ceil(params.Smin * params.Pmax);   % 子种群的规模下限比例


paramsdivDefault.nPop = ceil(params.Pmax / params.popDivNum); % 子种群大小
paramsdivDefault.cross = 0.9;                           % 交叉概率
paramsdivDefault.variation = 0.02;                      % 变异概率
paramsdivDefault.cross_method = 'OX';                    % 部分匹配交叉（PMX）、顺序交叉（OX）、最大保留交叉（MPX）
paramsdivDefault.crossOne = 0.6;
paramsdivDefault.crossTwo = 0.3;
paramsdivDefault.crossThree = 0.1;
paramsdivDefault.variation_method = 'TPM';                % 两点换位变异（TPM）、重置变异（RSM）、单点插入变异（OIM）、倒序变异（ARM）
paramsdivDefault.maxTimes = 2;                          % 种群最大扩大倍数，繁殖有度法则，考虑到父代和子代共同选择，取1-2
paramsdivDefault.dd = 0;                             % 连续最差的代数
paramsdivDefault.di = 0;                                % 子种群存在的代数
paramsdivDefault.do = 1;                                % 亚种群表现不变的代数
paramsdivDefault.Zr = Zr;       
paramsdivDefault.nZr = size(Zr, 2);                     % 得到生成的参考点的数量。
paramsdivDefault.zmin = [];
paramsdivDefault.zmax = [];
paramsdivDefault.smin = [];
% 种群实际规模小于需要选择的的规模
paramsdivDefault.error = 0;

paramsdiv = repmat(paramsdivDefault, 1, params.popDivNum);

for i = 1 : params.popDivNum                            % 定义每个子群体的参数
    paramsdiv(i) = paramsdivDefault;
end
paramsdiv(end).nPop = params.Pmax - sum([paramsdiv.nPop]) + paramsdiv(end).nPop;

F_f = cell(1, params.popDivNum);                            % 各亚种群当代在评估集合最优前沿的适应度值
F_s = cell(1, params.popDivNum);                            % 各亚种群当代在评估集合最优前沿的解
DS = zeros(1, params.popDivNum);                            % 亚种群的占优分数
NF = zeros(1, params.maxGen);                           % 存放每代中评估群体帕累托层数
% 最优档案集，添加每一子群的最优前沿个体并排序选择
elite_pool = [];
% 最优档案集参数
params_elite = struct(...
    'nPop', 40,...              % 种群大小,运行中取其第一前沿的所有个体
    'Zr', Zr,...
    'nZr',size(Zr, 2),...       % 得到生成的参考点的数量。
    'zmin', [],...
    'zmax', [],...
    'smin', []);       

DivPop = cell(1, params.popDivNum); % 每个亚种群
F = cell(1, params.popDivNum);  % 每个亚种群的层
uniqueIndiv = cell(params.popDivNum, 2);    % 存放每各种群的独立个体（编码和适应度值）

improved_circle_flag = false;  %是否使用改良圈

% 存储各代亚种群的规模
divPopQuantity = zeros(params.popDivNum + 1, params.maxGen + 1);
divPopQuantity(1,:) = 0 : params.maxGen;

lineNum = 0;    % 记录替代种群的次数
lineDefault.it = 0;     % 记录线的代数
lineDefault.popNum = 0; % 记录替代的亚种群的编号
lineDefault.flag = 0;   % 记录发生替代的原因（1表示灭绝；2表示新陈代谢；3表示生态占位）
replaceLine = repmat(lineDefault, 1, ceil(params.maxGen / params.DI * params.popDivNum));    % 过了DI代后，每DI代最多替换三个
sBestNum = zeros(1, params.maxGen + 1);     % 存放每一代最优档案集中个体的数目  
fBestNum = zeros(1, params.maxGen + 1); 

FParetoBest = []; % 记录前一代的最优前沿
FPareto = []; % 记录当前代的最优前沿

global Tem; % 供应点编码变异时的参数
Tem = 2000;     % 每一代的温度
TStart = 2000;  % 开始时的温度
Tend = 1e-2;    % 结束时的温度
deltaT = (Tend / TStart) ^ (1 / params.maxGen);


%% 加载遍历解
if bianli == true
    load('design10task.mat', 'external_set')
    % 按第一个适应度值排序
    [~, orderFt] = sort(external_set(:, 2 * nVar + 1));
    external_set(:, 1 : end) = external_set(orderFt, 1 : end);

    % 真解：前一半代表工序，后一半代表供应点选择
    realS = external_set(:, 1 : 2 * nVar);
    % 真值
    realF = external_set(:, 2 * nVar + 1 : 2 * nVar + 2);   % 两个适应度值
    realF = unique(realF, 'row');       % 去重

    % 统计遍历中每一适应度值中解的个数
    eachSNum = zeros(1, size(realF, 1));   % 表示遍历得到的该列适应度值的个数
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

    everyGenFindF = zeros(1, params.maxGen + 1);    % 记录每一代中找到的适应度值的个数
    everyGenFindS = zeros(1, params.maxGen + 1);    % 记录每一代中找到的适应度值的个数
end

%% Initialization
disp('Starting NSGA-III ...');
% 将每个个体的有关信息存放在名为empty_individual的结构体中
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
% 初始化种群
thisGeneration = GenerateNewPop(params.Pmax, 0, empty_individual, nVar, improved_circle_flag, info);

% 分为三个种群
for i = 1 : params.popDivNum
    DivPop{i} = thisGeneration((i - 1) *  paramsdiv(i).nPop + 1 : i * paramsdiv(i).nPop); % 初始化时都为params.nPop / params.popDivNum个
    for j = 1 : paramsdiv(i).nPop
        DivPop{i}(j).PopNum = i;    % 记录每个个体所属的子群体
    end
	[DivPop{i}, F{i}, paramsdiv(i)] = SortAndSelectPopulation(DivPop{i}, paramsdiv(i));     % 对各个亚种群进行非支配排序，此处未选择
    divPopQuantity(i + 1, 1) = paramsdiv(i).nPop;
end

% 更新最优档案集
for i = 1 : params.popDivNum
    elite_pool = [elite_pool; DivPop{i}(F{i}{1})];  %#ok      % 每个子群体的最优前沿进入最优档案集中
end
elite_pool = RemoveDuplicate(elite_pool, 'Order');      % 去重复解
params_elite.nPop = length(elite_pool);
[elite_pool, F_elite, params_elite] = SortAndSelectPopulation(elite_pool, params_elite);    % 最优档案集进行非支配排序
elite_pool = elite_pool(F_elite{1});            % 取其最优前沿的个体
sBestNum(1, 1) = length(elite_pool);           % 最优集合中的个体（解）数目

Cost = [elite_pool.Cost]';      % 适应度值
[~, ia, ~] = unique(Cost, 'rows');
fBestNum(1, 1) = length(ia);    % 适应度值的个数

% 记录最优前沿(适应度值)以及出现的代数和时间
FParetoBest = Cost(ia);
bestFIt = 0;
bestFTime = toc;

% 记录最优前沿以及出现的代数和时间
best_Pareto_front = elite_pool;
best_it = 0;
best_time = toc;
oneMin = [];
twoMin = [];
weightSum = [];  % 存储加权和的最小值

F_best = elite_pool;          % 评估群体中的最优解 
Cost = [F_best.Cost];
[~,order] = sort(Cost(2,:));   % 按照第一个代价函数值排序
F_best = F_best(order);
twoMin(1) = F_best(1).Cost(2);

F_best = elite_pool;          % 评估群体中的最优解 
Cost = [F_best.Cost];
[~,order] = sort(Cost(1,:));   % 按照第一个代价函数值排序
F_best = F_best(order);
oneMin(1) = F_best(1).Cost(1);

weightSum(1) = min((Cost(1, :) + Cost(2, :)) / 2);  % 加权和的最小值

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

%% NSGA Main Loop，迭代主程序
for it = 1 : params.maxGen
    disp(['Iteration ' num2str(it)]);
    % 对每个种群进行评估排序
    estimatePop = [];
    for i = 1 : params.popDivNum
        paramsdiv(i).di =  paramsdiv(i).di + 1;  % 亚种群存在代数加1
        estimatePop = [estimatePop; RemoveDuplicate(DivPop{i}(F{i}{1}), 'Order')];  %#ok % 每个亚种群最优前沿的独立解进入评估集合
    end
    [DS, estimBestPop, NF(it)] = PopSort(estimatePop, paramsdivDefault, params.popDivNum, params.alphaK);   
    [~,popRank] = sort(DS,'descend');    % 得到亚种群群排名
    
    % 根据排名确定种群中选择各交叉策略的比例以及选择变异策略的种类
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
    
  
    F_fLast = F_f;F_sLast = F_s;    % 各亚种群上一代在评估集合最优前沿的编码和适应度值
    [F_f, F_s] = GetDivPopBest(estimBestPop, params.popDivNum);     % 得到各亚种群在评估集合最优前沿的编码和适应度值
    F_sSum = [];
    for i = 1 : params.popDivNum
        F_sSum = [F_sSum; F_s{i}];  %#ok
    end
    
	% 根据分数确定子群下一代的规模和个体，优胜劣汰法则
    DS_sum = sum(DS);
    for i = 1 : params.popDivNum - 1
        if ceil(params.Pmax * DS(i) / DS_sum) < paramsdiv(i).maxTimes * paramsdiv(i).nPop
            paramsdiv(i).nPop = ceil(params.Pmax * DS(i) / DS_sum);
        else
            paramsdiv(i).nPop = ceil(paramsdiv(i).maxTimes * paramsdiv(i).nPop);
        end
    end
    paramsdiv(params.popDivNum).nPop = params.Pmax - sum([paramsdiv(1 : end - 1).nPop]);
    
	% 规模限制法则
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
    % num必为偶数（上述计算时取偶）,若总体总群少于设定值，则均分给两个小群，否则，大群体减少
    if num > 0 
        paramsdiv(popRank(3)).nPop = paramsdiv(popRank(3)) + num / 2 - mod(num / 2, 2);
        paramsdiv(popRank(2)).nPop = paramsdiv(popRank(2)) + num / 2 + mod(num / 2, 2);
    elseif num < 0
        paramsdiv(popRank(1)).nPop = paramsdiv(popRank(1)).nPop + num;
    end
    
    % 进行可能需要新种群的劣种灭绝、新陈代谢、生态占位规则判定
    params.New = false;            % 将此代是否有新种群生成的参数先设置为false    
    % 子群连续最劣的代数（劣种灭绝法则）
    for i = 1 : params.popDivNum - 1
        paramsdiv(popRank(i)).dd = 0;
    end
    paramsdiv(popRank(end)).dd = paramsdiv(popRank(end)).dd + 1;    % 连续最差的代数加1
    if paramsdiv(popRank(end)).dd >= params.Dd && paramsdiv(popRank(end)).di >= params.DI
        disp(['第' num2str(it) '代：' num2str(popRank(end)) '种群灭绝 ' ' 生存代数：' num2str(paramsdiv(popRank(end)).di) ' 最差代数：' num2str(paramsdiv(popRank(end)).dd)]);
        DivPop{popRank(end)} = GenerateNewPop(paramsdiv(popRank(end)).nPop, popRank(end), empty_individual, nVar, improved_circle_flag, info);  % 生成新种群
        F_f{popRank(end)} = [];F_s{popRank(end)} = [];
        n = paramsdiv(popRank(end)).nPop;      
        paramsdiv(popRank(end)) = paramsdivDefault; % 种群参数置为默认
        paramsdiv(popRank(end)).nPop = n;           % 种群规模更新
        paramsdiv(popRank(end)).di = 1;
        params.New = true;  % 此代已产生新种群
        lineNum = lineNum + 1;  % 线的数目加1
        replaceLine(lineNum) = struct('it', it, 'popNum', popRank(end), 'flag', 1);   % 灭绝代数为it，种群编号为popRank(end)，替换原因为灭绝
    end    
    
    % 新陈代谢判定
    for i = 1 : params.keepNum
        if isequal(F_f{popRank(i)}, F_fLast{popRank(i)})    % 表现（适应度值）没变
            paramsdiv(popRank(i)).do = paramsdiv(popRank(i)).do + 1;
        else
            paramsdiv(popRank(i)).do = 1;
        end
    end
    for i = params.keepNum + 1 : params.popDivNum
        if isequal(F_f{popRank(i)}, F_fLast{popRank(i)})    % 表现（适应度值）没变
            paramsdiv(popRank(i)).do = paramsdiv(popRank(i)).do + 1;
            if paramsdiv(popRank(i)).do >= params.Do && paramsdiv(popRank(i)).di >= params.DI && params.New ~= true
                disp(['第' num2str(it) '代：' num2str(popRank(i)) '种群新陈代谢被取代' ' 生存代数：' num2str(paramsdiv(popRank(i)).di) ' 陷入局部的代数：' num2str(paramsdiv(popRank(i)).do)]);
                [DivPop{popRank(i)}, paramsdiv(popRank(i))] = ReplacePop(paramsdiv(popRank(i)), popRank(i), empty_individual, nVar, improved_circle_flag, info, F_s, F_sSum);
                F_f{popRank(i)} = [];F_s{popRank(i)} = [];
                params.New = true;
                lineNum = lineNum + 1;  % 线的数目加1
                replaceLine(lineNum) = struct('it', it, 'popNum', popRank(i), 'flag', 2);   % 替换代数为it，种群编号为popRank(i)，替换原因为新陈代谢
            end
        else
            paramsdiv(popRank(i)).do = 1;
        end
    end
     
    % 生态占位
    if params.New ~= true
        Content_DI = [paramsdiv.di] >= params.DI;    % 不受若幼保护的位置置为1    
        [~, num] = find(Content_DI == 1);       % 找到不受若幼保护的种群编号
        if length(num) >= 2
            mid = randperm(length(num));        % 获得随机数列
             % 判断是否发生生态占位
             numReplace = 0;    % 若发生占位,取代的是mid(1),则置为1，取代的是mid(2),置为2,不发生占位,则为0
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
                if judge == true    % 发生生态占位，需要替换群体
                    [DivPop{num(mid(numReplace))}, paramsdiv(num(mid(numReplace)))] = ReplacePop(paramsdiv(num(mid(numReplace))), num(mid(numReplace)), empty_individual, nVar, improved_circle_flag, info, F_s, F_sSum);
                end
             end
             if numReplace ~= 0
                disp(['第' num2str(it) '代：' num2str(num(mid(numReplace))) '种群占位被取代 ' num2str(num(mid(3 - numReplace))) '种群留下']);
                F_f{num(mid(numReplace))} = [];F_s{num(mid(numReplace))} = [];
                lineNum = lineNum + 1;  % 线的数目加1
                replaceLine(lineNum) = struct('it', it, 'popNum', num(mid(numReplace)), 'flag', 3);   % 替换代数为it，种群编号为popRank(i)，替换原因为新陈代谢
             end
        end
    end    
    
    % 对三个子群分别操作
    for i = 1 : params.popDivNum
        [DivPop{i}, F{i}, paramsdiv(i)] = GetNextPop(i, DivPop{i}, paramsdiv(i), empty_individual, info);
        divPopQuantity(i + 1,it + 1) = paramsdiv(i).nPop;   % 存储亚种群的规模
    end
    
    Tem = Tem * deltaT;
    % 更新最优档案集
    for i = 1 : params.popDivNum
        elite_pool = [elite_pool; DivPop{i}(F{i}{1})];  %#ok      % 每个子群体的最优前沿进入最优档案集中
    end
    elite_pool = RemoveDuplicate(elite_pool, 'Order');      % 去重复解
    params_elite.nPop = length(elite_pool);
    [elite_pool, F_elite, params_elite] = SortAndSelectPopulation(elite_pool, params_elite);    % 最优档案集进行非支配排序
    elite_pool = elite_pool(F_elite{1});            % 取其最优前沿的个体
	sBestNum(1, it + 1) = length(elite_pool);           % 最优集合中的个体数目
    
    Cost = [elite_pool.Cost]';      % 适应度值
    [~, ia, ~] = unique(Cost, 'rows');
    fBestNum(1, it + 1) = length(ia);    % 适应度值的个数
    FPareto = Cost(ia);
    
    % 记录最优前沿（适应度值），若前沿变化，则得到更优的前沿
	if ~isequal(FPareto, FParetoBest)
        bestFIt = it;
        bestFTime = toc;
        FParetoBest = FPareto;
	end
    
    % 记录最优前沿，若前沿变化，则得到更优的前沿
    if ~Pareto_Compare(best_Pareto_front,elite_pool)
        best_Pareto_front = elite_pool;
        best_it = it;
        best_time = toc;
    end

    
    F_best = elite_pool;          % 评估群体中的最优解 
    Cost = [F_best.Cost];
    [~,order] = sort(Cost(2,:));   % 按照第一个代价函数值排序
    F_best = F_best(order);
    twoMin(it + 1) = F_best(1).Cost(2);
    
    F_best = elite_pool;          % 评估群体中的最优解 
    Cost = [F_best.Cost];
    [~,order] = sort(Cost(1,:));   % 按照第一个代价函数值排序
    F_best = F_best(order);
    oneMin(it + 1) = F_best(1).Cost(1);
    
    CostNor = [F_best.NormalizedCost]';
    CostNorWeight = [];
    CostNorWeight(1,:) = 0.5 * CostNor(:,1) + 0.5 * CostNor(:,2);
    [~,order] = sort(CostNorWeight);   % 排序
    CostNorWeight = CostNorWeight(order);
    
    weightSum(it + 1) = min((Cost(1, :) + Cost(2, :)) / 2);  % 加权和的最小值

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
