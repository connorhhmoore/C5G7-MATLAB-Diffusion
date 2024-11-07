function assigncoeff(PDE,regIDs,mat)
%Assign PDE coefficients to region IDs given their material
%
%   This function generates and assigns coefficients to regions
%   by calculating the 'c', 'a', and 'd' and applying them to each
%   provided region ID.
%
%   Connor Moore, 2024, <connor.moore@ontariotechu.net>

arguments
    PDE (1,1)
    regIDs (:,1) {mustBeInteger}
    mat (1,1) material
end

c = [mat.diffusion,mat.diffusion*0,mat.diffusion]';

a = diag(sum(transpose(mat.scatter-diag(diag(mat.scatter)))) + ...
    mat.absorption')-transpose(mat.scatter-diag(diag(mat.scatter)))';

d = transpose(mat.chi*(mat.nu'.*mat.fission'));

specifyCoefficients(PDE,c=c(:),a=a(:),d=d(:),m=0,f=0,Face=regIDs);

end