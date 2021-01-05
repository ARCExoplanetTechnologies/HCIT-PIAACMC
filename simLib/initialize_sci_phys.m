function sci = initialize_sci_phys(params)
%lambdaRef = params.lambdaRef;
flD = params.flD;
%samplesPerflD = params.samplesPerflD;
%FOVflD = params.FOVflD;

% initialize science plane
% sci.FOVflD = FOVflD;
sci.flD = flD;
% sci.samplesPerflD = samplesPerflD;
% sci.pixAngSize = 1/samplesPerflD;
% sci.dx = flD / samplesPerflD;
% sci.dy = flD / samplesPerflD;
sci.dx = params.CCD_pixel_size;
sci.dy = params.CCD_pixel_size;
sci.Nx = params.width;
sci.Ny = params.height;
sci.N = sci.Nx;
sci.gridsizeX = sci.Nx*sci.dx;
sci.gridsizeY = sci.Ny*sci.dy;
sci.x = -(sci.gridsizeX - sci.dx)/2 : sci.dx : (sci.gridsizeX - sci.dx)/2;
sci.xlD = sci.x / sci.flD;
sci.y = -(sci.gridsizeY - sci.dy)/2 : sci.dy : (sci.gridsizeY - sci.dy)/2;
sci.ylD = sci.y / sci.flD;
[sci.xx sci.yy] = meshgrid(sci.x, sci.y);
sci.xxlD = sci.xx / sci.flD;
sci.yylD = sci.yy / sci.flD;
sci.rr = sqrt(sci.xx.^2 + sci.yy.^2);
sci.rrlD = sci.rr / sci.flD;

