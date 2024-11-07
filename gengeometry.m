function geom=gengeometry(pts)
%Generate geometry for decsg by converting into zero-padded 10x1 form
%   (see: <https://www.mathworks.com/help/pde/ug/decsg.html>)
%
%   Connor Moore, 2024, <connor.moore@ontariotechu.net>

arguments
    pts (:,:) {mustBeNumeric} % array of points data for shapes
end

[nr,nc]=size(pts); % number of rows and columns

out=zeros(10,nc); % define a nr=10 x nc matrix to fill in columnwise

for icol=1:nc
    switch nr % number of rows determines the shape
        case 3 % circle case, input=[x0,y0,r]
            out(1:4,icol)=[1;pts(:,icol)];
            % output of form [1,x0,y0,r,0,0,0,0,0,0]
            
        case 4 % rectangular case, input=[x0,y0,x1,y1]
            out(:,icol)=[3;4;pts(1,icol);pts(1,icol);pts(3,icol);pts(3,icol); ...
                pts(2,icol);pts(4,icol);pts(4,icol);pts(2,icol)];
            % output of form [3,4,x0,x0,x1,x1,y0,y1,y1,y0]

        otherwise
            error("gengeom:incorrectGeometry", ...
                "Unsupported geometry strcture");
    end
    geom=out;
end
end