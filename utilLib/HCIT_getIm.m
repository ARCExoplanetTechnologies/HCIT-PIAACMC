function [varout] = HCIT_getIm(sourceImFilename,destinationImFilename,pauseTime)
    
    if nargin < 3
        pauseTime = 5;
    end

    try
        copyfile(sourceImFilename,destinationImFilename);
        gunzip(destinationImFilename);
        varout = 'Success';
    catch
        pause(pauseTime)
        varout = HCIT_getIm(sourceImFilename,destinationImFilename);
        varout = 'Failure';
    end
   
end

