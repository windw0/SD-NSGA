tic     %记录时间
%% Problem Definition
bianliAver = true;
info = input_info8();
info.calcu(info.SUPPLY_x, info.SUPPLY_y, info.SUPPLY_z);
nVar = info.ini.num_REQUEST;
CostFunction = @(x, y, info) GSSP_MOP2(x, y, info);  % Cost Function代价函数，进入MOP2中设置。输入参数可以改。
VarSize = [1 nVar]; % Size of Decision Variables Matrix决策变量矩阵的大小
a = randperm(nVar);
b = GenerateSupplyOrder(a, info.REQUEST, info.cons_MATERIAL);
nObj = numel(CostFunction(a, b, info)); % Number of Objective Functions目标函数的个数
%% NSGA Parameters
% Generating Reference Points生成参考点，一次运行中只生成一次。
nDivisionAver = 39; % 设置每一维上生成参考点的数量，可以更改。  
ZrAver = GenerateReferencePoints(nObj, nDivisionAver);  % 输出表示所有参考点坐标的矩阵。

% 种群的总参数
paramsAver = struct(...
	'maxGen', 200,...           % 最大代数
    'Pmax', 120,...             % 子种群个体数目和大小，资源恒定法则
	'popDivNum', 3);          % 协同进化种群数

paramsAverDefault.nPop = ceil(paramsAver.Pmax / paramsAver.popDivNum); % 子种群大小
paramsAverDefault.cross = 0.9;                           % 交叉概率
paramsAverDefault.variation = 0.02;                      % 变异概率
paramsAverDefault.cross_method = 'MPX';                    % 部分匹配交叉（PMX）、顺序交叉（OX）、最大保留交叉（MPX）
paramsAverDefault.variation_method = 'TPM';                % 两点换位变异（TPM）、重置变异（RSM）RM、单点插入变异（OIM）、倒序变异（ARM）PRM
paramsAverDefault.Zr = ZrAver;       
paramsAverDefault.nZr = size(ZrAver, 2);                     % 得到生成的参考点的数量。
paramsAverDefault.zmin = [];
paramsAverDefault.zmax = [];
paramsAverDefault.smin = [];

paramsdivAver = repmat(paramsAverDefault, 1, paramsAver.popDivNum);
for i = 1 : paramsAver.popDivNum                            % 定义每个子群体的参数
    paramsdivAver(i) = paramsAverDefault;
end
paramsdivAver(1).cross_method = 'MPX';
paramsdivAver(1).variation_method = 'RM';
paramsdivAver(2).cross_method = 'OX';
paramsdivAver(2).variation_method = 'PRM';
paramsdivAver(3).cross_method = 'PMX';
paramsdivAver(3).variation_method = 'TPM';


elite_poolAver = [];

% 最优档案集参数
params_eliteAver = struct(...
    'nPop', 40,...              % 种群大小,运行中取其第一前沿的所有个体
    'Zr', ZrAver,...
    'nZr',size(ZrAver, 2),...       % 得到生成的参考点的数量。
    'zmin', [],...
    'zmax', [],...
    'smin', []);       

DivPopAver = cell(1, paramsAver.popDivNum); % 每个亚种群
FAver = cell(1, paramsAver.popDivNum);  % 每个亚种群的层
uniqueIndivAver = cell(paramsAver.popDivNum, 2);    % 存放每各种群的独立个体（编码和适应度值）

improved_circle_flagAver = false;  %是否使用改良圈

sBestNumAver = zeros(1, paramsAver.maxGen + 1);     % 存放每一代最优档案集中个体的数目
fBestNumAver = zeros(1, paramsAver.maxGen + 1);     % 存放每一代最优档案集中个体的数目

FParetoBestAver = []; % 记录前一代的最优前沿
FParetoAver = []; % 记录当前代的最优前沿


%% 加载遍历解
if bianliAver == true
    load('design10task.mat', 'external_set')
    % 按第一个适应度值排序
    [~, orderFtAver] = sort(external_set(:, 2 * nVar + 1));
    external_set(:, 1 : end) = external_set(orderFtAver, 1 : end);

    % 真解：前一半代表工序，后一半代表供应点选择
    realSAver = external_set(:, 1 : 2 * nVar);
    % 真值
    realFAver = external_set(:, 2 * nVar + 1 : 2 * nVar + 2);   % 两个适应度值
    realFAver = unique(realFAver, 'row');       % 去重

    % 统计遍历中每一适应度值中解的个数
    eachSNumAver = zeros(1, size(realFAver, 1));   % 表示遍历得到的该列适应度值的个数
    k_erAver = 1;
    for i = 1 : size(realFAver, 1)
        while k_erAver <= size(external_set, 1)
            if external_set(k_erAver, 2 * nVar + 1) == realFAver(i, 1)
                eachSNumAver(i) = eachSNumAver(i) + 1;
                k_erAver = k_erAver + 1;
            else
                break;
            end
        end
    end

    everyGenFindFAver = zeros(1, paramsAver.maxGen + 1);    % 记录每一代中找到的适应度值的个数
    everyGenFindSAver = zeros(1, paramsAver.maxGen + 1);    % 记录每一代中找到的适应度值的个数
end



%% Initialization
disp('Starting NSGA-III ...');
% 将每个个体的有关信息存放在名为empty_individual的结构体中
empty_individualAver.Order = [];
empty_individualAver.SupplyOrder = [];
empty_individualAver.Cost = [];
empty_individualAver.Rank = [];
empty_individualAver.DominationSet = [];
empty_individualAver.DominatedCount = [];
empty_individualAver.NormalizedCost = [];
empty_individualAver.AssociatedRef = [];
empty_individualAver.DistanceToAssociatedRef = [];
empty_individualAver.PopNum = [];
% 初始化种群
thisGenerationAver = GenerateNewPop(paramsAver.Pmax, 0, empty_individualAver, nVar, improved_circle_flagAver, info);

% 分为三个种群
for i = 1 : paramsAver.popDivNum
    DivPopAver{i} = thisGenerationAver((i - 1) *  paramsdivAver(i).nPop + 1 : i * paramsdivAver(i).nPop); % 初始化时都为params.nPop / params.popDivNum个
    for j = 1 : paramsdivAver(i).nPop
        DivPopAver{i}(j).PopNum = i;    % 记录每个个体所属的子群体
    end
	[DivPopAver{i}, FAver{i}, paramsdivAver(i)] = SortAndSelectPopulation(DivPopAver{i}, paramsdivAver(i));     % 对各个亚种群进行非支配排序，此处未选择
end

% 更新最优档案集
for i = 1 : paramsAver.popDivNum
    elite_poolAver = [elite_poolAver; DivPopAver{i}(FAver{i}{1})];  %#ok      % 每个子群体的最优前沿进入最优档案集中
end
elite_poolAver = RemoveDuplicate(elite_poolAver, 'Order');      % 去重复解
params_eliteAver.nPop = length(elite_poolAver);
[elite_poolAver, F_elite, params_eliteAver] = SortAndSelectPopulation(elite_poolAver, params_eliteAver);    % 最优档案集进行非支配排序
elite_poolAver = elite_poolAver(F_elite{1});            % 取其最优前沿的个体
sBestNumAver(1) = length(elite_poolAver);           % 最优集合中的个体数目

CostAver = [elite_poolAver.Cost]';      % 适应度值
[~, ia, ~] = unique(CostAver, 'rows');
fBestNumAver(1) = length(ia);    % 适应度值的个数

% 记录最优前沿(适应度值)以及出现的代数和时间
FParetoBestAver = CostAver(ia);
bestFItAver = 0;
bestFTimeAver = toc;

% 记录最优前沿以及出现的代数和时间
best_Pareto_frontAver = elite_poolAver;
best_itAver = 0;
best_timeAver = toc;

oneMinAver = [];    % 第一个适应度值的最小值
twoMinAver = [];    % 第二个适应度值的最小值
weightSumAver = []; % 加权适应度值的最小值

F_bestAver = elite_poolAver;          % 评估群体中的最优解 
CostAver = [F_bestAver.Cost];
[~,orderAver] = sort(CostAver(2,:));   % 按照第一个代价函数值排序
F_bestAver = F_bestAver(orderAver);
twoMinAver(1) = F_bestAver(1).Cost(2);


F_bestAver = elite_poolAver;          % 评估群体中的最优解 
CostAver = [F_bestAver.Cost];
[~,orderAver] = sort(CostAver(1,:));   % 按照第一个代价函数值排序
F_bestAver = F_bestAver(orderAver);
oneMinAver(1) = F_bestAver(1).Cost(1);

weightSumAver(1) = min((CostAver(1, :) + CostAver(2, :)) / 2);  % 加权和的最小值

if bianliAver == true
    CostAver = CostAver';
    independFAver = unique(CostAver, 'row'); 
	everyGenFindFAver(1) = sum(ismember(independFAver, realFAver, 'row'));
    independSAver = zeros(length(elite_poolAver), 2 * nVar);
    for i = 1 : length(elite_poolAver)
        independSAver(i, :) = [elite_poolAver(i).Order elite_poolAver(i).SupplyOrder];
    end
	everyGenFindSAver(1) = sum(ismember(independSAver, realSAver, 'row'));
end



%% NSGA Main Loop，迭代主程序
for it = 1 : paramsAver.maxGen
    disp(['Iteration ' num2str(it)]);
    % 对三个子群分别操作
    for i = 1 : paramsAver.popDivNum
        [DivPopAver{i}, FAver{i}, paramsdivAver(i)] = GetNextPopBasic(i, DivPopAver{i}, paramsdivAver(i), empty_individualAver, info);
    end
    % 更新最优档案集
    for i = 1 : paramsAver.popDivNum
        elite_poolAver = [elite_poolAver; DivPopAver{i}(FAver{i}{1})];  %#ok      % 每个子群体的最优前沿进入最优档案集中
    end
    elite_poolAver = RemoveDuplicate(elite_poolAver, 'Order');      % 去重复解
    params_eliteAver.nPop = length(elite_poolAver);
    [elite_poolAver, F_elite, params_eliteAver] = SortAndSelectPopulation(elite_poolAver, params_eliteAver);    % 最优档案集进行非支配排序
    elite_poolAver = elite_poolAver(F_elite{1});            % 取其最优前沿的个体
	sBestNumAver(it + 1) = length(elite_poolAver);           % 最优集合中的个体数目
    
    CostAver = [elite_poolAver.Cost]';      % 适应度值
    [~, ia, ~] = unique(CostAver, 'rows');
    fBestNumAver(it + 1) = length(ia);    % 适应度值的个数
    FParetoAver = CostAver(ia);

    % 记录最优前沿，若前沿变化，则得到更优的前沿
    if ~Pareto_Compare(best_Pareto_frontAver,elite_poolAver)
        best_Pareto_frontAver = elite_poolAver;
        best_itAver = it;
        best_timeAver = toc;
    end
    % 记录最优前沿（适应度值），若前沿变化，则得到更优的前沿
    if ~isequal(FParetoAver, FParetoBestAver)
        bestFItAver = it;
        bestFTimeAver = toc;
        FParetoBestAver = FParetoAver;
    end
    
    F_bestAver = elite_poolAver;          % 评估群体中的最优解 
    CostAver = [F_bestAver.Cost];
    [~,orderAver] = sort(CostAver(2,:));   % 按照第一个代价函数值排序
    F_bestAver = F_bestAver(orderAver);
    twoMinAver(it + 1) = F_bestAver(1).Cost(2);
    
    F_bestAver = elite_poolAver;          % 评估群体中的最优解 
    CostAver = [F_bestAver.Cost];
    [~,orderAver] = sort(CostAver(1,:));   % 按照第一个代价函数值排序
    F_bestAver = F_bestAver(orderAver);
    oneMinAver(it + 1) = F_bestAver(1).Cost(1);
    
    weightSumAver(it + 1) = min((CostAver(1, :) + CostAver(2, :)) / 2); %第it代加权和的最小值
    
    if bianliAver == true
        CostAver = CostAver';
        independFAver = unique(CostAver, 'row'); 
        everyGenFindFAver(it + 1) = sum(ismember(independFAver, realFAver, 'row'));
        independSAver = zeros(length(elite_poolAver), 2 * nVar);
        for i = 1 : length(elite_poolAver)
            independSAver(i, :) = [elite_poolAver(i).Order elite_poolAver(i).SupplyOrder];
        end
        everyGenFindSAver(it + 1) = sum(ismember(independSAver, realSAver, 'row'));
    end
    
    
end
endtimeAver = toc;