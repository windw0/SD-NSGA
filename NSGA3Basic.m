dbstop if error;  % �����á�
tic     %��¼ʱ��
%% Problem Definition
bianliBasic = true;
info = input_info8();
info.calcu(info.SUPPLY_x, info.SUPPLY_y, info.SUPPLY_z);
nVar = info.ini.num_REQUEST;
CostFunction = @(x, y, z) GSSP_MOP2(x, y, z);  % Cost Function���ۺ���������MOP2�����á�����������Ըġ�

VarSize = [1 nVar]; % Size of Decision Variables Matrix���߱�������Ĵ�С
% Number of Objective FunctionsĿ�꺯���ĸ���
a = randperm(nVar);
b = GenerateSupplyOrder(a, info.REQUEST, info.cons_MATERIAL);
nObj = numel(CostFunction(a, b, info));

%% NSGA Parameters
% Generating Reference Points
nDivision = 119; % ����ÿһά�����ɲο�������������Ը��ġ�

Zr = GenerateReferencePoints(nObj, nDivision);  % �����ʾ���вο�������ľ���

paramsBasic = struct(...
    'maxGen', 200,...           % ������
	'nPop', 120,...   % ��Ⱥ��С
    'cross', 0.9,...
    'variation', 0.02,...
    'cross_method', 'MPX',...
    'variation_method', 'TPM',...
    'Zr', Zr,...
    'nZr',size(Zr, 2),...       % �õ����ɵĲο����������
    'zmin', [],...
    'zmax', [],...
    'smin', []);         

elite_poolBasic = [];

% ���ŵ���������
params_eliteBasic = struct(...
    'nPop', 40,...              % ��Ⱥ��С,������ȡ���һǰ�ص����и���
    'Zr', Zr,...
    'nZr',size(Zr, 2),...       % �õ����ɵĲο����������
    'zmin', [],...
    'zmax', [],...
    'smin', []);       

improved_circle_flag = false;  %�Ƿ�ʹ�ø���Ȧ
sBestNumBasic = zeros(1, paramsBasic.maxGen + 1);     % ���ÿһ�����ŵ������и������Ŀ
fBestNumBasic = zeros(1, paramsBasic.maxGen + 1);     % ���ÿһ�����ŵ���������Ӧ��ֵ����Ŀ

FParetoBestBasic = []; % ��¼����ǰ��
FParetoBasic = []; % ��¼��ǰ��������ǰ��

%% ���ر�����
if bianliBasic == true
    load('design10task.mat', 'external_set')
    % ����һ����Ӧ��ֵ����
    [~, orderFtBasic] = sort(external_set(:, 2 * nVar + 1));
    external_set(:, 1 : end) = external_set(orderFtBasic, 1 : end);

    % ��⣺ǰһ������򣬺�һ�����Ӧ��ѡ��
    realSBasic = external_set(:, 1 : 2 * nVar);
    % ��ֵ
    realFBasic = external_set(:, 2 * nVar + 1 : 2 * nVar + 2);   % ������Ӧ��ֵ
    realFBasic = unique(realFBasic, 'row');       % ȥ��

    % ͳ�Ʊ�����ÿһ��Ӧ��ֵ�н�ĸ���
    eachSNumBasic = zeros(1, size(realFBasic, 1));   % ��ʾ�����õ��ĸ�����Ӧ��ֵ�ĸ���
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

    everyGenFindFBasic = zeros(1, paramsBasic.maxGen + 1);    % ��¼ÿһ�����ҵ�����Ӧ��ֵ�ĸ���
    everyGenFindSBasic = zeros(1, paramsBasic.maxGen + 1);    % ��¼ÿһ�����ҵ�����Ӧ��ֵ�ĸ���
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
thisGenerationBasic = GenerateNewPop(paramsBasic.nPop, 0, empty_individual, nVar, improved_circle_flag, info);
% Sort Population and Perform Selection ���������ѡ�����
[thisGenerationBasic, FBasic, paramsBasic] = SortAndSelectPopulation(thisGenerationBasic, paramsBasic);


elite_poolBasic = [elite_poolBasic; thisGenerationBasic(FBasic{1})];  %#ok      % ÿ����Ⱥ�������ǰ�ؽ������ŵ�������

elite_poolBasic = RemoveDuplicate(elite_poolBasic, 'Order');      % ȥ�ظ���
params_eliteBasic.nPop = length(elite_poolBasic);
[elite_poolBasic, F_eliteBasic, params_eliteBasic] = SortAndSelectPopulation(elite_poolBasic, params_eliteBasic);    % ���ŵ��������з�֧������
elite_poolBasic = elite_poolBasic(F_eliteBasic{1});            % ȡ������ǰ�صĸ���


% ����������ǰ��
F_bestBasic = elite_poolBasic;
sBestNumBasic(1, 1) = length(F_bestBasic);    % ��ų�������ǰ���и������Ŀ

CostBasic = [F_bestBasic.Cost]';      % ��Ӧ��ֵ
[~, ia, ~] = unique(CostBasic, 'rows');
fBestNumBasic(1, 1) = length(ia);    % ��Ӧ��ֵ�ĸ���

% ��¼����ǰ��(��Ӧ��ֵ)�Լ����ֵĴ�����ʱ��
FParetoBestBasic = CostBasic(ia);
bestFItBasic = 0;
bestFTimeBasic = toc;

% ��¼����ǰ���Լ����ֵĴ�����ʱ��
best_Pareto_front_Basic = F_bestBasic;
best_it_basic = 0;
best_time_basic = toc;

oneMinBasic = [];   % ��һ��Ӧ��ֵ����Сֵ
twoMinBasic = [];   % �ڶ���Ӧ��ֵ����Сֵ
weightSumBasic = [];  % �洢��Ȩ�͵���Сֵ

CostBasic = [F_bestBasic.Cost];
[~,orderBasic] = sort(CostBasic(2,:));   % ���յ�һ�����ۺ���ֵ����
F_bestBasic = F_bestBasic(orderBasic);
twoMinBasic(1) = F_bestBasic(1).Cost(2);

CostBasic = [F_bestBasic.Cost];
[~,orderBasic] = sort(CostBasic(1,:));   % ���յ�һ�����ۺ���ֵ����
F_bestBasic = F_bestBasic(orderBasic);
oneMinBasic(1) = F_bestBasic(1).Cost(1);

weightSumBasic(1) = min((CostBasic(1, :) + CostBasic(2, :)) / 2);  % ��Ȩ�͵���Сֵ

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
for it = 1 : paramsBasic.maxGen    % ����ÿһ�������н��桢���졢����ѡ�񡢴洢�Ȳ�����
    disp(['Iteration ' num2str(it)]);
    % �Ӵ���Ⱥ
    [thisGenerationBasic, FBasic, paramsBasic] = GetNextPopBasic(0, thisGenerationBasic, paramsBasic, empty_individual, info);
    
    % �������ŵ�����
	elite_poolBasic = [elite_poolBasic; thisGenerationBasic(FBasic{1})];  %#ok      % ÿ����Ⱥ�������ǰ�ؽ������ŵ�������
    elite_poolBasic = RemoveDuplicate(elite_poolBasic, 'Order');      % ȥ�ظ���
    params_eliteBasic.nPop = length(elite_poolBasic);
    [elite_poolBasic, F_eliteBasic, params_eliteBasic] = SortAndSelectPopulation(elite_poolBasic, params_eliteBasic);    % ���ŵ��������з�֧������
    elite_poolBasic = elite_poolBasic(F_eliteBasic{1});            % ȡ������ǰ�صĸ���
    
    % ����������ǰ��
    F_bestBasic = elite_poolBasic;
    F_bestBasic = RemoveDuplicate(F_bestBasic, 'Order');      % ȥ�ظ���
    sBestNumBasic(1, it + 1) = length(F_bestBasic);
    
    CostBasic = [F_bestBasic.Cost]';      % ��Ӧ��ֵ
    [~, ia, ~] = unique(CostBasic, 'rows');
    fBestNumBasic(1, it + 1) = length(ia);    % ��Ӧ��ֵ�ĸ���
    FParetoBasic = CostBasic(ia);

    % ��¼����ǰ�أ���Ӧ��ֵ������ǰ�ر仯����õ����ŵ�ǰ��
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
    [~,orderBasic] = sort(CostBasic(2,:));   % ���յ�һ�����ۺ���ֵ����
    F_bestBasic = F_bestBasic(orderBasic);
    twoMinBasic(it + 1) = F_bestBasic(1).Cost(2);
    
    CostBasic = [F_bestBasic.Cost];
    [~,orderBasic] = sort(CostBasic(1,:));   % ���յ�һ�����ۺ���ֵ����
    F_bestBasic = F_bestBasic(orderBasic);
    oneMinBasic(it + 1) = F_bestBasic(1).Cost(1);
    
    weightSumBasic(it + 1) = min((CostBasic(1, :) + CostBasic(2, :)) / 2);  % ��Ȩ�͵���Сֵ
    
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