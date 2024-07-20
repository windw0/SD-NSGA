tic     %��¼ʱ��
%% Problem Definition
bianliAver = true;
info = input_info8();
info.calcu(info.SUPPLY_x, info.SUPPLY_y, info.SUPPLY_z);
nVar = info.ini.num_REQUEST;
CostFunction = @(x, y, info) GSSP_MOP2(x, y, info);  % Cost Function���ۺ���������MOP2�����á�����������Ըġ�
VarSize = [1 nVar]; % Size of Decision Variables Matrix���߱�������Ĵ�С
a = randperm(nVar);
b = GenerateSupplyOrder(a, info.REQUEST, info.cons_MATERIAL);
nObj = numel(CostFunction(a, b, info)); % Number of Objective FunctionsĿ�꺯���ĸ���
%% NSGA Parameters
% Generating Reference Points���ɲο��㣬һ��������ֻ����һ�Ρ�
nDivisionAver = 39; % ����ÿһά�����ɲο�������������Ը��ġ�  
ZrAver = GenerateReferencePoints(nObj, nDivisionAver);  % �����ʾ���вο�������ľ���

% ��Ⱥ���ܲ���
paramsAver = struct(...
	'maxGen', 200,...           % ������
    'Pmax', 120,...             % ����Ⱥ������Ŀ�ʹ�С����Դ�㶨����
	'popDivNum', 3);          % Эͬ������Ⱥ��

paramsAverDefault.nPop = ceil(paramsAver.Pmax / paramsAver.popDivNum); % ����Ⱥ��С
paramsAverDefault.cross = 0.9;                           % �������
paramsAverDefault.variation = 0.02;                      % �������
paramsAverDefault.cross_method = 'MPX';                    % ����ƥ�佻�棨PMX����˳�򽻲棨OX������������棨MPX��
paramsAverDefault.variation_method = 'TPM';                % ���㻻λ���죨TPM�������ñ��죨RSM��RM�����������죨OIM����������죨ARM��PRM
paramsAverDefault.Zr = ZrAver;       
paramsAverDefault.nZr = size(ZrAver, 2);                     % �õ����ɵĲο����������
paramsAverDefault.zmin = [];
paramsAverDefault.zmax = [];
paramsAverDefault.smin = [];

paramsdivAver = repmat(paramsAverDefault, 1, paramsAver.popDivNum);
for i = 1 : paramsAver.popDivNum                            % ����ÿ����Ⱥ��Ĳ���
    paramsdivAver(i) = paramsAverDefault;
end
paramsdivAver(1).cross_method = 'MPX';
paramsdivAver(1).variation_method = 'RM';
paramsdivAver(2).cross_method = 'OX';
paramsdivAver(2).variation_method = 'PRM';
paramsdivAver(3).cross_method = 'PMX';
paramsdivAver(3).variation_method = 'TPM';


elite_poolAver = [];

% ���ŵ���������
params_eliteAver = struct(...
    'nPop', 40,...              % ��Ⱥ��С,������ȡ���һǰ�ص����и���
    'Zr', ZrAver,...
    'nZr',size(ZrAver, 2),...       % �õ����ɵĲο����������
    'zmin', [],...
    'zmax', [],...
    'smin', []);       

DivPopAver = cell(1, paramsAver.popDivNum); % ÿ������Ⱥ
FAver = cell(1, paramsAver.popDivNum);  % ÿ������Ⱥ�Ĳ�
uniqueIndivAver = cell(paramsAver.popDivNum, 2);    % ���ÿ����Ⱥ�Ķ������壨�������Ӧ��ֵ��

improved_circle_flagAver = false;  %�Ƿ�ʹ�ø���Ȧ

sBestNumAver = zeros(1, paramsAver.maxGen + 1);     % ���ÿһ�����ŵ������и������Ŀ
fBestNumAver = zeros(1, paramsAver.maxGen + 1);     % ���ÿһ�����ŵ������и������Ŀ

FParetoBestAver = []; % ��¼ǰһ��������ǰ��
FParetoAver = []; % ��¼��ǰ��������ǰ��


%% ���ر�����
if bianliAver == true
    load('design10task.mat', 'external_set')
    % ����һ����Ӧ��ֵ����
    [~, orderFtAver] = sort(external_set(:, 2 * nVar + 1));
    external_set(:, 1 : end) = external_set(orderFtAver, 1 : end);

    % ��⣺ǰһ������򣬺�һ�����Ӧ��ѡ��
    realSAver = external_set(:, 1 : 2 * nVar);
    % ��ֵ
    realFAver = external_set(:, 2 * nVar + 1 : 2 * nVar + 2);   % ������Ӧ��ֵ
    realFAver = unique(realFAver, 'row');       % ȥ��

    % ͳ�Ʊ�����ÿһ��Ӧ��ֵ�н�ĸ���
    eachSNumAver = zeros(1, size(realFAver, 1));   % ��ʾ�����õ��ĸ�����Ӧ��ֵ�ĸ���
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

    everyGenFindFAver = zeros(1, paramsAver.maxGen + 1);    % ��¼ÿһ�����ҵ�����Ӧ��ֵ�ĸ���
    everyGenFindSAver = zeros(1, paramsAver.maxGen + 1);    % ��¼ÿһ�����ҵ�����Ӧ��ֵ�ĸ���
end



%% Initialization
disp('Starting NSGA-III ...');
% ��ÿ��������й���Ϣ�������Ϊempty_individual�Ľṹ����
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
% ��ʼ����Ⱥ
thisGenerationAver = GenerateNewPop(paramsAver.Pmax, 0, empty_individualAver, nVar, improved_circle_flagAver, info);

% ��Ϊ������Ⱥ
for i = 1 : paramsAver.popDivNum
    DivPopAver{i} = thisGenerationAver((i - 1) *  paramsdivAver(i).nPop + 1 : i * paramsdivAver(i).nPop); % ��ʼ��ʱ��Ϊparams.nPop / params.popDivNum��
    for j = 1 : paramsdivAver(i).nPop
        DivPopAver{i}(j).PopNum = i;    % ��¼ÿ��������������Ⱥ��
    end
	[DivPopAver{i}, FAver{i}, paramsdivAver(i)] = SortAndSelectPopulation(DivPopAver{i}, paramsdivAver(i));     % �Ը�������Ⱥ���з�֧�����򣬴˴�δѡ��
end

% �������ŵ�����
for i = 1 : paramsAver.popDivNum
    elite_poolAver = [elite_poolAver; DivPopAver{i}(FAver{i}{1})];  %#ok      % ÿ����Ⱥ�������ǰ�ؽ������ŵ�������
end
elite_poolAver = RemoveDuplicate(elite_poolAver, 'Order');      % ȥ�ظ���
params_eliteAver.nPop = length(elite_poolAver);
[elite_poolAver, F_elite, params_eliteAver] = SortAndSelectPopulation(elite_poolAver, params_eliteAver);    % ���ŵ��������з�֧������
elite_poolAver = elite_poolAver(F_elite{1});            % ȡ������ǰ�صĸ���
sBestNumAver(1) = length(elite_poolAver);           % ���ż����еĸ�����Ŀ

CostAver = [elite_poolAver.Cost]';      % ��Ӧ��ֵ
[~, ia, ~] = unique(CostAver, 'rows');
fBestNumAver(1) = length(ia);    % ��Ӧ��ֵ�ĸ���

% ��¼����ǰ��(��Ӧ��ֵ)�Լ����ֵĴ�����ʱ��
FParetoBestAver = CostAver(ia);
bestFItAver = 0;
bestFTimeAver = toc;

% ��¼����ǰ���Լ����ֵĴ�����ʱ��
best_Pareto_frontAver = elite_poolAver;
best_itAver = 0;
best_timeAver = toc;

oneMinAver = [];    % ��һ����Ӧ��ֵ����Сֵ
twoMinAver = [];    % �ڶ�����Ӧ��ֵ����Сֵ
weightSumAver = []; % ��Ȩ��Ӧ��ֵ����Сֵ

F_bestAver = elite_poolAver;          % ����Ⱥ���е����Ž� 
CostAver = [F_bestAver.Cost];
[~,orderAver] = sort(CostAver(2,:));   % ���յ�һ�����ۺ���ֵ����
F_bestAver = F_bestAver(orderAver);
twoMinAver(1) = F_bestAver(1).Cost(2);


F_bestAver = elite_poolAver;          % ����Ⱥ���е����Ž� 
CostAver = [F_bestAver.Cost];
[~,orderAver] = sort(CostAver(1,:));   % ���յ�һ�����ۺ���ֵ����
F_bestAver = F_bestAver(orderAver);
oneMinAver(1) = F_bestAver(1).Cost(1);

weightSumAver(1) = min((CostAver(1, :) + CostAver(2, :)) / 2);  % ��Ȩ�͵���Сֵ

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



%% NSGA Main Loop������������
for it = 1 : paramsAver.maxGen
    disp(['Iteration ' num2str(it)]);
    % ��������Ⱥ�ֱ����
    for i = 1 : paramsAver.popDivNum
        [DivPopAver{i}, FAver{i}, paramsdivAver(i)] = GetNextPopBasic(i, DivPopAver{i}, paramsdivAver(i), empty_individualAver, info);
    end
    % �������ŵ�����
    for i = 1 : paramsAver.popDivNum
        elite_poolAver = [elite_poolAver; DivPopAver{i}(FAver{i}{1})];  %#ok      % ÿ����Ⱥ�������ǰ�ؽ������ŵ�������
    end
    elite_poolAver = RemoveDuplicate(elite_poolAver, 'Order');      % ȥ�ظ���
    params_eliteAver.nPop = length(elite_poolAver);
    [elite_poolAver, F_elite, params_eliteAver] = SortAndSelectPopulation(elite_poolAver, params_eliteAver);    % ���ŵ��������з�֧������
    elite_poolAver = elite_poolAver(F_elite{1});            % ȡ������ǰ�صĸ���
	sBestNumAver(it + 1) = length(elite_poolAver);           % ���ż����еĸ�����Ŀ
    
    CostAver = [elite_poolAver.Cost]';      % ��Ӧ��ֵ
    [~, ia, ~] = unique(CostAver, 'rows');
    fBestNumAver(it + 1) = length(ia);    % ��Ӧ��ֵ�ĸ���
    FParetoAver = CostAver(ia);

    % ��¼����ǰ�أ���ǰ�ر仯����õ����ŵ�ǰ��
    if ~Pareto_Compare(best_Pareto_frontAver,elite_poolAver)
        best_Pareto_frontAver = elite_poolAver;
        best_itAver = it;
        best_timeAver = toc;
    end
    % ��¼����ǰ�أ���Ӧ��ֵ������ǰ�ر仯����õ����ŵ�ǰ��
    if ~isequal(FParetoAver, FParetoBestAver)
        bestFItAver = it;
        bestFTimeAver = toc;
        FParetoBestAver = FParetoAver;
    end
    
    F_bestAver = elite_poolAver;          % ����Ⱥ���е����Ž� 
    CostAver = [F_bestAver.Cost];
    [~,orderAver] = sort(CostAver(2,:));   % ���յ�һ�����ۺ���ֵ����
    F_bestAver = F_bestAver(orderAver);
    twoMinAver(it + 1) = F_bestAver(1).Cost(2);
    
    F_bestAver = elite_poolAver;          % ����Ⱥ���е����Ž� 
    CostAver = [F_bestAver.Cost];
    [~,orderAver] = sort(CostAver(1,:));   % ���յ�һ�����ۺ���ֵ����
    F_bestAver = F_bestAver(orderAver);
    oneMinAver(it + 1) = F_bestAver(1).Cost(1);
    
    weightSumAver(it + 1) = min((CostAver(1, :) + CostAver(2, :)) / 2); %��it����Ȩ�͵���Сֵ
    
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