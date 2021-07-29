function distance = Cal_distance(route,D)
%函数名称：Cal_distance
%函数功能：计算运输的总路程
%{
参数说明
route:表示单个蚂蚁的路径信息
D:表示客户之间的距离关系
%}
distance=0;%初始化
temp=route(route~=0);%去掉为了保留的
for i=1:(length(temp)-1)
    distance=distance+D(temp(i),temp(i+1));
end
end

