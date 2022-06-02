% Copyright (c) 2022 Gouhei Tanaka. All rights reserved.
% Citation: G.Tanaka and R.Nakane, Scientific Reports (2022).
% DOI: 10.1038/s41598-022-13687-z

function showNet(Nn,Am,Ai)

%%%%% input
% Nn: Number of circuit nodes
% Am: Adjacency matrix of memristors
% Ai: Adjacency matrix of voltage source

figure(1); clf;

%%%%% nodes on a circle
z = zeros(Nn,2);
t = linspace(0,2*pi,Nn+1);
for i=1:Nn
    z(i,1) = cos(t(i));  % x-coordiate
    z(i,2) = sin(t(i));  % y-coordiate
end
scatter(z(:,1),z(:,2),'ko');
for i=1:Nn
    text(1.1*z(i,1),1.1*z(i,2),num2str(i));
end
hold on;

%%%%% memristor branches 
for i=1:Nn
    for j=i+1:Nn
        if Am(i,j) == -1  % i->j
            quiver(z(i,1),z(i,2),z(j,1)-z(i,1),z(j,2)-z(i,2),0,'b','LineWidth',1,'AutoScaleFactor',1);
            hold on;
        elseif Am(i,j) == 1 % j->i
            quiver(z(j,1),z(j,2),z(i,1)-z(j,1),z(i,2)-z(j,2),0,'b','LineWidth',1,'AutoScaleFactor',1);
            hold on;
        end
    end
end

%%%%% voltage source
for i=1:Nn
    for j=i+1:Nn
        if Ai(i,j) == -1  % i->j
            quiver(z(i,1),z(i,2),z(j,1)-z(i,1),z(j,2)-z(i,2),0,'r:','LineWidth',3);
            hold on;
        elseif Ai(i,j) == 1  % j->i
            quiver(z(j,1),z(j,2),z(i,1)-z(j,1),z(i,2)-z(j,2),0,'r:','LineWidth',3);
            hold on;
        end
    end
end

% legend and title
quiver(1,1.2,0.1,0,0,'b','LineWidth',1);
text(1.15,1.2,'Memristor branch')
quiver(1,1.1,0.1,0,0,'r:','LineWidth',3);
text(1.15,1.1,'Voltage source')
title('Structure of memristor network')

axis off;
hold off;
