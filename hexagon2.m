function line=hexagon2(x)

k=68.85;

line1x=linspace(-k/2,k/2,10);
line1y=linspace(-k/2*sqrt(3),-k/2*sqrt(3),10);
for i=1:10
    line1{i}=[line1x(i),line1y(i)];
end

line2x=linspace(k/2,k,10);
line2y=linspace(-k/2*sqrt(3),0,10);
for i=1:10
    line2{i}=[line2x(i),line2y(i)];
end

line3x=linspace(k,k/2,10);
line3y=linspace(0,k/2*sqrt(3),10);
for i=1:10
    line3{i}=[line3x(i),line3y(i)];
end

line4x=linspace(k/2,-k/2,10);
line4y=linspace(k/2*sqrt(3),k/2*sqrt(3),10);
for i=1:10
    line4{i}=[line4x(i),line4y(i)];
end

line5x=linspace(-k/2,-k,10);
line5y=linspace(k/2*sqrt(3),0,10);
for i=1:10
    line5{i}=[line5x(i),line5y(i)];
end

line6x=linspace(-k,-k/2,10);
line6y=linspace(0,-k/2*sqrt(3),10);
for i=1:10
    line6{i}=[line6x(i),line6y(i)];
end

line=[line1,line2,line3,line4,line5,line6];
line=cell2mat(line');
line=uniquetol(line,'ByRows',true);
% plot(line(:,1), line(:,2), 'xr', 'MarkerSize', 10, 'LineStyle', 'None')