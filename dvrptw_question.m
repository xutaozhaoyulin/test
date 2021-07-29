%清空环境变量
clc;
clear;
close all;
%--------------------------------------------------------------------------
%初始化参数
K=13;                   %配送中心自由的车辆
Qm=5;                   %冷链车的最大载重量（吨）
v=40;                   %车辆固定行驶速度（千米/小时）
type=3;                 %货物的种类
ph_empty=15;            %空载时百公里燃油消耗量(升/百公里）
ph_full=19;             %满载时百公里燃油消耗量(升/百公里）
alpha1=0.003;           %运输过程中产品的腐败率
alpha2=0.005;           %卸货过程中产品的腐败率
T=0.1;                  %在客户点除装卸外其他等待的时间（小时）
p_truck=200;            %冷链车使用的固定成本（元/辆）
p_lostgoods=1200;       %单位货损成本(元/吨）
p_fuel=6000;            %燃料油耗成本(元/吨）
p_early=90;             %表示在迟到时间窗内的单位时间惩罚成本（元/小时）
p_late=120;             %表示在早到时间窗内的单位时间惩罚成本（元/小时）
p_trefrigeration=18;    %运输过程中单位时间的制冷成本（元/小时）
p_lrefrigeration=25;    %装卸过程中单位时间的制冷成本（元/小时）
theta1=1;               %装卸货物a的效率 =1t/h/人；
theta2=3;               %装卸货物b的效率 =3t/h/人；
theta3=5;               %装卸货物c的效率 =5t/h/人
f=0.84;                 %常数，表示汽油质量与体积的关系，单位吨/立方米
extra=90;               %表示超过这个值之后就要付给司机加班费用
extra_cost=2;           %每超出公里数应该付出的成本 元/公里

%得到各个城市的坐标
citys=xlsread('D:\\Matlab\\Distribution path optimization\\data_position.xlsx','B2:C31');
%获取城市的个数
n=size(citys,1);      
%%计算城市间的相互距离
D=zeros(n,n);%将矩阵初始化为0矩阵
for i=1:n
    for j=1:n
        if i~=j
            D(i,j)=sqrt(sum((citys(i,:)-citys(j,:)).^2));
        else
            D(i,j)=eps; %应该为0，但是启发函数要用到倒数，所以这边用eps，浮点数的相对精度来表示这个很小的距离 
        end
    end
end                 
%各个客户的需求量矩阵
Requirement=xlsread('D:\\Matlab\\Distribution path optimization\\data_client_new.xlsx','B2:C32');
%各个客户点装卸人员数量
WorkerNumber=xlsread('D:\\Matlab\\Distribution path optimization\\data_client_new.xlsx','D2:D32');
%各个客户点的时间窗并且将所有时间转换成小时
TimeWindows=xlsread('D:\\Matlab\\Distribution path optimization\\data_client_new.xlsx','I2:L32');
TimeWindows=TimeWindows/60;
%各个客户点的总时间
TL=zeros(n,1);
for i=1:n%计算卸货时间
    if Requirement(i,1)==1
        TL(i)=(Requirement(i,2)/(WorkerNumber(i)*theta1))*60;
    elseif Requirement(i,1)==2
        TL(i)=(Requirement(i,2)/(WorkerNumber(i)*theta2))*60;
    elseif Requirement(i,1)==3
        TL(i)=(Requirement(i,2)/(WorkerNumber(i)*theta3))*60;
    else
        TL(i)=0;
    end
end
%换成分钟并且加上服务时间
TL=TL+T*60;
%将配送中心的时间清零，得到各个客户点的总时间
TL(1)=0;   
%得到各个客户点的停留的总时间
ST=TL/60;
%--------------------------------------------------------------------------
%蚁群算法参数初始化
m=50;                                % 蚂蚁数量
alpha = 1;                           % 信息素重要程度因子
beta = 5;                            % 启发函数重要程度因子
vol = 0.2;                           % 信息素挥发(volatilization)因子
Q = 10;                              % 常系数
Heu_F = 1./D;                        % 启发函数(heuristic function)
Tau = ones(n,n);                     % 信息素矩阵
Table = zeros(m,n+20);               % 路径记录表 m个蚂蚁走过n个城市
iter = 1;                            % 迭代次数初值
iter_max = 100;                      % 最大迭代次数 
Min__cost_Route = zeros(iter_max,n+20); % 各代最小成本路径       
Min_cost = zeros(iter_max,1);        % 各代最小成本  
Limit_iter = 0;                      % 程序收敛时迭代次数
Load=zeros(K,1);                     %保存每次车辆运输时候的载重量
%--------------------------------------------------------------------------
load=0;%初始化载重为0
count=1;%用来保存任务数目

%用蚁群算法进行迭代
while iter<=iter_max
    %将所有蚂蚁的起点城市改为1
    Table(:,1)=1;%将所有蚂蚁的初始位置都设置成1
    %构建解空间
    citys_index = 1:n;
    i=1;
    %逐个蚂蚁进行城市选择
    while i<=m
        j=2;
        %逐个城市进行路径选择
        while j<=n
            has_visited=Table(i,1:(j-1));%已经访问的城市集合
            allow_index=~ismember(citys_index,has_visited);%判断那些城市还没有访问
            allow= citys_index(allow_index);%待访问城市的集合
            P=allow;
            %计算城市间访问的概率
            for k=1:length(allow)
                P(k) = Tau(has_visited(end),allow(k))^alpha * Heu_F(has_visited(end),allow(k))^beta;
            end
            P=P/sum(P);
            %用轮盘赌方法选择下一个访问城市
            Pc = cumsum(P);     %用来求变量中累加元素的和
            target_index = find(Pc >= rand);%rand 随机产生一个0-1内的数
            target = allow(target_index(1));%算出下一个要访问的城市序号
            load=load+Requirement(target,2);%算出如果访问这个城市后车上载重量
            if(load>Qm)
                Load(i,count)=load-Requirement(target,2);%保存本次任务车辆的载重量
                target=1;%车将会超载，于是在这个时候返回配送中心
                load=0;%将车上的初始重量清0
                count=count+1;%任务数加一
                n=n+1;%城市选择次数加一
                Table(i,j) = target;
            else
                Table(i,j) = target;%如果没有超重，求得蚂蚁第i只蚂蚁第j次要访问的城市
            end
            j=j+1;
        end
        Load(i,count)=load;%把最后一次的任务载重量加上去
        Table(i,n+1)=1;%蚂蚁回到原来的城市
        load=0;%将初始载重置0
        count=1;%将任务数置0
        n=size(D,1);
        i=i+1;
    end
%--------------------------------------------------------------------------
    %计算出总成本
    Cost=zeros(m,1);
    %得到固定成本
    for i=1:m%取出第i只蚂蚁走的城市
        route=Table(i,:);
        temp_distance=Cal_distance(route,D);%计算出本条的路径总距离
        temp_difference=Cal_Max2Min(route,D);%计算出该条路径的差值
        %disp(['差值=',num2str(temp_difference)]);
        if((temp_difference<=250)&&(temp_distance<=4980))%判定
            myLoad=Load(i,:);%取出本只蚂蚁的每次的载重量
            C1=K*p_truck;%固定成本
            C2=GoodsLost_cost(route,D,ST,p_lostgoods,myLoad,Requirement,v,alpha1,alpha2);%货物损失成本
            %disp(['C2=' num2str(C2)]);
            C3=TimePunishment_cost(route,D,TimeWindows,v,ST,p_early,p_late);%时间惩罚成本
            %disp(['C3=' num2str(C3)]);
            C4=Refrigeration_cost(route,ST,D,v,p_trefrigeration,p_lrefrigeration);%制冷成本
            %disp(['C4=' num2str(C4)]);
            C5=Transport_cost(route,myLoad,Requirement, D,ph_empty,ph_full,Qm,p_fuel,f);%运输成本
            %disp(['C5=' num2str(C5)]);
            C6=Cal_welfare(route,D,extra,extra_cost);%应该给司机付的加班费用
            %disp(['C6=' num2str(C6)]);
            Cost(i)=C1+C2+C3+C4+C5+C6;%将本次迭代过程中的所有蚂蚁的总成本记录下来
            %disp(['Cost(i)' num2str(Cost(i))]);
        else
            Cost(i)=100000;%设置一个极大值，表示这种情况不存在
            %disp(['Cost(i)' num2str(Cost(i))])
        end
            
            
    end
    %计算出最小成本
    if iter==1%第一次迭代的情况
        [min_cost,min_index]=min(Cost);%找到最小成本路径以及最小成本路径的蚂蚁编号
        Min_cost(iter)=min_cost;%计算出本代的最小成本
        Min__cost_Route(iter,:)=Table(min_index,:);%通过最短路径的蚂蚁编号取出对应的路径
        Limit_iter = 1; %程序收敛的迭代次数为1；
    else
        [min_cost,min_index]=min(Cost);%找到最小成本路径以及最小成本路径的蚂蚁编号
        Min_cost(iter)=min(Min_cost(iter-1),min_cost);%比较本代的最小成本和上一代最短路径，取最小
        if Min_cost(iter)==min_cost%%如果本代的蚂蚁走的最小成本比上一代的小
            Min__cost_Route(iter,:)=Table(min_index,:);%通过最小成本的蚂蚁编号取出对应的路径
            Limit_iter = iter;%程序收敛的迭代出次数等于本次的迭代次数
        else%如果上一代的蚂蚁走的最小成本比这一代的要小，那么本次的最小成本则为上一代的最小成本
             Min__cost_Route(iter,:)= Min__cost_Route((iter-1),:);
        end    
    end
    % 计算各个蚂蚁的路径距离
    Length = zeros(m,1);
    for i = 1:m
        Route = Table(i,:);%取出第i只蚂蚁走的城市
        temp=sum(sum(Route~=0));%获取数组中非0元素的个数 即走过的城市的个数
        for j = 1:temp-1
            Length(i) = Length(i) + D(Route(j),Route(j + 1));%求出第i只蚂蚁走的总路径长度
        end
    end    
    %采用蚁周模型来更新信息素
    Delta_Tau = zeros(n,n);
    % 逐个蚂蚁计算
    for i = 1:m
        % 逐个城市计算
        for j = 1:(n - 1)
            Delta_Tau(Table(i,j),Table(i,j+1)) = Delta_Tau(Table(i,j),Table(i,j+1)) + Q/Length(i);%第i只蚂蚁在第j次出发时在路上留下的信息素
        end
    end
    Tau = (1-vol) * Tau + Delta_Tau; %信息素表=挥发剩余的信息素+蚂蚁走的信息素
    % 迭代次数加1，清空路径记录表
    iter = iter + 1;
    Table = zeros(m,n+20);
end
%--------------------------------------------------------------------------
%结果显示
[min_cost,index]=min(Min_cost);
min_cost_route=Min__cost_Route(index,:);
%去掉多余的0元素
temp=min_cost_route(min_cost_route~=0);
min_cost_length=Cal_distance(temp,D);
final_result=Cal_result(temp,D);
difference=Cal_Max2Min(temp,D);
max_length=Cal_Max(temp,D);
min_length=Cal_Min(temp,D);
disp(['最小成本:' num2str(min_cost)]);
disp(['最小成本路径:' num2str([temp])]);
disp(['最小成本路径长度:',num2str(min_cost_length)]);
disp(['最小成本路径中最大路径:',num2str(max_length)]);
disp(['最小成本路径中最小路径:',num2str(min_length)]);
disp(['最小成本路径差值:',num2str(difference)]);
disp(['程序收敛次数:' num2str([Limit_iter])]);
%% 绘图
figure(1)
plot(citys(temp,1),citys(temp,2),'o-');%将最短路线从开始到结束连接起来
grid on%打开网格
for i = 1:size(citys,1)
    text(citys(i,1),citys(i,2),['   ' num2str(i)]);
end
text(citys(temp(1),1),citys(temp(1),2),'       起点');
text(citys(temp(end),1),citys(temp(end),2),'       终点');
xlabel('城市位置横坐标')
ylabel('城市位置纵坐标')
title(['ACA最优化路径(最小成本:' num2str(min_cost) ')'])


