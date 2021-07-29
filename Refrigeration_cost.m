function C4 = Refrigeration_cost(route,ST,D,speed,p_trefrigeration,p_lrefrigeration)
%函数名称:Refrigeration_cost
%函数功能:计算制冷成本
%{
参数说明:
route:表示单个蚂蚁的路径信息
ST:表示各个客户点的服务时间
D:表示各个客户点之间的距离
speed:表示汽车的速度
p_trefrigeration: 运输过程中单位时间的制冷成本（元/小时）
p_lrefrigeration:%装卸过程中单位时间的制冷成本（元/小时）
%}
C4=0;%初始化
iter=sum(sum(route~=0));%获取数组中非0元素的个数，即走过的城市总数目
for k=1:iter-1
    t1=D(route(k),route(k+1))/speed;%算出在路上行驶的时间
    t2=ST(route(k));%计算在客户点停留的时间
    C4=C4+p_trefrigeration*t1+p_lrefrigeration*t2;
end
end

