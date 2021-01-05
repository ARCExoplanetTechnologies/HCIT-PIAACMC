function [sources] = initialize_extendedSources(Npt,stellarRad);
       % central star
       rsource = rand(Npt,1);
       tsource = 2*pi*rand(Npt,1);
       xsource = stellarRad*sqrt(rsource).*cos(tsource);
       ysource = stellarRad*sqrt(rsource).*sin(tsource);
       
       disp(['Initializing Extended Source with Npt = ' num2str(Npt) ', R = ' num2str(stellarRad,'%.2e')])
       %sources = params.sources;
       for iSource = 1:Npt
           sources(iSource).mult = 1;
           sources(iSource).x = xsource(iSource);
           sources(iSource).y = ysource(iSource);
       end
end

