function [DM1sineShape] = make_DM_sineShape(optics, DMelemID, kx1, ky1, delta_p, psi_p)

    DM1sineShape.sag = delta_p*sin(2*kx1*pi/(optics.elem(DMelemID).D)*optics.elem(DMelemID).xx+2*ky1*pi/optics.elem(DMelemID).D*optics.elem(DMelemID).yy+psi_p);    % DM flat shape

end
