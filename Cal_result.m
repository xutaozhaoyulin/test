function result = Cal_result(route,D)
%�������ƣ�Cal_Max2Min
%�������ܣ�����һ����������е�·������ֵ��
%{
����˵��
route:��ʾ�������ϵ�·����Ϣ
D:��ʾ�ͻ�֮��ľ����ϵ
%}
distance=0;%��ʼ��
count=1;%��ʱ������
temp=route(route~=0);%ȥ��Ϊ��·�������0
result=zeros(1,20);%����ÿ��·����ֵ
for i=1:(length(temp)-1)
    if(temp(i)==1&&(i~=1))
    %��ʾ���µ�һ��·��
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
end
