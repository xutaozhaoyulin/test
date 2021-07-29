function difference = Cal_Max2Min(route,D)
%函数名称：Cal_Max2Min
%函数功能：计算一次运输过程中的路径的最值差
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
difference=max(result)-min(result);%得到差值
end

