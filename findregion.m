function regIDs=findregion(PDE,pts)
%Return region IDs for a given set of [x,y] points in a geometry
%
%   This function is for use with the C5G7 demo to properly allocate
%   material-dependent coefficients to pin element regions in the model.
%
%   MATLAB does not include an easy way to do this, so it is necessary
%   to loop over all regions using findNodes to locate the region that
%   has the point contained in it.
%
%   Connor Moore, 2024, <connor.moore@ontariotechu.net>

arguments
    PDE (1,1)
    pts (:,2) double {mustBeNumeric} % column vectors of [x,y] pts
end

    rmax=0.3; % search radius for element around given point
    [npts,~]=size(pts); % define number of points. length(pts) fails for
                        % 1 single coordinate.
    regs=zeros(npts,1); % predefine region IDs 

    for ipts=1:npts % loop over all given points
        elmID=findNodes(PDE.Mesh,"radius",[pts(ipts,:)],rmax); % node ID
        if(length(elmID)>1)
            elmID=elmID(1); % if many nodes found, use the first
        end
        for iregion=1:PDE.Geometry.NumFaces % loop over every region
            if ismember(elmID,findNodes(PDE.Mesh,"region","face",iregion))
                regs(ipts)=iregion;
                %fprintf("found region %i/%i\n",nnz(regs),npts)
                break;
            end
            if(iregion==PDE.Geometry.NumFaces)
                error("findregion:noRegionFound","Region not found");
            end
        end
    end
    regIDs=regs;
end