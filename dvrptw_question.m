%��ջ�������
clc;
clear;
close all;
%--------------------------------------------------------------------------
%��ʼ������
K=13;                   %�����������ɵĳ���
Qm=5;                   %��������������������֣�
v=40;                   %�����̶���ʻ�ٶȣ�ǧ��/Сʱ��
type=3;                 %���������
ph_empty=15;            %����ʱ�ٹ���ȼ��������(��/�ٹ��
ph_full=19;             %����ʱ�ٹ���ȼ��������(��/�ٹ��
alpha1=0.003;           %��������в�Ʒ�ĸ�����
alpha2=0.005;           %ж�������в�Ʒ�ĸ�����
T=0.1;                  %�ڿͻ����װж�������ȴ���ʱ�䣨Сʱ��
p_truck=200;            %������ʹ�õĹ̶��ɱ���Ԫ/����
p_lostgoods=1200;       %��λ����ɱ�(Ԫ/�֣�
p_fuel=6000;            %ȼ���ͺĳɱ�(Ԫ/�֣�
p_early=90;             %��ʾ�ڳٵ�ʱ�䴰�ڵĵ�λʱ��ͷ��ɱ���Ԫ/Сʱ��
p_late=120;             %��ʾ���絽ʱ�䴰�ڵĵ�λʱ��ͷ��ɱ���Ԫ/Сʱ��
p_trefrigeration=18;    %��������е�λʱ�������ɱ���Ԫ/Сʱ��
p_lrefrigeration=25;    %װж�����е�λʱ�������ɱ���Ԫ/Сʱ��
theta1=1;               %װж����a��Ч�� =1t/h/�ˣ�
theta2=3;               %װж����b��Ч�� =3t/h/�ˣ�
theta3=5;               %װж����c��Ч�� =5t/h/��
f=0.84;                 %��������ʾ��������������Ĺ�ϵ����λ��/������
extra=90;               %��ʾ�������ֵ֮���Ҫ����˾���Ӱ����
extra_cost=2;           %ÿ����������Ӧ�ø����ĳɱ� Ԫ/����

%�õ��������е�����
citys=xlsread('D:\\Matlab\\Distribution path optimization\\data_position.xlsx','B2:C31');
%��ȡ���еĸ���
n=size(citys,1);      
%%������м���໥����
D=zeros(n,n);%�������ʼ��Ϊ0����
for i=1:n
    for j=1:n
        if i~=j
            D(i,j)=sqrt(sum((citys(i,:)-citys(j,:)).^2));
        else
            D(i,j)=eps; %Ӧ��Ϊ0��������������Ҫ�õ����������������eps������������Ծ�������ʾ�����С�ľ��� 
        end
    end
end                 
%�����ͻ�������������
Requirement=xlsread('D:\\Matlab\\Distribution path optimization\\data_client_new.xlsx','B2:C32');
%�����ͻ���װж��Ա����
WorkerNumber=xlsread('D:\\Matlab\\Distribution path optimization\\data_client_new.xlsx','D2:D32');
%�����ͻ����ʱ�䴰���ҽ�����ʱ��ת����Сʱ
TimeWindows=xlsread('D:\\Matlab\\Distribution path optimization\\data_client_new.xlsx','I2:L32');
TimeWindows=TimeWindows/60;
%�����ͻ������ʱ��
TL=zeros(n,1);
for i=1:n%����ж��ʱ��
    if Requirement(i,1)==1
        TL(i)=(Requirement(i,2)/(WorkerNumber(i)*theta1))*60;
    elseif Requirement(i,1)==2
        TL(i)=(Requirement(i,2)/(WorkerNumber(i)*theta2))*60;
    elseif Requirement(i,1)==3
        TL(i)=(Requirement(i,2)/(WorkerNumber(i)*theta3))*60;
    else
        TL(i)=0;
    end
end
%���ɷ��Ӳ��Ҽ��Ϸ���ʱ��
TL=TL+T*60;
%���������ĵ�ʱ�����㣬�õ������ͻ������ʱ��
TL(1)=0;   
%�õ������ͻ����ͣ������ʱ��
ST=TL/60;
%--------------------------------------------------------------------------
%��Ⱥ�㷨������ʼ��
m=50;                                % ��������
alpha = 1;                           % ��Ϣ����Ҫ�̶�����
beta = 5;                            % ����������Ҫ�̶�����
vol = 0.2;                           % ��Ϣ�ػӷ�(volatilization)����
Q = 10;                              % ��ϵ��
Heu_F = 1./D;                        % ��������(heuristic function)
Tau = ones(n,n);                     % ��Ϣ�ؾ���
Table = zeros(m,n+20);               % ·����¼�� m�������߹�n������
iter = 1;                            % ����������ֵ
iter_max = 100;                      % ���������� 
Min__cost_Route = zeros(iter_max,n+20); % ������С�ɱ�·��       
Min_cost = zeros(iter_max,1);        % ������С�ɱ�  
Limit_iter = 0;                      % ��������ʱ��������
Load=zeros(K,1);                     %����ÿ�γ�������ʱ���������
%--------------------------------------------------------------------------
load=0;%��ʼ������Ϊ0
count=1;%��������������Ŀ

%����Ⱥ�㷨���е���
while iter<=iter_max
    %���������ϵ������и�Ϊ1
    Table(:,1)=1;%���������ϵĳ�ʼλ�ö����ó�1
    %������ռ�
    citys_index = 1:n;
    i=1;
    %������Ͻ��г���ѡ��
    while i<=m
        j=2;
        %������н���·��ѡ��
        while j<=n
            has_visited=Table(i,1:(j-1));%�Ѿ����ʵĳ��м���
            allow_index=~ismember(citys_index,has_visited);%�ж���Щ���л�û�з���
            allow= citys_index(allow_index);%�����ʳ��еļ���
            P=allow;
            %������м���ʵĸ���
            for k=1:length(allow)
                P(k) = Tau(has_visited(end),allow(k))^alpha * Heu_F(has_visited(end),allow(k))^beta;
            end
            P=P/sum(P);
            %�����̶ķ���ѡ����һ�����ʳ���
            Pc = cumsum(P);     %������������ۼ�Ԫ�صĺ�
            target_index = find(Pc >= rand);%rand �������һ��0-1�ڵ���
            target = allow(target_index(1));%�����һ��Ҫ���ʵĳ������
            load=load+Requirement(target,2);%����������������к���������
            if(load>Qm)
                Load(i,count)=load-Requirement(target,2);%���汾����������������
                target=1;%�����ᳬ�أ����������ʱ�򷵻���������
                load=0;%�����ϵĳ�ʼ������0
                count=count+1;%��������һ
                n=n+1;%����ѡ�������һ
                Table(i,j) = target;
            else
                Table(i,j) = target;%���û�г��أ�������ϵ�iֻ���ϵ�j��Ҫ���ʵĳ���
            end
            j=j+1;
        end
        Load(i,count)=load;%�����һ�ε���������������ȥ
        Table(i,n+1)=1;%���ϻص�ԭ���ĳ���
        load=0;%����ʼ������0
        count=1;%����������0
        n=size(D,1);
        i=i+1;
    end
%--------------------------------------------------------------------------
    %������ܳɱ�
    Cost=zeros(m,1);
    %�õ��̶��ɱ�
    for i=1:m%ȡ����iֻ�����ߵĳ���
        route=Table(i,:);
        temp_distance=Cal_distance(route,D);%�����������·���ܾ���
        temp_difference=Cal_Max2Min(route,D);%���������·���Ĳ�ֵ
        %disp(['��ֵ=',num2str(temp_difference)]);
        if((temp_difference<=250)&&(temp_distance<=4980))%�ж�
            myLoad=Load(i,:);%ȡ����ֻ���ϵ�ÿ�ε�������
            C1=K*p_truck;%�̶��ɱ�
            C2=GoodsLost_cost(route,D,ST,p_lostgoods,myLoad,Requirement,v,alpha1,alpha2);%������ʧ�ɱ�
            %disp(['C2=' num2str(C2)]);
            C3=TimePunishment_cost(route,D,TimeWindows,v,ST,p_early,p_late);%ʱ��ͷ��ɱ�
            %disp(['C3=' num2str(C3)]);
            C4=Refrigeration_cost(route,ST,D,v,p_trefrigeration,p_lrefrigeration);%����ɱ�
            %disp(['C4=' num2str(C4)]);
            C5=Transport_cost(route,myLoad,Requirement, D,ph_empty,ph_full,Qm,p_fuel,f);%����ɱ�
            %disp(['C5=' num2str(C5)]);
            C6=Cal_welfare(route,D,extra,extra_cost);%Ӧ�ø�˾�����ļӰ����
            %disp(['C6=' num2str(C6)]);
            Cost(i)=C1+C2+C3+C4+C5+C6;%�����ε��������е��������ϵ��ܳɱ���¼����
            %disp(['Cost(i)' num2str(Cost(i))]);
        else
            Cost(i)=100000;%����һ������ֵ����ʾ�������������
            %disp(['Cost(i)' num2str(Cost(i))])
        end
            
            
    end
    %�������С�ɱ�
    if iter==1%��һ�ε��������
        [min_cost,min_index]=min(Cost);%�ҵ���С�ɱ�·���Լ���С�ɱ�·�������ϱ��
        Min_cost(iter)=min_cost;%�������������С�ɱ�
        Min__cost_Route(iter,:)=Table(min_index,:);%ͨ�����·�������ϱ��ȡ����Ӧ��·��
        Limit_iter = 1; %���������ĵ�������Ϊ1��
    else
        [min_cost,min_index]=min(Cost);%�ҵ���С�ɱ�·���Լ���С�ɱ�·�������ϱ��
        Min_cost(iter)=min(Min_cost(iter-1),min_cost);%�Ƚϱ�������С�ɱ�����һ�����·����ȡ��С
        if Min_cost(iter)==min_cost%%��������������ߵ���С�ɱ�����һ����С
            Min__cost_Route(iter,:)=Table(min_index,:);%ͨ����С�ɱ������ϱ��ȡ����Ӧ��·��
            Limit_iter = iter;%���������ĵ������������ڱ��εĵ�������
        else%�����һ���������ߵ���С�ɱ�����һ����ҪС����ô���ε���С�ɱ���Ϊ��һ������С�ɱ�
             Min__cost_Route(iter,:)= Min__cost_Route((iter-1),:);
        end    
    end
    % ����������ϵ�·������
    Length = zeros(m,1);
    for i = 1:m
        Route = Table(i,:);%ȡ����iֻ�����ߵĳ���
        temp=sum(sum(Route~=0));%��ȡ�����з�0Ԫ�صĸ��� ���߹��ĳ��еĸ���
        for j = 1:temp-1
            Length(i) = Length(i) + D(Route(j),Route(j + 1));%�����iֻ�����ߵ���·������
        end
    end    
    %��������ģ����������Ϣ��
    Delta_Tau = zeros(n,n);
    % ������ϼ���
    for i = 1:m
        % ������м���
        for j = 1:(n - 1)
            Delta_Tau(Table(i,j),Table(i,j+1)) = Delta_Tau(Table(i,j),Table(i,j+1)) + Q/Length(i);%��iֻ�����ڵ�j�γ���ʱ��·�����µ���Ϣ��
        end
    end
    Tau = (1-vol) * Tau + Delta_Tau; %��Ϣ�ر�=�ӷ�ʣ�����Ϣ��+�����ߵ���Ϣ��
    % ����������1�����·����¼��
    iter = iter + 1;
    Table = zeros(m,n+20);
end
%--------------------------------------------------------------------------
%�����ʾ
[min_cost,index]=min(Min_cost);
min_cost_route=Min__cost_Route(index,:);
%ȥ�������0Ԫ��
temp=min_cost_route(min_cost_route~=0);
min_cost_length=Cal_distance(temp,D);
final_result=Cal_result(temp,D);
difference=Cal_Max2Min(temp,D);
max_length=Cal_Max(temp,D);
min_length=Cal_Min(temp,D);
disp(['��С�ɱ�:' num2str(min_cost)]);
disp(['��С�ɱ�·��:' num2str([temp])]);
disp(['��С�ɱ�·������:',num2str(min_cost_length)]);
disp(['��С�ɱ�·�������·��:',num2str(max_length)]);
disp(['��С�ɱ�·������С·��:',num2str(min_length)]);
disp(['��С�ɱ�·����ֵ:',num2str(difference)]);
disp(['������������:' num2str([Limit_iter])]);
%% ��ͼ
figure(1)
plot(citys(temp,1),citys(temp,2),'o-');%�����·�ߴӿ�ʼ��������������
grid on%������
for i = 1:size(citys,1)
    text(citys(i,1),citys(i,2),['   ' num2str(i)]);
end
text(citys(temp(1),1),citys(temp(1),2),'       ���');
text(citys(temp(end),1),citys(temp(end),2),'       �յ�');
xlabel('����λ�ú�����')
ylabel('����λ��������')
title(['ACA���Ż�·��(��С�ɱ�:' num2str(min_cost) ')'])


