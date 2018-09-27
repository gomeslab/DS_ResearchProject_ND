function vp = khex(nhex, a, type)
% generates the position for the CO molecules to form a hexagonal or
% triangular lattice.
% input: nhex = number of hexagons (radius of lattice)
%           a = atomic lattice size
%           type = 1 => honeycomb (CO in triangular lattice)
%           type = 2 => triangular (CO in honeycomb)

if nargin < 2, a=2.55; end;
if nargin < 3, type = 1; end;

% generating the honeycomb (CO in triangular lattice)
if type==1,
    vp=[0,0];
    for na=1:nhex
        vpl=zeros(6,2);
        for ni = 0:5
            vpl(ni+1,:)=[na*a*cos(pi/3*ni) na*a*sin(pi/3*ni)];
        end;
        vp=[vp; vpl];
        for ni = 1:6
            v1 = vpl(ni, :);
            v2 = vpl(mod(ni,6)+1, :);
            vd = (v2-v1)/na;
            for nj = 1:na-1
            vp = [vp; v1 + nj*vd];
            end;
        end;
    end;
end;

% generating the triangular lattice (CO in honeycomb)
if type==2,
    vp=[0,0];
    for na=1:nhex-1
        vpl=zeros(6,2);
        for ni = 0:5
            vpl(ni+1,:)=[na*a*cos(pi/3*ni) na*a*sin(pi/3*ni)];
        end;
        vp=[vp; vpl];
        for ni = 1:6
            v1 = vpl(ni, :);
            v2 = vpl(mod(ni,6)+1, :);
            vd = (v2-v1)/na;
            for nj = 1:na-1
            vp = [vp; v1 + nj*vd];
            end;
        end;
    end;
    vpa=[vp(:,1),vp(:,2)-a/sqrt(3)];
    vpl=zeros(4,2);
    for ni = 0:3
        vpl(ni+1,:)=[nhex*a*cos(pi/3*ni) nhex*a*sin(pi/3*ni)-a/sqrt(3)];
    end;
    vpa=[vpa; vpl(2:3,:)];
    for ni = 1:3,
        v1 = vpl(ni, :);
        v2 = vpl(ni+1, :);
        vd = (v2-v1)/nhex;
        for nj = 1:nhex-1
            vpa = [vpa; v1 + nj*vd];
        end;
    end;
    vpb=[vp(:,1),vp(:,2)+a/sqrt(3)];
    for ni = 0:3
        vpl(ni+1,:)=[nhex*a*cos(pi/3*ni) -nhex*a*sin(pi/3*ni)+a/sqrt(3)];
    end;
    vpb=[vpb; vpl(2:3,:)];
    for ni = 1:3,
        v1 = vpl(ni, :);
        v2 = vpl(ni+1, :);
        vd = (v2-v1)/nhex;
        for nj = 1:nhex-1
            vpb=[vpb; v1 + nj*vd];
        end;
    end
    vp=[vpa;vpb];
end;