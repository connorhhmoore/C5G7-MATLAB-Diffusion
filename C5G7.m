%%  MATLAB 7 energy group solution of the C5G7 test problem
%   This code is simulating the C5G7 demonstration for deterministic
%   neutron transport solvers. It uses MATLAB's PDE Toolbox to define
%   and construct a model with material coefficients based on cross
%   sections provided in the C5G7 document. The solution for each flux
%   energy group is plotted and an eigenvalue (keff) is found.
%
%   Connor Moore, 2024, <connor.moore@ontariotechu.net>

close all;
clear;

addpath("XS_Data");

%% Predefine some useful dimensions
sl=64.26; % side length
lp=1.26; % lattice pitch
per=0.54; % pin element radius

%% Initialize the pde model and geometry

demoC5G7=createpde(7);

circs=arraypattern([lp/2,sl-lp/2,per],[34,34],[lp,-lp]); % fuel pins
ob=[0,0,sl,sl]'; % outer boundary box
sbd=arraypattern([0,sl/3,sl/3,sl*2/3],[2,2],[sl/3,sl/3]); % subdivisions

meshgeom=[gengeometry([ob,sbd]),gengeometry(circs)];
meshgeom=decsg(meshgeom);
geometryFromEdges(demoC5G7,meshgeom);

%{
% geometry faces plot
figure(Name="Faces plot of geometry"); % faces plot
pdegplot(meshgeom,"FaceLabels","off","EdgeLabels","on");
grid on;
axis equal padded;
%}

% geometry mesh plot
figure(Name="Mesh plot of geometry");
generateMesh(demoC5G7,"Hface",{2:demoC5G7.Geometry.NumFaces,per/2}, ...
    "Hmax",2,"GeometricOrder","linear","Hedge",{[5,6,7,14],0.1}, ...
    "Hgrad",1); 
% specify a fine mesh only inside the inner 2/3 region
pdeplot(demoC5G7);
title("C5G7 Mesh");
grid on;
axis equal padded;

%% Assign coefficients to each pin
% restructure so the original grid system from the problem is accurate
[xp,yp]=meshgrid(1:34); % gen mesh
latticepts=[xp(:),flip(yp(:))]*lp-lp/2; % offset to match grid
latticepts(:,2)=latticepts(:,2)+sl/3; % offset to sit in ul corner

% load excel file containing cross section data
% construct materials for the reactor
MOD=material("MODERATOR");
UO2=material("UO2");
MOX43=material("MOX43");
MOX70=material("MOX70");
MOX87=material("MOX87");
GT=material("GUIDETUBE");
FC=material("FISSIONCHAMBER");

% load core map
load("corelayout.mat");
corelayout=corelayout(:);

% assign entire reactor as moderator first
assigncoeff(demoC5G7,1:demoC5G7.Geometry.NumFaces,MOD);

% assign specific coefficients to each pin
assigncoeff(demoC5G7,findregion(demoC5G7, ...
    findpts("UO2",latticepts,corelayout)),UO2);
assigncoeff(demoC5G7,findregion(demoC5G7, ...
    findpts("4.3MOX",latticepts,corelayout)),MOX43);
assigncoeff(demoC5G7,findregion(demoC5G7, ...
    findpts("7.0MOX",latticepts,corelayout)),MOX70);
assigncoeff(demoC5G7,findregion(demoC5G7, ...
    findpts("8.7MOX",latticepts,corelayout)),MOX87);
assigncoeff(demoC5G7,findregion(demoC5G7, ...
    findpts("GT",latticepts,corelayout)),GT);
assigncoeff(demoC5G7,findregion(demoC5G7, ...
    findpts("FC",latticepts,corelayout)),FC);

% vacuum boundary on edges [1,8]
applyBoundaryCondition(demoC5G7,"neumann","edge",[1,8], ...
    "q",eye(7)./(3*0.7104),"g",zeros(7,1));

% reflective boundary on edges [2,3,4,9,10,11]
applyBoundaryCondition(demoC5G7,"neumann","edge",[2,3,4,9,10,11], ...
    "q",zeros(7,7),"g",zeros(7,1));

% solve and calculate keff
solution=solvepdeeig(demoC5G7,[0.25,15]) % keff in range [1/15,4]
keff=1/min(solution.Eigenvalues)

%% Postprocessing and plots
% lattice configuration
figure(Name="C5G7 Inner Lattice");
findpts("UO2",latticepts,corelayout);
scatter(ans(:,1),ans(:,2),"filled");
hold on;
findpts("4.3MOX",latticepts,corelayout);
scatter(ans(:,1),ans(:,2),"filled");
findpts("7.0MOX",latticepts,corelayout);
scatter(ans(:,1),ans(:,2),"filled");
findpts("8.7MOX",latticepts,corelayout);
scatter(ans(:,1),ans(:,2),"filled");
findpts("GT",latticepts,corelayout);
scatter(ans(:,1),ans(:,2),"filled");
findpts("FC",latticepts,corelayout);
scatter(ans(:,1),ans(:,2),"filled");
hold off;
grid on;
title("C5G7 Lattice");
legend(["UO_2","4.3% MOX","7.0% MOX","8.7% MOX","Guide Tube", ...
    "Fission Chamber"]);

% plots for each energy group
for igroup=1:7
    figure(Name="C5G7 Group "+igroup+" flux");
    if(sum(solution.NodalSolution(:,igroup))<0)
        XYsoln=-solution.NodalSolution(:,igroup);
    else
        XYsoln=solution.NodalSolution(:,igroup);
    end
    pdeplot(solution.Mesh,XYData=XYsoln,Colormap="turbo");
    title("C5G7 Group "+igroup+" Flux, k_{eff} = "+keff);
    xlabel("X-coordinate [cm]");
    ylabel("Y-coordinate [cm]");
    xlim([0,sl]);
    ylim([0,sl]);
    box on;
    xticks(0:10:sl);
    set(gca,"Layer","Top");
    yticks(0:10:sl);
    set(gca,"Layer","Top");
    clim([0,6]*1e-3)
end