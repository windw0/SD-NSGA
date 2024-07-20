%% 设计算例

classdef input_info8<handle
    %% 属性
    properties
    % 参数
        ini = struct(...
            'num_SUPPLY', 3,...     % 供应点个数
            'num_DEMAND', 5,...     % 需求点个数
            'num_MATERIAL', 4,...   % 物料种类
            'num_REQUEST', 10,...   % 任务个数
            'num_BUILDING', 3,...   % 建筑物的数量（包含塔吊基座）
            'num_FACILITY', 4,...   % 施工设施的数量
            'tower_init_pos_in_demand', 1,...   % 塔吊初始位置在第n个需求点
            'hs', 2,...             % 安全高度
            'v_rho', 0.62,...          % 负载变幅速度(m/s) （原来：1） 负载速度为一半
            'v_theta', 0.03,...   % 负载回转速度（rad/s）（原来：0.0083） 负载速度为一半
            'v_height', 0.83,...    % 负载卷扬速度(m/s) （原来：2.27）负载速度为一半
            'miu', 1,...            % 工况系数
            'tao', 0.24,...         % 水平协调系数
            'yita', 1,...           % 横纵协调系数
            't_load', 1,...         % 装货时间
            't_unload', 1,...       % 卸货时间
            'tower_pos', [0  0  0],...  % 塔初始位置
            'tower_dd', 10,...      % 塔基座识别距离
            'radius', 63);          % 塔吊吊臂长度

    % 供应点信息
        empty_SUPPLY = struct(...
            'pos1', [],...      % 直角坐标
            'pos2', [],...      % 柱坐标
            'length', [],...
            'width', [],...
            'boundary_x', [],...
            'boundary_y', []);
         
        SUPPLY = [];
        
        SUPPLY_x =  [22.98     -7.36     -11.17];
        SUPPLY_y =  [20.02     -14.21      3.95];
        SUPPLY_z = [0 0 0 0];
        SUPPLY_length = [10 12 6 6];
        SUPPLY_width = [14 6 6 8];
        
	% 需求点信息
        empty_DEMAND = struct(...
            'pos1', [],...      % 直角坐标
            'pos2', []);        % 柱坐标
        DEMAND = [];
        DEMAND_x = [-40     -25     -10     20     20];
        DEMAND_y = [20       20      26     0      -20];
        DEMAND_z = [15.6 15.6 15.6 9.46 9.46];
        
	% 任务信息
        empty_REQUEST = struct(...
            'demand', [],...    % 需求点  
            'material', [],...  % 需求物料种类  
            'material_quantity', [],... % 需求物料量
            'supply', [],...    % 供应点选择（目前测试，直接给出）
            'time', [],...      % 任务执行时间
            'limit_time', [])   % 任务限定的结束时间
        
        REQUEST = [];
        
        REQUEST_demand  =  [1   2   3   4   5   4   5   4   4   5];
        REQUEST_material = [1   1   1   2   2   3   3   4   4   4]; % 需求物料
        REQUEST_material_quantity = [1 2 1 2 2 3 3 1 1 1]
        
        REQUEST_supply = [1   4   2   1   2   2   1   4   3   3];
        REQUEST_time = [0.40 0.40 0.40 0.60 0.5 0.5 0.6 0.40 0.40 0.60] * 3600;
        
	%  场地边界信息
        % 场地范围线
        field = [70  -82  -82  70;
                 70  70  -70  -70];
        dd = [10 10 10 10];
        FIELD = struct(...
            'boundary_x', [],...
            'boundary_y', [],...
            'dd', []);
        
	% 建筑物+塔吊基座信息
        empty_BUILDING = struct(...
            'x', [],...
            'y', [],...
            'length', [],...
            'width', [],...
            'boundary_x', [],...
            'boundary_y', [],...
            'dd', []);
        
        BUILDING = [];
        BUILDING_x = [0 -25 29];
        BUILDING_y = [0 30 -11];
        BUILDING_length = [6 60 28];
        BUILDING_width = [6 28 42];
        BUILDING_dd = [10 20 20];
        
        
	% 施工设施信息
        empty_FACILITY = struct(...
            'x', [],...
            'y', [],...
            'length', [],...
            'width', [],...
            'boundary_x', [],...
            'boundary_y', [],...
            'dd', []);
        
        FACILITY = [];
        FACILITY_x = [-66 -66 37 46];
        FACILITY_y = [-36 56 45 -44];
        FACILITY_length = [16 8 6 12];
        FACILITY_width = [32 8 10 8];
        FACILITY_dd = [15 15 25 30];
        
	% 物料存储约束
        cons_MATERIAL= [2   4   0   3;
                        4   0   6   3;
                        0   4   0   3];

        materialLoad = [0.20 0.20 0.20 0.15 0.15 0.10 0.10]*3600;
        materialUnload = [0.12 0.12 0.08 0.08 0.08 0.08 0.08]*3600;
                        
           
	% 工序约束
        cons_PROCESS = [];
        
	% 交货期约束
        cons_DEADLINE = [];
        
        THETA = [];     % 供应点到需求点的回转角度
        RHO = [];       % 供应点和需求点的极径之差
        H = [];         % 供应点和需求点的垂直路径距离
        Dis = [];       % 供应点和需求点的水平路径距离
        T_load = [];    % 负载状态下每个供应点到需求点所需时间
        T_noload = [];	% 空载状态下每个供应点到需求点所需时间
        A = [];         % 所有任务备选供应点数量
        m = [];         % 所有任务备选供应点数量的最小公倍数
    end
    
    %% 方法
    methods
        function obj = input_info8(~)
            % 供应点信息
            obj.SUPPLY = repmat(obj.empty_SUPPLY, obj.ini.num_SUPPLY, 1);
            for i = 1 : obj.ini.num_SUPPLY
                obj.SUPPLY(i).pos1(1) = obj.SUPPLY_x(i);
                obj.SUPPLY(i).pos1(2) = obj.SUPPLY_y(i);
                obj.SUPPLY(i).pos1(3) = obj.SUPPLY_z(i);

                % 直角坐标系变为柱坐标系 pos_cyl_new = [rou, thelta, z]            
                obj.SUPPLY(i).pos2 = obj.rect_to_cyl(obj.SUPPLY(i).pos1);

                obj.SUPPLY(i).length = obj.SUPPLY_length(i);
                obj.SUPPLY(i).width = obj.SUPPLY_width(i);

                % 根据中心点与长宽，求出四个边界点坐标
                [obj.SUPPLY(i).boundary_x,obj.SUPPLY(i).boundary_y] = obj.get_boundary(obj.SUPPLY(i).pos1(1), obj.SUPPLY(i).pos1(2), obj.SUPPLY_length(i), obj.SUPPLY(i).width);
            end
            % 需求点信息
            obj.DEMAND = repmat(obj.empty_DEMAND, obj.ini.num_DEMAND, 1);
            for i = 1 : obj.ini.num_DEMAND
                obj.DEMAND(i).pos1(1) = obj.DEMAND_x(i);
                obj.DEMAND(i).pos1(2) = obj.DEMAND_y(i);
                obj.DEMAND(i).pos1(3) = obj.DEMAND_z(i);

                % 直角坐标系变为柱坐标系 pos_cyl_new = [rou, thelta, z]            
                obj.DEMAND(i).pos2 = obj.rect_to_cyl(obj.DEMAND(i).pos1);
            end
            
            % 任务信息
            obj.REQUEST = repmat(obj.empty_REQUEST, obj.ini.num_REQUEST, 1);
            for i = 1 : obj.ini.num_REQUEST
                obj.REQUEST(i).demand = obj.REQUEST_demand(i);
                obj.REQUEST(i).material = obj.REQUEST_material(i);
                obj.REQUEST(i).material_quantity = obj.REQUEST_material_quantity(i);
                obj.REQUEST(i).supply = obj.REQUEST_supply(i);
                obj.REQUEST(i).time = obj.REQUEST_time(i);
            end
            
            for i = 1 : obj.ini.num_REQUEST
                obj.REQUEST(i).loadTime = obj.materialLoad(obj.REQUEST(i).material) * obj.REQUEST(i).material_quantity;
                obj.REQUEST(i).unloadTime = obj.materialUnload(obj.REQUEST(i).material) * obj.REQUEST(i).material_quantity;
            end
            % 场地边界
            obj.FIELD.boundary_x = obj.field(1,:);
            obj.FIELD.boundary_y = obj.field(2,:);
            obj.FIELD.dd = obj.dd;
            
            % 建筑物+塔吊基座
            obj.BUILDING = repmat(obj.empty_BUILDING, obj.ini.num_BUILDING, 1);
            for i = 1 : obj.ini.num_BUILDING
                obj.BUILDING(i).x = obj.BUILDING_x(i);
                obj.BUILDING(i).y = obj.BUILDING_y(i);
                obj.BUILDING(i).length = obj.BUILDING_length(i);
                obj.BUILDING(i).width = obj.BUILDING_width(i);
                obj.BUILDING(i).dd = obj.BUILDING_dd(i);
                [obj.BUILDING(i).boundary_x, obj.BUILDING(i).boundary_y] = obj.get_boundary(obj.BUILDING_x(i), obj.BUILDING_y(i), obj.BUILDING_length(i), obj.BUILDING_width(i));
            end
            
            % 施工设施
            obj.FACILITY = repmat(obj.empty_FACILITY, obj.ini.num_FACILITY, 1);
            for i =1 : obj.ini.num_FACILITY
                obj.FACILITY(i).x = obj.FACILITY_x(i);
                obj.FACILITY(i).y = obj.FACILITY_y(i);
                obj.FACILITY(i).length = obj.FACILITY_length(i);
                obj.FACILITY(i).width = obj.FACILITY_width(i);
                obj.FACILITY(i).dd = obj.FACILITY_dd(i);
                [obj.FACILITY(i).boundary_x, obj.FACILITY(i).boundary_y] = obj.get_boundary(obj.FACILITY_x(i), obj.FACILITY_y(i), obj.FACILITY_length(i), obj.FACILITY_width(i));
            end
            
            % 工序约束
            obj.cons_PROCESS = ones(obj.ini.num_REQUEST);
            for ii = 1 : obj.ini.num_REQUEST
                obj.cons_PROCESS(ii,ii)=0;
            end
            % i必须在j前，则(j,i) = 0;
            % obj.cons_PROCESS(5,1) = 0;
            obj = GetDesignCons(obj);
        end
        
        function calcu(obj, supply_x, supply_y, supply_z)
            % 将布置后的供应点位置更新
            for i = 1 : obj.ini.num_SUPPLY
                obj.SUPPLY(i).pos1(1) = supply_x(i);
                obj.SUPPLY(i).pos1(2) = supply_y(i);
                obj.SUPPLY(i).pos1(3) = supply_z(i);
                % 直角坐标系变为柱坐标系 pos_cyl_new = [rou, thelta, z]            
                obj.SUPPLY(i).pos2 = obj.rect_to_cyl(obj.SUPPLY(i).pos1);
            end
            
            % 供应点S和需求点D 之间的最小回转角度，范围[-pi,pi],i为出发点，j为终止点，逆时针角为正，顺时针角为负
            obj.THETA = zeros(obj.ini.num_SUPPLY, obj.ini.num_DEMAND);
            for i = 1 : obj.ini.num_SUPPLY
                for j = 1 : obj.ini.num_DEMAND                
                    obj.THETA(i, j) =  obj.SUPPLY(i).pos2(2) - obj.DEMAND(j).pos2(2);
                    if obj.THETA(i, j) > pi
                        obj.THETA(i, j) = 2 * pi - obj.THETA(i, j);
                    elseif obj.THETA(i, j) < -pi
                        obj.THETA(i, j) = -2 * pi - obj.THETA(i, j);
                    else
                        obj.THETA(i, j) = -obj.THETA(i, j);
                    end
                end
            end

            % 供应点和需求点的极径之差 已取绝对值
            obj.RHO = zeros(obj.ini.num_SUPPLY, obj.ini.num_DEMAND);
            for i = 1 : obj.ini.num_SUPPLY
                for j = 1 : obj.ini.num_DEMAND
                    obj.RHO(i, j) =  abs(obj.SUPPLY(i).pos2(1) - obj.DEMAND(j).pos2(1));
                end
            end        
    
             % 供应点和需求点的水平路径距离
            obj.Dis = zeros(obj.ini.num_SUPPLY, obj.ini.num_DEMAND);
            for i = 1 : obj.ini.num_SUPPLY
                for j = 1 : obj.ini.num_DEMAND
                    obj.Dis(i, j) = (2 - obj.ini.tao) * abs(obj.THETA(i, j)) * (obj.SUPPLY(i).pos2(1) + obj.DEMAND(j).pos2(1));
                end
            end        
        
            % 供应点和需求点的垂直路径距离
            obj.H = zeros(obj.ini.num_SUPPLY, obj.ini.num_DEMAND);
            for i = 1 : obj.ini.num_SUPPLY
                for j = 1 : obj.ini.num_DEMAND
                    obj.H(i, j) =  abs(obj.SUPPLY(i).pos2(3) - obj.DEMAND(j).pos2(3));
                end
            end
        
            % 负载状态下供应点到需求点的时间,暂未考虑装卸时间
            T_RHO = zeros(obj.ini.num_SUPPLY, obj.ini.num_DEMAND);   % 变幅时间矩阵
            T_THETA = zeros(obj.ini.num_SUPPLY, obj.ini.num_DEMAND); % 回转时间矩阵
            T_D = zeros(obj.ini.num_SUPPLY, obj.ini.num_DEMAND);     % 水平路径时间矩阵
            T_H = zeros(obj.ini.num_SUPPLY, obj.ini.num_DEMAND);     % 卷扬时间矩阵
            obj.T_load = zeros(obj.ini.num_SUPPLY, obj.ini.num_DEMAND);       % 供应点到需求点的时间
            for i = 1 : obj.ini.num_SUPPLY
                for j = 1 : obj.ini.num_DEMAND
                    T_RHO(i, j) = obj.RHO(i, j) / obj.ini.v_rho;
                    T_THETA(i, j) = abs(obj.THETA(i, j)) / obj.ini.v_theta;
                    T_D(i, j) = max(T_RHO(i, j), T_THETA(i, j)) + obj.ini.tao * min(T_RHO(i, j), T_THETA(i, j));
                    T_H(i, j) =  (obj.H(i, j) + 2 * obj.ini.hs) / obj.ini.v_height;
                    obj.T_load(i, j) = max(T_D(i, j), T_H(i, j)) + obj.ini.yita * min(T_D(i, j), T_H(i, j));
                end
            end
     
            % 空载状态下供应点到需求点的时间,暂未考虑装卸时间
            % 暂时设为与负载状态一致
            obj.T_noload = obj.T_load * 2; 
        
            % 所有任务备选供应点数量及其最小公倍数
            obj.A = zeros(1, obj.ini.num_REQUEST);
            for i = 1 : obj.ini.num_REQUEST
                obj.A(i) = sum(obj.cons_MATERIAL(:, obj.REQUEST(i).material));
            end
            n = length(obj.A);
            obj.m = obj.A(1);
            for i = 2 : n
                obj.m = abs(obj.m * obj.A(i)) / gcd(obj.m, obj.A(i));
            end        
        end
    end
        

%% 函数调用
    methods(Access = private)
        %直角坐标系变为柱坐标系 pos_cyl_new = [rou, thelta, z]
        function pos_cyl_new = rect_to_cyl(~, pos)
            pos_cyl_new(1) = sqrt(pos(1)^(2) + pos(2)^(2));
            if pos(1) > 0 && pos(2) >= 0
                pos_cyl_new(2) = atan(pos(2) / pos(1));
            elseif pos(1) > 0 && pos(2) < 0
                pos_cyl_new(2) = atan(pos(2) / pos(1)) + 2 * pi;
            elseif pos(1) == 0 && pos(2) > 0
                pos_cyl_new(2) = pi / 2;
            elseif pos(1) == 0 && pos(2) < 0
                pos_cyl_new(2) = 3 * pi / 2;
            elseif pos(1) < 0
                pos_cyl_new(2) = atan(pos(2) / pos(1)) + pi;
            end
            pos_cyl_new(3) = pos(3);
        end

        % 根据中心点与长宽，求出四个边界点坐标
        function [xx,yy] = get_boundary(~, x, y, len, wid)
            xx(1) = x + len / 2;
            xx(4) = xx(1);
            xx(2) = x - len / 2;
            xx(3) = xx(2);

            yy(1) = y + wid / 2;
            yy(2) = yy(1);
            yy(3) = y - wid / 2;
            yy(4) = yy(3);
        end
    end
    
end




            
