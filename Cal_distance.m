function distance = Cal_distance(route,D)
%�������ƣ�Cal_distance
%�������ܣ������������·��
%{
����˵��
route:��ʾ�������ϵ�·����Ϣ
D:��ʾ�ͻ�֮��ľ����ϵ
%}
distance=0;%��ʼ��
temp=route(route~=0);%ȥ��Ϊ�˱�����
for i=1:(length(temp)-1)
    distance=distance+D(temp(i),temp(i+1));
end
end

