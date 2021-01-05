function DMact = DMsurfToDMact(DMsurf, InfFunc, Nact, Mact);

% This function finds the closest DM actuators to a given DM surface assuming the
% influence function model with circular boundary conditions. It uses FFTs to perform the deconvolution. The DM actuators that it
% finds is (I think) optimal in a least-squares sense.
%
% DMsurf can be complex, in which case its imaginary part represents amplitude variations.
%
% The output DMact will be Nact x Mact in size. It will be
% complex-valued, but if DMsurf and InfFunc are real, then the imaginary
% part of DMact will be machine-precision close to 0.

[Nsurf Msurf] = size(InfFunc);

FTDMsurf = fft2(DMsurf);
FTInfFunc = fft2(InfFunc);

FTDMactBig = FTDMsurf./FTInfFunc;

% Fix divide by zero problems. Dividing by 0 means there are many possible solutions for DMact that will generate the same DMsurf. I am setting the result of dividing by 0 to 0, which picks one particular solution.
FTDMactBig(FTInfFunc == 0)=0; % Fix divide by zero problems. Dividing by 0 means there are many possible solutions for DMact that will generate the same DMsurf. I am setting the result of dividing by 0 to 0, which picks one particular solution.

% adjust the phase of the FT of DMsurf in order to account for the
% shift from corner to center of each actuator
fx = [(0:ceil(Msurf/2)-1) (ceil(-Msurf/2):-1)]/Msurf;
fy = [(0:ceil(Nsurf/2)-1) (ceil(-Nsurf/2):-1)]'/Nsurf;
fxs = ones(Nsurf,1)*fx;
fys = fy*ones(1,Msurf);
FTDMactBig = FTDMactBig./exp(2*pi*i*(fxs*(Msurf*(1-1/Mact)/2) + fys*(Nsurf*(1-1/Nact)/2)));

% Truncate to Nact x Mact
FTDMact = FTtruncate(FTDMactBig, Nact, Mact);

DMact = ifft2(FTDMact);