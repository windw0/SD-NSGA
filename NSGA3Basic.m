dbstop if error;  % 调试用。
tic     %记录时间
%% Problem Definition
bianliBasic = true;
info = input_info8();
info.calcu(info.SUPPLY_x, info.SUPPLY_y, info.SUPPLY_z);
nVar = info.ini.num_REQUEST;
CostFunction = @(x, y, z) GSSP_MOP2(x, y, z);  % Cost Function代价函数，进入MOP2中设置。输入参数可以改。

VarSize = [1 nVar]; % Size of Decision Variables Matrix决策变量矩阵的大小
% Number of Objective Functions目标函数的个数
a = randperm(nVar);
b = GenerateSupplyOrder(a, info.REQUEST, info.cons_MATERIAL);
nObj = numel(CostFunction(a, b, info));

%% NSGA Parameters
% Generating Reference Points
nDivision = 119; % 设置每一维上生成参考点的数量，可以更改。

Zr = GenerateReferencePoints(nObj, nDivision);  % 输出表示所有参考点坐标的矩阵。

paramsBasic = struct(...
    'maxGen', 200,...           % 最大代数
	'nPop', 120,...   % 种群大小
    'cross', 0.9,...
    'variation', 0.02,...
    'cross_method', 'MPX',...
    'variation_method', 'TPM',...
    'Zr', Zr,...
    'nZr',size(Zr, 2),...       % 得到生成的参考点的数量。
    'zmin', [],...
    'zmax', [],...
    'smin', []);         

elite_poolBasic = [];

% 最优档案集参数
params_eliteBasic = struct(...
    'nPop', 40,...              % 种群大小,运行中取其第一前沿的所有个体
    'Zr', Zr,...
    'nZr',size(Zr, 2),...       % 得到生成的参考点的数量。
    'zmin', [],...
    'zmax', [],...
    'smin', []);       

improved_circle_flag = false;  %是否使用改良圈
sBestNumBasic = zeros(1, paramsBasic.maxGen + 1);     % 存放每一代最优档案集中个体的数目
fBestNumBasic = zeros(1, paramsBasic.maxGen + 1);     % 存放每一代最优档案集中适应度值的数目

FParetoBestBasic = []; % 记录最优前沿
FParetoBasic = []; % 记录当前代的最优前沿

%% 加载遍历解
if bianliBasic == true
    load('design10task.mat', 'external_set')
    % 按第一个适应度值排序
    [~, orderFtBasic] = sort(external_set(:, 2 * nVar + 1));
    external_set(:, 1 : end) = external_set(orderFtBasic, 1 : end);

    % 真解：前一半代表工序，后一半代表供应点选择
    realSBasic = external_set(:, 1 : 2 * nVar);
    % 真值
    realFBasic = external_set(:, 2 * nVar + 1 : 2 * nVar + 2);   % 两个适应度值
    realFBasic = unique(realFBasic, 'row');       % 去重

    % 统计遍历中每一适应度值中解的个数
    eachSNumBasic = zeros(1, size(realFBasic, 1));   % 表示遍历得到的该列适应度值的个数
    k_erBasic = 1;
    for i = 1 : size(realFBasic, 1)
        while k_erBasic <= size(external_set, 1)
            if external_set(k_erBasic, 2 * nVar + 1) == realFBasic(i, 1)
                eachSNumBasic(i) = eachSNumBasic(i) + 1;
                k_erBasic = k_erBasic + 1;
            else
                break;
            end
        end
    end

    everyGenFindFBasic = zeros(1, paramsBasic.maxGen + 1);    % 记录每一代中找到的适应度值的个数
    everyGenFindSBasic = zeros(1, paramsBasic.maxGen + 1);    % 记录每一代中找到的适应度值的个数
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
thisGenerationBasic = GenerateNewPop(paramsBasic.nPop, 0, empty_individual, nVar, improved_circle_flag, info);
% Sort Population and Perform Selection 个体排序和选择操作
[thisGenerationBasic, FBasic, paramsBasic] = SortAndSelectPopulation(thisGenerationBasic, paramsBasic);


elite_poolBasic = [elite_poolBasic; thisGenerationBasic(FBasic{1})];  %#ok      % 每个子群体的最优前沿进入最优档案集中

elite_poolBasic = RemoveDuplicate(elite_poolBasic, 'Order');      % 去重复解
params_eliteBasic.nPop = length(elite_poolBasic);
[elite_poolBasic, F_eliteBasic, params_eliteBasic] = SortAndSelectPopulation(elite_poolBasic, params_eliteBasic);    % 最优档案集进行非支配排序
elite_poolBasic = elite_poolBasic(F_eliteBasic{1});            % 取其最优前沿的个体


% 更新帕累托前沿
F_bestBasic = elite_poolBasic;
sBestNumBasic(1, 1) = length(F_bestBasic);    % 存放初代最优前沿中个体的数目

CostBasic = [F_bestBasic.Cost]';      % 适应度值
[~, ia, ~] = unique(CostBasic, 'rows');
fBestNumBasic(1, 1) = length(ia);    % 适应度值的个数

% 记录最优前沿(适应度值)以及出现的代数和时间
FParetoBestBasic = CostBasic(ia);
bestFItBasic = 0;
bestFTimeBasic = toc;

% 记录最优前沿以及出现的代数和时间
best_Pareto_front_Basic = F_bestBasic;
best_it_basic = 0;
best_time_basic = toc;

oneMinBasic = [];   % 第一适应度值的最小值
twoMinBasic = [];   % 第二适应度值的最小值
weightSumBasic = [];  % 存储加权和的最小值

CostBasic = [F_bestBasic.Cost];
[~,orderBasic] = sort(CostBasic(2,:));   % 按照第一个代价函数值排序
F_bestBasic = F_bestBasic(orderBasic);
twoMinBasic(1) = F_bestBasic(1).Cost(2);

CostBasic = [F_bestBasic.Cost];
[~,orderBasic] = sort(CostBasic(1,:));   % 按照第一个代价函数值排序
F_bestBasic = F_bestBasic(orderBasic);
oneMinBasic(1) = F_bestBasic(1).Cost(1);

weightSumBasic(1) = min((CostBasic(1, :) + CostBasic(2, :)) / 2);  % 加权和的最小值

if bianliBasic == true
    CostBasic = CostBasic';
    independBasic = unique(CostBasic, 'row'); 
	everyGenFindFBasic(1) = sum(ismember(independBasic, realFBasic, 'row'));
    independSBasic = zeros(length(F_bestBasic), 2 * nVar);
    for i = 1 : length(F_bestBasic)
        independSBasic(i, :) = [F_bestBasic(i).Order F_bestBasic(i).SupplyOrder];
    end
	everyGenFindSBasic(1) = sum(ismember(independSBasic, realSBasic, 'row'));
end


%% NSGA Main Loop
for it = 1 : paramsBasic.maxGen    % 对于每一代，进行交叉、变异、排序、选择、存储等操作。
    disp(['Iteration ' num2str(it)]);
    % 子代种群
    [thisGenerationBasic, FBasic, paramsBasic] = GetNextPopBasic(0, thisGenerationBasic, paramsBasic, empty_individual, info);
    
    % 更新最优档案集
	elite_poolBasic = [elite_poolBasic; thisGenerationBasic(FBasic{1})];  %#ok      % 每个子群体的最优前沿进入最优档案集中
    elite_poolBasic = RemoveDuplicate(elite_poolBasic, 'Order');      % 去重复解
    params_eliteBasic.nPop = length(elite_poolBasic);
    [elite_poolBasic, F_eliteBasic, params_eliteBasic] = SortAndSelectPopulation(elite_poolBasic, params_eliteBasic);    % 最优档案集进行非支配排序
    elite_poolBasic = elite_poolBasic(F_eliteBasic{1});            % 取其最优前沿的个体
    
    % 更新帕累托前沿
    F_bestBasic = elite_poolBasic;
    F_bestBasic = RemoveDuplicate(F_bestBasic, 'Order');      % 去重复解
    sBestNumBasic(1, it + 1) = length(F_bestBasic);
    
    CostBasic = [F_bestBasic.Cost]';      % 适应度值
    [~, ia, ~] = unique(CostBasic, 'rows');
    fBestNumBasic(1, it + 1) = length(ia);    % 适应度值的个数
    FParetoBasic = CostBasic(ia);

    % 记录最优前沿（适应度值），若前沿变化，则得到更优的前沿
	if ~isequal(FParetoBasic, FParetoBestBasic)
        bestFItBasic = it;
        bestFTimeBasic = toc;
        FParetoBestBasic = FParetoBasic;
	end
    
    if ~Pareto_Compare(best_Pareto_front_Basic, F_bestBasic)
        best_Pareto_front_Basic = F_bestBasic;
        best_it_basic = it;
        best_time_basic = toc;
    end
    
    CostBasic = [F_bestBasic.Cost];
    [~,orderBasic] = sort(CostBasic(2,:));   % 按照第一个代价函数值排序
    F_bestBasic = F_bestBasic(orderBasic);
    twoMinBasic(it + 1) = F_bestBasic(1).Cost(2);
    
    CostBasic = [F_bestBasic.Cost];
    [~,orderBasic] = sort(CostBasic(1,:));   % 按照第一个代价函数值排序
    F_bestBasic = F_bestBasic(orderBasic);
    oneMinBasic(it + 1) = F_bestBasic(1).Cost(1);
    
    weightSumBasic(it + 1) = min((CostBasic(1, :) + CostBasic(2, :)) / 2);  % 加权和的最小值
    
    if bianliBasic == true
        CostBasic = CostBasic';
        independBasic = unique(CostBasic, 'row'); 
        everyGenFindFBasic(it + 1) = sum(ismember(independBasic, realFBasic, 'row'));
        independSBasic = zeros(length(F_bestBasic), 2 * nVar);
        for i = 1 : length(F_bestBasic)
            independSBasic(i, :) = [F_bestBasic(i).Order F_bestBasic(i).SupplyOrder];
        end
        everyGenFindSBasic(it + 1) = sum(ismember(independSBasic, realSBasic, 'row'));
    end
    
    % Show Iteration Information
%     disp(['Iteration ' num2str(it) ': Number of F1 Members = ' num2str(numel(F_best))]);
end

endtimeBasic = toc;