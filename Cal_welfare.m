function welfare = Cal_welfare(route,D,extra,extra_cost)
%�������ƣ�Cal_welfare
%�������ܣ�����һ�����������Ӧ�ø�˾���ļӰ��
%{
����˵��
route:��ʾ�������ϵ�·����Ϣ
D:��ʾ�ͻ�֮��ľ����ϵ
extra:��ʾ�������ٽ�ֵ
extra_cost:ÿ����������Ӧ�ø����ĳɱ� Ԫ/����
%}
distance=0;
welfare=0;%��ʼ��
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
for j=1:length(result)
    if(result(j)>extra)
        welfare=welfare+(result(j)-extra)*extra_cost;
    end
end

end

