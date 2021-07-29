function C5 = Transport_cost(route,load,Requirement,D,ph_empty,ph_full,Qm,p_fuel,f)
%函数名称：Transport_cost
%函数功能：计算运输过程中的燃料成本
%{
参数说明
route:表示单个蚂蚁的路径信息
D:表示客户之间的距离关系
ph_empty:表示汽车空载时的燃油消耗量
ph_full:表示汽车满载时的燃油消耗量
Qm:表示汽车的最大载重量
load:表示本趟任务中的汽车载重量
p_fuel:单位燃油成本(元/吨）
f:常数，0.84吨/立方米，表示汽油体积和质量的关系
%}
C5=0;%初始化参数
l=0;%初始化任务数为0
q=Requirement(:,2);
iter=sum(sum(route~=0));%获取数组中非0元素的个数 即走过的城市的个数
p=(ph_full-ph_empty)/Qm;%得到油耗与载重量的关系系数
for k=1:iter-1
    if(route(k)==1&&k==1)%表示从配送中心出发
        l=l+1;%任务数目加一
        Q=load(l);%剩余货物的质量等于车上的载重量-客户点的需求量
        C5=C5+p_fuel*D(route(k),route(k+1))*(ph_empty+p*Q)*f*(1e-5);%得到本次路径上的所有燃油成本
    elseif((route(k+1)==1)&&k~=1)%表示返回配送中心
        %返回配送中心是空车返回
        l=l+1;%任务数加一
        C5=C5+p_fuel*D(route(k),route(k+1))*(ph_empty)*f*(1e-5);%得到本次路径上的所有燃油成本
    else
        %表示从一个客户点到另外一个客户点
        Q=load(l)-(q(route(k+1)));%剩余货物的质量等于车上的载重量-客户点的需求量
        C5=C5+p_fuel*D(route(k),route(k+1))*(ph_empty+p*Q)*f*(1e-5);%得到本次路径上的所有燃油成本
    end   
end
end

