function C2 = GoodsLost_cost(route,D,ST,p1,load,Requirement,speed,Omega1,Omega2)
%函数名称：GoodsLost_cost
%函数功能：计算货物损失成本
%{
route:表示单个蚂蚁的路径信息
p1:单位货损成本（元/吨）
Requiremwnt:客户的货物需求量
Q:货车离开客户时车上剩余货物的的重量
distance:本次客户距离上次客户的
Omega1:货物在车辆门关闭时的腐败率
Omega2:货物在车辆门打开时的腐败率
%}
%函数返回：返回本条路径的货物损失量
C2=0;%初始化
k=1;l=0;%初始化任务数为0
q=Requirement(:,2);
iter=sum(sum(route~=0));%获取数组中非0元素的个数
while k<iter
    if((route(k)==1))%表示从配送中心出发
        l=l+1;
        t1=(D(route(k),route(k+1)))/speed;%获取达到客户点i的路上的行驶时间
        Q=load(l);%得到本次路径中的车上的货物质量
        C2=C2+p1*Q*(1-exp(-Omega1*(t1)));%表示车上所有货物在到达客户点i之前的货损成本
    elseif((route(k+1)==1)&&k~=1)
        C2=C2+0;
    else
        t1=(D(route(k),route(k+1)))/speed;%获取达到客户点i的路上的行驶时间
        t2=ST(route(k));%获取客户再客户点停留的总时间
        C2=C2+p1*Q*(1-exp(-Omega2*t2));%到达客户点i时停留期间的货损成本
        Q=Q-(q(route(k+1)));%剩余货物的质量等于车上的载重量-客户点的需求量
        C2=C2+p1*(Q*(1-exp(-Omega1*t1)));%计算出到达本次客户的所需要的货损成本
    end
    k=k+1;
end
end

