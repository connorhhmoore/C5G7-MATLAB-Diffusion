function pts = findpts(material,lattice,layout)
%Find respective points in the C5G7 lattice given a material
%   The purpose of this function is to take a material name
%   and return a set of points representing the locations of
%   pins made of the material.
%
%   Connor Moore, 2024, <connor.moore@ontariotechu.net>

arguments
    material (1,1) string
    lattice(:,2) double {mustBeNumeric}
    layout (:,:) string
end
    
    key=layout==material;
    pts=lattice(key,:);

end