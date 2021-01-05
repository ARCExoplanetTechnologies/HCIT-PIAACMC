%% Dan Sirbu  / 2020-01-05
%% PIAACMC Model with propagation through PIAA optics

profile on

clear all
clc
format compact
warning off all

docPref = '';
docComm = '';

profile on

%%  Define constants, parameters, paths, and settings
libPath = 'simLib\';
utilPath = 'utilLib\';
propPath = 'propLib\';
addpath(libPath);
addpath(utilPath);
addpath(propPath);

units
runNum = 281;

%% define optical system parameters, pupil, and image planes
configDir = '';
lambdaRef = 635e-9;

[runDir dmDir imagDir] = make_dirs(runNum);

disp('Initializing System Parameters')
% set config

params.dir = configDir; % optical element look-up location
params.Nelem = 14; % number of optical elements
params.Nread = 2048;  % number of samples across one side of pupil planes for read-in elements
params.N = 256;  % number of samples across one side of pupil planes for propagation
params.resampleMethod = 'FTdownsample'; % available methods are: 'FTdownsample' and 'linear'
params.lambdaRef = lambdaRef; % set reference lambda for focal plane mask
params.opticalPrescriptionFileName = 'opticalElements_luvoirA_piaacmc_compactPIAA.xlsx'; % read excel file with elements
params.padfactor = 2;

% definition of primary
params.primary.D = 2*14.2e-3;
params.primary.fnum = 85.0; % f-number of telescope
params.primary.f = params.primary.D*params.primary.fnum; % find actual focal length
params.primarySurfaceRMS = 0; % surface errors at primary
params.primaryReflectivityRMS = 0;     % reflectivity errors at 
params.primaryAlpha = 2;               % aberrations ramp shape
params.flatAlphaFrac = 0.03;         % fraction of samples FT plane for which aberrations envelope is flat
params.Nalpha = params.N*params.flatAlphaFrac;  % number of samples across FT plane for which random aberrations are flat (before flattening)

% usage of PIAA
params.usePIAA = 1;
params.useInvPIAA = 0;

% definition of PIAA
params.PIAA.pupilStop = 1;              % stopped-down PIAA fraction
params.PIAA.magnification = 1.337683015572162;     % assumed magnification

% beam-radius (used to size pupil planes)
params.overSizeFactor = 1;
params.beamrad = params.primary.D/2;
params.gridrad = params.overSizeFactor*params.primary.D/2;
params.gridCentering = 'cell'; %centering options are 'cell' or 'vertex'

% definition of DMs
params.numDM = 1;
params.DM(1).numAct = 34;
params.DM(1).diameter = 2*14.2e-3;
params.DM(1).actSpacing = params.DM(1).diameter / params.DM(1).numAct;
params.DM(1).infFuncSigma = 1.3;
params.DM(1).numActTotal = params.DM(1).numAct*params.DM(1).numAct;
params.DM(1).elemID = 9;

params.numActTotal = 0;
startAct = 1;

for iDM = 1:params.numDM 
    params.DM(iDM).startAct = startAct;
    params.DM(iDM).endAct = params.DM(iDM).startAct + params.DM(iDM).numActTotal - 1;
    startAct = startAct + params.DM(iDM).numActTotal
    params.numActTotal = params.numActTotal  + params.DM(iDM).numActTotal;
    params.DM(iDM).relinNum = 1;
end

% definition of focal plane (mask) occulter
params.fpm.lambdaRef = lambdaRef;       % reference lambda for which the focal plane mask size is defined
params.fpm.InnflD = 1.9;                % focal plane mask inner radius in units of flD
params.fpm.OutflD = 3.72;                 % focal plane mask outer radius in units of flD
params.fpm.FOVflD = params.fpm.OutflD*2; % field of view used to sample focal plane mask across (twice the opening)
params.fpm.f = params.primary.f;        % focal length before the focal plane mask (set the same as for telescope/science plane)
params.fpm.flD = params.fpm.f*params.fpm.lambdaRef/params.primary.D; % define focal plane mask units of flD
params.fpm.samplesPerflD = 276.25;
params.fpm.t = -0.045436856855254;
params.fpm.idealRad = params.fpm.InnflD*params.fpm.flD;
params.fpm.elemID = 11;
params.fpm.usePrePropMask = true;       % prePropagate mask for pupil_to_lyot
params.fpm.babinet = true;

% definition of Lyot stop (annular)
params.lyotStop.FracInn = 0.1;         % lyot stop inner radius (as a fraction of total opening)
params.lyotStop.FracOut = 0.9;         % lyot stop outer radius (as a fraction of total opening)

% definition of science camera
params.sci.lambdaRef = lambdaRef;      % similar definition to fpm
params.sci.FOVflD = 37.5058;
params.sci.samplesPerflD = 4.6395;          % sampling in units of flD
params.sci.flD = params.primary.f*params.lambdaRef/params.primary.D; % definition of units of flD for the science camera

% stetch science focal plane coordinates if needed for PIAA
if params.usePIAA == 1
    if params.useInvPIAA == 0
        params.sci.flD = params.sci.flD*params.PIAA.magnification;
    end
end

% definition of scoring/control regions
params.regionType = 'shiftAnnular';         % 'rectangular', 'annular', 'shiftAnnular'
params.ScoreMaskReg = [2 8 -2 2];        % inner and outer radius of high-contrast region
params.innerDZcutOff = 11;                  % not used here (would define inner/outer regions)
params.IWZScoreReg = [params.ScoreMaskReg(1) params.innerDZcutOff -4 4];
params.OWZScoreReg = [params.innerDZcutOff params.ScoreMaskReg(2) -4 4];
params.CorAngularSize = 180;                % angular extent in deg. of dark hole if annular
params.shiftReg = 2;                     
params.CorMaskReg = params.ScoreMaskReg;

% sources
params.numSources = 1;
params.sources(1).mult = 1;
params.sources(1).x = 0;
params.sources(1).y = 0;

% evaluation params
params.eval.lambda0 = 635e-9;
params.eval.lambdaList = [635]*1e-9;
params.eval.broadbandProp = true;

% illumination settings
params.illumination.use = true;
params.illumination.startElemID = 1;
params.illumination.endElemID = 7;
params.illumination.downsample = true;
params.illumination.Nillum = 2048;
params.illumination.downsampleFactor = params.illumination.Nillum/params.N;
params.illumination.saveOrigIllum = false;
params.illumination.downsampleMethod = 'FTdownsample'; % choices are 'FTdownsample' and 'linear'
params.illumination.pupilSurf = 'opticalElements\luvoirApiaacmc\pupil-surfMapFinal.fits'; 
params.illumination.nuTekSag1 = 'opticalElements\luvoirApiaacmc\m1SFE-n2048.fits';
params.illumination.nuTekSag2 = 'opticalElements\luvoirApiaacmc\m2SFE-n2048.fits';
params.illumination.auxOptics = 'opticalElements\luvoirApiaacmc\zeros_n2048.fits';


% correction params
params.useRelin = 1;                    % 0 - no relinearization, 1 - use relinearization
params.relinThresh = 0.1;
params.relinFlag = 0;
params.relinIterList = [];              % relinearization history tracker
params.lambdaCor = [635]*1e-9;
params.numLambdaCor = length(params.lambdaCor);
params.NiterCor = 12;
params.mu = 8e-6;


%% initialize system
system.params = params; clear params;
system.optics = initialize_optics(system.params);
system.sources = initialize_sources(system.params);
system.illumination = initialize_illumination_offaxis(system,0,0); % use same illumination as 2048x2048 (before downsampling)
[system.illuminationAb system.illuminationOptics] = initialize_illumination_nutek_v2(system,0,0); % use same illumination as 2048x2048 (before downsampling)
system.optics = precompute_mask(system.optics,system.params);
system.sci = initialize_sci(system.params.sci);
system.regions = initialize_regions(system.sci,system.params);

%% wavelength settings
lambda0 = system.params.eval.lambda0;

if system.params.eval.broadbandProp == true
    lambdaBroadband = system.params.eval.lambdaList;
else
    lambdaBroadband = lambda0;
end

%% default simulation options
defaultSimOptions.useab = 0;
defaultSimOptions.calibrationFlag = 0;
defaultSimOptions.verbose = 1;
defaultSimOptions.sourceIn = system.sources(1);

if system.params.illumination.use == true
    defaultSimOptions.sourceType = 'illumination';
    defaultSimOptions.startElemID = system.params.illumination.endElemID + 1;
    defaultSimOptions.endElemID = system.params.Nelem;
else
    defaultSimOptions.sourceType = 'offaxis';
    defaultSimOptions.startElemID = 1;
    defaultSimOptions.endElemID = system.params.Nelem;
end


%% compute calibration PSF
disp(' ')
disp('PSF Calibration')
simOptions = defaultSimOptions;
simOptions.useab = 0;
simOptions.calibrationFlag = 1;
system.outputCalib = propagate_optics(system, lambda0, simOptions);

system.I00 = max(max(system.outputCalib.psfE.*conj(system.outputCalib.psfE)));

system.illuminationOnAx = system.illumination;
system.illumination = system.illuminationAb;

disp(' ')
disp('PSF Calibration with PR Abb')
simOptions = defaultSimOptions;
simOptions.calibrationFlag = 1;
simOptions.useab = 1;
system.outputCalibAbb = propagate_optics(system, lambda0, simOptions);
SRcalibAbb = max(max(system.outputCalibAbb.psf)) / system.I00;

system.illumination = system.illuminationOnAx;

disp(' ')
disp('On-axis PSF')
simOptions = defaultSimOptions;
simOptions.calibrationFlag = 0;
simOptions.useab = 0;
system.output = propagate_optics(system, lambda0, simOptions);

figure(); imagesc(system.sci.xlD, system.sci.ylD, log10(system.outputCalib.psfE.*conj(system.outputCalib.psfE)./system.I00)); axis image;
set(gcf,'color','white')
title('Normalization LUVOIR PSF', 'FontSize', 16)
xlabel('Sky Angular Separation, $\lambda_0 / D$', 'Interpreter', 'latex', 'FontSize', 16)
ylabel('Sky Angular Separation, $\lambda_0 / D$', 'Interpreter', 'latex', 'FontSize', 16)
set(gcf,'color', 'white')
colorbar

figure(); imagesc(system.sci.xlD, system.sci.ylD, log10(system.output.psfE.*conj(system.output.psfE)./system.I00)); axis image;
set(gcf,'color','white')
title('LUVOIR PSF', 'FontSize', 16)
xlabel('Sky Angular Separation, $\lambda_0 / D$', 'Interpreter', 'latex', 'FontSize', 16)
ylabel('Sky Angular Separation, $\lambda_0 / D$', 'Interpreter', 'latex', 'FontSize', 16)
set(gcf,'color', 'white')
colorbar

figure(); imagesc(system.sci.xlD, system.sci.ylD, log10(system.output.psfE.*conj(system.output.psfE)./system.I00)); axis image;
set(gcf,'color','white')
title('LUVOIR PSF', 'FontSize', 16)
xlabel('Sky Angular Separation, $\lambda_0 / D$', 'Interpreter', 'latex', 'FontSize', 16)
ylabel('Sky Angular Separation, $\lambda_0 / D$', 'Interpreter', 'latex', 'FontSize', 16)
set(gcf,'color', 'white')
colorbar

simOptions = defaultSimOptions;
[resultsMono] = simResult(system, simOptions, lambda0, system.I00, 0)

figure(); imagesc(system.sci.xlD, system.sci.ylD, log10(resultsMono.Ibr)); axis image; caxis([-10 -3]); colorbar; title('Normalized Intensity PSF')
set(gcf,'color','white')
title('LUVOIR PSF - Mono', 'FontSize', 16)
xlabel('Sky Angular Separation, $\lambda_0 / D$', 'Interpreter', 'latex', 'FontSize', 16)
ylabel('Sky Angular Separation, $\lambda_0 / D$', 'Interpreter', 'latex', 'FontSize', 16)
set(gcf,'color', 'white')
colorbar
hold on;





profile viewer