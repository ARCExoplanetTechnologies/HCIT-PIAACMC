function [probePhases] = estimation_pairWiseProbes_getPhases(Npairs,plotPairsFlag)
% Evenly sample the complex unit circle by alternating positive and
% negative probe
% input:
% - Npairs (scalar): number of pairs of estimation probes
% - plotPairsFlag: 1 for showing probe pairs on unit circle
% output:
% - probePhases (vector): set of probe phases with +ve probe followed
% by corresopnding -ve probe

if nargin < 2
    plotPairsFlag = 0; % default to not show plot
end

Nprobes = Npairs*2;

pairSpacing = 2*pi/Nprobes;
positivePhases = [0:pairSpacing:pairSpacing*(Npairs-1)];

probeNum = 1
probePhases = zeros(Nprobes,1);

for iProbePair = 1:Npairs
    probePhases(probeNum:probeNum+1) = [positivePhases(iProbePair); positivePhases(iProbePair)+pi];
    probeNum = probeNum + 2;
end

if plotPairsFlag == 1
    figure();
    plot(real(exp(1i*probePhases)),imag(exp(1i*probePhases)),'ko');
    hold on;
    axis image;
    title('Pairwise Probes on Unit Circle')
    set(gcf,'color','w')
end

end

