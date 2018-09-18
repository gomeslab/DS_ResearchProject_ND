function line=hexagon(x)

line1x=linspace(-33.15,33.15,14);
line1y=linspace(-33.15*sqrt(3),-33.15*sqrt(3),14);
for i=1:14
    line1{i}=[line1x(i),line1y(i)];
end

line2x=linspace(33.15,66.3,14);
line2y=linspace(-33.15*sqrt(3),0,14);
for i=1:14
    line2{i}=[line2x(i),line2y(i)];
end

line3x=linspace(66.3,33.15,14);
line3y=linspace(0,33.15*sqrt(3),14);
for i=1:14
    line3{i}=[line3x(i),line3y(i)];
end

line4x=linspace(33.15,-33.15,14);
line4y=linspace(33.15*sqrt(3),33.15*sqrt(3),14);
for i=1:14
    line4{i}=[line4x(i),line4y(i)];
end

line5x=linspace(-33.15,-66.3,14);
line5y=linspace(33.15*sqrt(3),0,14);
for i=1:14
    line5{i}=[line5x(i),line5y(i)];
end

line6x=linspace(-66.3,-33.15,14);
line6y=linspace(0,-33.15*sqrt(3),14);
for i=1:14
    line6{i}=[line6x(i),line6y(i)];
end

line=[line1,line2,line3,line4,line5,line6];
line=cell2mat(line');
line=uniquetol(line,'ByRows',true);

% plot(line(:,1), line(:,2), 'xr', 'MarkerSize', 10, 'LineStyle', 'None')