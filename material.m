classdef material
   %%   Specification class to handle material-specific cross sections.
    %   Material class is an object type that houses specific cross
    %   sections imported from a spreadsheet and calculates parameters
    %   such as the diffusion coefficient. It is introduced to make
    %   code in the C5G7 demo much more readable and to provide a 
    %   framework for easy access to material data.
    %
    %   Each cross section listed under propery is a 1 x Ng column vector 
    %   containing the respective cross section for each energy group Ng.
    %
    %   Scattering cross-sections are represented using an Ng x Ng
    %   scattering block matrix, which represents both up and down
    %   scattering cases for all energy groups.
    %
    %   All data is taken from individual CSV files containing
    %   the material cross sections augmented with a scattering
    %   block. All values are taken from the C5G7 document.
    %
    %   Connor Moore, 2024, <connor.moore@ontariotechu.net>

    properties
        total (:,1) double {mustBeNumeric} % total Xs (Σtot)
        transport (:,1) double {mustBeNumeric} % transport Xs (Σtr)
        absorption (:,1) double {mustBeNumeric} % absorption Xs (Σa)
        capture (:,1) double {mustBeNumeric} % capture Xs (ΣΥ)
        fission (:,1) double {mustBeNumeric} % fission Xs (Σf)
        nu (:,1) double {mustBeNumeric} % neutrons per fission (ν)
        chi (:,1) double {mustBeNumeric} % fission spectrum (χ)
        scatter (:,:) double {mustBeNumeric} % scattering block (Σs)
        diffusion (:,1) double {mustBeNumeric} % diffusion coefficient (D)
    end

    methods
        function obj = material(XSfile)
            %Construct a material instance.
            %   Given a cross section file, read the values for the energy
            %   dependent cross sections and scattering block
            arguments
                XSfile (:,1) string % file name string
            end
            % first import the specific sheet from the excel file
            rawdata=readmatrix(XSfile);

            % the number of energy groups is then calculated with the
            % assumption that the values are in a 2Ng x Ng matrix
            Ng=length(rawdata)/2;
            
            % now populate the cross sections
            obj.total=rawdata(1:Ng,1);
            obj.transport=rawdata(1:Ng,2);
            obj.absorption=rawdata(1:Ng,3);
            obj.capture=rawdata(1:Ng,4);
            obj.fission=rawdata(1:Ng,5);
            obj.nu=rawdata(1:Ng,6);
            obj.chi=rawdata(1:Ng,7);
            
            % and the scattering block
            obj.scatter=rawdata(Ng+1:end,:);
            
            % lastly calculate the diffusion coefficient
            % D = 1/(3*(Σa+Σtr))
            obj.diffusion=1./(3.*(obj.absorption+obj.transport));
            
        end
    end
end