function C2 = GoodsLost_cost(route,D,ST,p1,load,Requirement,speed,Omega1,Omega2)
%�������ƣ�GoodsLost_cost
%�������ܣ����������ʧ�ɱ�
%{
route:��ʾ�������ϵ�·����Ϣ
p1:��λ����ɱ���Ԫ/�֣�
Requiremwnt:�ͻ��Ļ���������
Q:�����뿪�ͻ�ʱ����ʣ�����ĵ�����
distance:���οͻ������ϴοͻ���
Omega1:�����ڳ����Źر�ʱ�ĸ�����
Omega2:�����ڳ����Ŵ�ʱ�ĸ�����
%}
%�������أ����ر���·���Ļ�����ʧ��
C2=0;%��ʼ��
k=1;l=0;%��ʼ��������Ϊ0
q=Requirement(:,2);
iter=sum(sum(route~=0));%��ȡ�����з�0Ԫ�صĸ���
while k<iter
    if((route(k)==1))%��ʾ���������ĳ���
        l=l+1;
        t1=(D(route(k),route(k+1)))/speed;%��ȡ�ﵽ�ͻ���i��·�ϵ���ʻʱ��
        Q=load(l);%�õ�����·���еĳ��ϵĻ�������
        C2=C2+p1*Q*(1-exp(-Omega1*(t1)));%��ʾ�������л����ڵ���ͻ���i֮ǰ�Ļ���ɱ�
    elseif((route(k+1)==1)&&k~=1)
        C2=C2+0;
    else
        t1=(D(route(k),route(k+1)))/speed;%��ȡ�ﵽ�ͻ���i��·�ϵ���ʻʱ��
        t2=ST(route(k));%��ȡ�ͻ��ٿͻ���ͣ������ʱ��
        C2=C2+p1*Q*(1-exp(-Omega2*t2));%����ͻ���iʱͣ���ڼ�Ļ���ɱ�
        Q=Q-(q(route(k+1)));%ʣ�������������ڳ��ϵ�������-�ͻ����������
        C2=C2+p1*(Q*(1-exp(-Omega1*t1)));%��������ﱾ�οͻ�������Ҫ�Ļ���ɱ�
    end
    k=k+1;
end
end

