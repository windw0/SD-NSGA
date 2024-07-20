%% �������

classdef input_info8<handle
    %% ����
    properties
    % ����
        ini = struct(...
            'num_SUPPLY', 3,...     % ��Ӧ�����
            'num_DEMAND', 5,...     % ��������
            'num_MATERIAL', 4,...   % ��������
            'num_REQUEST', 10,...   % �������
            'num_BUILDING', 3,...   % ���������������������������
            'num_FACILITY', 4,...   % ʩ����ʩ������
            'tower_init_pos_in_demand', 1,...   % ������ʼλ���ڵ�n�������
            'hs', 2,...             % ��ȫ�߶�
            'v_rho', 0.62,...          % ���ر���ٶ�(m/s) ��ԭ����1�� �����ٶ�Ϊһ��
            'v_theta', 0.03,...   % ���ػ�ת�ٶȣ�rad/s����ԭ����0.0083�� �����ٶ�Ϊһ��
            'v_height', 0.83,...    % ���ؾ����ٶ�(m/s) ��ԭ����2.27�������ٶ�Ϊһ��
            'miu', 1,...            % ����ϵ��
            'tao', 0.24,...         % ˮƽЭ��ϵ��
            'yita', 1,...           % ����Э��ϵ��
            't_load', 1,...         % װ��ʱ��
            't_unload', 1,...       % ж��ʱ��
            'tower_pos', [0  0  0],...  % ����ʼλ��
            'tower_dd', 10,...      % ������ʶ�����
            'radius', 63);          % �������۳���

    % ��Ӧ����Ϣ
        empty_SUPPLY = struct(...
            'pos1', [],...      % ֱ������
            'pos2', [],...      % ������
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
        
	% �������Ϣ
        empty_DEMAND = struct(...
            'pos1', [],...      % ֱ������
            'pos2', []);        % ������
        DEMAND = [];
        DEMAND_x = [-40     -25     -10     20     20];
        DEMAND_y = [20       20      26     0      -20];
        DEMAND_z = [15.6 15.6 15.6 9.46 9.46];
        
	% ������Ϣ
        empty_REQUEST = struct(...
            'demand', [],...    % �����  
            'material', [],...  % ������������  
            'material_quantity', [],... % ����������
            'supply', [],...    % ��Ӧ��ѡ��Ŀǰ���ԣ�ֱ�Ӹ�����
            'time', [],...      % ����ִ��ʱ��
            'limit_time', [])   % �����޶��Ľ���ʱ��
        
        REQUEST = [];
        
        REQUEST_demand  =  [1   2   3   4   5   4   5   4   4   5];
        REQUEST_material = [1   1   1   2   2   3   3   4   4   4]; % ��������
        REQUEST_material_quantity = [1 2 1 2 2 3 3 1 1 1]
        
        REQUEST_supply = [1   4   2   1   2   2   1   4   3   3];
        REQUEST_time = [0.40 0.40 0.40 0.60 0.5 0.5 0.6 0.40 0.40 0.60] * 3600;
        
	%  ���ر߽���Ϣ
        % ���ط�Χ��
        field = [70  -82  -82  70;
                 70  70  -70  -70];
        dd = [10 10 10 10];
        FIELD = struct(...
            'boundary_x', [],...
            'boundary_y', [],...
            'dd', []);
        
	% ������+����������Ϣ
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
        
        
	% ʩ����ʩ��Ϣ
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
        
	% ���ϴ洢Լ��
        cons_MATERIAL= [2   4   0   3;
                        4   0   6   3;
                        0   4   0   3];

        materialLoad = [0.20 0.20 0.20 0.15 0.15 0.10 0.10]*3600;
        materialUnload = [0.12 0.12 0.08 0.08 0.08 0.08 0.08]*3600;
                        
           
	% ����Լ��
        cons_PROCESS = [];
        
	% ������Լ��
        cons_DEADLINE = [];
        
        THETA = [];     % ��Ӧ�㵽�����Ļ�ת�Ƕ�
        RHO = [];       % ��Ӧ��������ļ���֮��
        H = [];         % ��Ӧ��������Ĵ�ֱ·������
        Dis = [];       % ��Ӧ���������ˮƽ·������
        T_load = [];    % ����״̬��ÿ����Ӧ�㵽���������ʱ��
        T_noload = [];	% ����״̬��ÿ����Ӧ�㵽���������ʱ��
        A = [];         % ��������ѡ��Ӧ������
        m = [];         % ��������ѡ��Ӧ����������С������
    end
    
    %% ����
    methods
        function obj = input_info8(~)
            % ��Ӧ����Ϣ
            obj.SUPPLY = repmat(obj.empty_SUPPLY, obj.ini.num_SUPPLY, 1);
            for i = 1 : obj.ini.num_SUPPLY
                obj.SUPPLY(i).pos1(1) = obj.SUPPLY_x(i);
                obj.SUPPLY(i).pos1(2) = obj.SUPPLY_y(i);
                obj.SUPPLY(i).pos1(3) = obj.SUPPLY_z(i);

                % ֱ������ϵ��Ϊ������ϵ pos_cyl_new = [rou, thelta, z]            
                obj.SUPPLY(i).pos2 = obj.rect_to_cyl(obj.SUPPLY(i).pos1);

                obj.SUPPLY(i).length = obj.SUPPLY_length(i);
                obj.SUPPLY(i).width = obj.SUPPLY_width(i);

                % �������ĵ��볤������ĸ��߽������
                [obj.SUPPLY(i).boundary_x,obj.SUPPLY(i).boundary_y] = obj.get_boundary(obj.SUPPLY(i).pos1(1), obj.SUPPLY(i).pos1(2), obj.SUPPLY_length(i), obj.SUPPLY(i).width);
            end
            % �������Ϣ
            obj.DEMAND = repmat(obj.empty_DEMAND, obj.ini.num_DEMAND, 1);
            for i = 1 : obj.ini.num_DEMAND
                obj.DEMAND(i).pos1(1) = obj.DEMAND_x(i);
                obj.DEMAND(i).pos1(2) = obj.DEMAND_y(i);
                obj.DEMAND(i).pos1(3) = obj.DEMAND_z(i);

                % ֱ������ϵ��Ϊ������ϵ pos_cyl_new = [rou, thelta, z]            
                obj.DEMAND(i).pos2 = obj.rect_to_cyl(obj.DEMAND(i).pos1);
            end
            
            % ������Ϣ
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
            % ���ر߽�
            obj.FIELD.boundary_x = obj.field(1,:);
            obj.FIELD.boundary_y = obj.field(2,:);
            obj.FIELD.dd = obj.dd;
            
            % ������+��������
            obj.BUILDING = repmat(obj.empty_BUILDING, obj.ini.num_BUILDING, 1);
            for i = 1 : obj.ini.num_BUILDING
                obj.BUILDING(i).x = obj.BUILDING_x(i);
                obj.BUILDING(i).y = obj.BUILDING_y(i);
                obj.BUILDING(i).length = obj.BUILDING_length(i);
                obj.BUILDING(i).width = obj.BUILDING_width(i);
                obj.BUILDING(i).dd = obj.BUILDING_dd(i);
                [obj.BUILDING(i).boundary_x, obj.BUILDING(i).boundary_y] = obj.get_boundary(obj.BUILDING_x(i), obj.BUILDING_y(i), obj.BUILDING_length(i), obj.BUILDING_width(i));
            end
            
            % ʩ����ʩ
            obj.FACILITY = repmat(obj.empty_FACILITY, obj.ini.num_FACILITY, 1);
            for i =1 : obj.ini.num_FACILITY
                obj.FACILITY(i).x = obj.FACILITY_x(i);
                obj.FACILITY(i).y = obj.FACILITY_y(i);
                obj.FACILITY(i).length = obj.FACILITY_length(i);
                obj.FACILITY(i).width = obj.FACILITY_width(i);
                obj.FACILITY(i).dd = obj.FACILITY_dd(i);
                [obj.FACILITY(i).boundary_x, obj.FACILITY(i).boundary_y] = obj.get_boundary(obj.FACILITY_x(i), obj.FACILITY_y(i), obj.FACILITY_length(i), obj.FACILITY_width(i));
            end
            
            % ����Լ��
            obj.cons_PROCESS = ones(obj.ini.num_REQUEST);
            for ii = 1 : obj.ini.num_REQUEST
                obj.cons_PROCESS(ii,ii)=0;
            end
            % i������jǰ����(j,i) = 0;
            % obj.cons_PROCESS(5,1) = 0;
            obj = GetDesignCons(obj);
        end
        
        function calcu(obj, supply_x, supply_y, supply_z)
            % �����ú�Ĺ�Ӧ��λ�ø���
            for i = 1 : obj.ini.num_SUPPLY
                obj.SUPPLY(i).pos1(1) = supply_x(i);
                obj.SUPPLY(i).pos1(2) = supply_y(i);
                obj.SUPPLY(i).pos1(3) = supply_z(i);
                % ֱ������ϵ��Ϊ������ϵ pos_cyl_new = [rou, thelta, z]            
                obj.SUPPLY(i).pos2 = obj.rect_to_cyl(obj.SUPPLY(i).pos1);
            end
            
            % ��Ӧ��S�������D ֮�����С��ת�Ƕȣ���Χ[-pi,pi],iΪ�����㣬jΪ��ֹ�㣬��ʱ���Ϊ����˳ʱ���Ϊ��
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

            % ��Ӧ��������ļ���֮�� ��ȡ����ֵ
            obj.RHO = zeros(obj.ini.num_SUPPLY, obj.ini.num_DEMAND);
            for i = 1 : obj.ini.num_SUPPLY
                for j = 1 : obj.ini.num_DEMAND
                    obj.RHO(i, j) =  abs(obj.SUPPLY(i).pos2(1) - obj.DEMAND(j).pos2(1));
                end
            end        
    
             % ��Ӧ���������ˮƽ·������
            obj.Dis = zeros(obj.ini.num_SUPPLY, obj.ini.num_DEMAND);
            for i = 1 : obj.ini.num_SUPPLY
                for j = 1 : obj.ini.num_DEMAND
                    obj.Dis(i, j) = (2 - obj.ini.tao) * abs(obj.THETA(i, j)) * (obj.SUPPLY(i).pos2(1) + obj.DEMAND(j).pos2(1));
                end
            end        
        
            % ��Ӧ��������Ĵ�ֱ·������
            obj.H = zeros(obj.ini.num_SUPPLY, obj.ini.num_DEMAND);
            for i = 1 : obj.ini.num_SUPPLY
                for j = 1 : obj.ini.num_DEMAND
                    obj.H(i, j) =  abs(obj.SUPPLY(i).pos2(3) - obj.DEMAND(j).pos2(3));
                end
            end
        
            % ����״̬�¹�Ӧ�㵽������ʱ��,��δ����װжʱ��
            T_RHO = zeros(obj.ini.num_SUPPLY, obj.ini.num_DEMAND);   % ���ʱ�����
            T_THETA = zeros(obj.ini.num_SUPPLY, obj.ini.num_DEMAND); % ��תʱ�����
            T_D = zeros(obj.ini.num_SUPPLY, obj.ini.num_DEMAND);     % ˮƽ·��ʱ�����
            T_H = zeros(obj.ini.num_SUPPLY, obj.ini.num_DEMAND);     % ����ʱ�����
            obj.T_load = zeros(obj.ini.num_SUPPLY, obj.ini.num_DEMAND);       % ��Ӧ�㵽������ʱ��
            for i = 1 : obj.ini.num_SUPPLY
                for j = 1 : obj.ini.num_DEMAND
                    T_RHO(i, j) = obj.RHO(i, j) / obj.ini.v_rho;
                    T_THETA(i, j) = abs(obj.THETA(i, j)) / obj.ini.v_theta;
                    T_D(i, j) = max(T_RHO(i, j), T_THETA(i, j)) + obj.ini.tao * min(T_RHO(i, j), T_THETA(i, j));
                    T_H(i, j) =  (obj.H(i, j) + 2 * obj.ini.hs) / obj.ini.v_height;
                    obj.T_load(i, j) = max(T_D(i, j), T_H(i, j)) + obj.ini.yita * min(T_D(i, j), T_H(i, j));
                end
            end
     
            % ����״̬�¹�Ӧ�㵽������ʱ��,��δ����װжʱ��
            % ��ʱ��Ϊ�븺��״̬һ��
            obj.T_noload = obj.T_load * 2; 
        
            % ��������ѡ��Ӧ������������С������
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
        

%% ��������
    methods(Access = private)
        %ֱ������ϵ��Ϊ������ϵ pos_cyl_new = [rou, thelta, z]
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

        % �������ĵ��볤������ĸ��߽������
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




            
