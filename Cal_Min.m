function min_length = Cal_Min(route,D)
%函数名称：Cal_Min
%函数功能：计算一次运输过程中的路径的最短路径
%{
参数说明
route:表示单个蚂蚁的路径信息
D:表示客户之间的距离关系
%}
distance=0;%初始化
count=1;%临时计数器
temp=route(route~=0);%去掉为了路径后面的0
result=zeros(1,20);%保存每条路径的值
for i=1:(length(temp)-1)
    if(temp(i)==1&&(i~=1))
        %表示是新的一条路径
        result(count)=distance;
        count=count+1;
        distance=0;
    end
    distance=distance+D(temp(i),temp(i+1));
    if(i==length(temp)-1)
        result(count)=distance;
        count=count+1;
        distance=0;
    end
end
result=result(result~=0);
min_length=min(result);
end

