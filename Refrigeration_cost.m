function C4 = Refrigeration_cost(route,ST,D,speed,p_trefrigeration,p_lrefrigeration)
%��������:Refrigeration_cost
%��������:��������ɱ�
%{
����˵��:
route:��ʾ�������ϵ�·����Ϣ
ST:��ʾ�����ͻ���ķ���ʱ��
D:��ʾ�����ͻ���֮��ľ���
speed:��ʾ�������ٶ�
p_trefrigeration: ��������е�λʱ�������ɱ���Ԫ/Сʱ��
p_lrefrigeration:%װж�����е�λʱ�������ɱ���Ԫ/Сʱ��
%}
C4=0;%��ʼ��
iter=sum(sum(route~=0));%��ȡ�����з�0Ԫ�صĸ��������߹��ĳ�������Ŀ
for k=1:iter-1
    t1=D(route(k),route(k+1))/speed;%�����·����ʻ��ʱ��
    t2=ST(route(k));%�����ڿͻ���ͣ����ʱ��
    C4=C4+p_trefrigeration*t1+p_lrefrigeration*t2;
end
end

