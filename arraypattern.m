function ptrn=arraypattern(geom,num,spacing)
%Generates an array pattern (like in AutoCAD) for a given geometry.
%
%   Connor Moore, 2024, <connor.moore@ontariotechu.net>

arguments
    geom (:,1) {mustBeNumeric} % geometry matrix for shape
    num (2,1) {mustBeInteger} % number of [rows,columns] for pattern
    spacing (2,1) {mustBeNumeric} % spacing for rows and columns
end

addx=0:spacing(1):(num(1)-1)*spacing(1); % x spacing
addy=0:spacing(2):(num(2)-1)*spacing(2); % y spacing

[addx,addy]=meshgrid(addx,addy); % generate mesh grid from spacings
pts=[addx(:),addy(:)]; % num(pts)x2 vector of x,y coordinates

switch numel(geom)
    case 3 % circular geometry case, [x0,y0,r]
        colvec=ones(numel(pts)/2,1);
        pts=pts+colvec.*[geom(1),geom(2)];
        ptrn=[pts';geom(3)*ones(1,numel(pts)/2)];
    case 4 % rectangular geometry case [x0,y0,x1,y1]
        colvec=ones(numel(pts)/2,1);
        xpts=pts+colvec.*[geom(1),geom(3)]; % [x0,x1]
        ypts=pts+colvec.*[geom(2),geom(4)]; % [y0,y1]
        ptrn=transpose([xpts,ypts]); % [x0;y0;x1;y1]
    otherwise
        error("arraypattern:incorrectGeometry", ...
            "Unsupported geometry strcture");
end
end