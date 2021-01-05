function [iter,thisFilename] = HCIT_sendDM(dmActs, iter, labelLength, runLabel, im_wfcDir, dm_wfcDir, fitsheaderInfo)
    import matlab.io.*
    
    %dmActs = -fliplr(flipud(2*flipud(dmActs)));
    dmActs = dmActs;
    
    if nargin < 7
        fitsheaderInfo.useHeader = false;
    end
    
    

    imlog_Filename = [im_wfcDir 'log.txt'];
    dmlog_Filename = [dm_wfcDir 'log.txt'];
    
    % create labels
    iterLabel = create_numericalLabel(iter,labelLength);
    dmBasename = ['run' runLabel 'it' iterLabel 'dm.fits'];
    dmFilename = [dm_wfcDir dmBasename];
    
    %figure(2);
    %imagesc(abs(dmActs)); axis image;
    
    dmLen = length(dmActs);
    dmCubeLen = size(dmActs,3);
    
    fptr = fits.createFile(dmFilename);
    fits.createImg(fptr,'double',[dmLen dmLen dmCubeLen]);
    fits.writeImg(fptr, dmActs);
    
    if fitsheaderInfo.useHeader == true
        for iHeader = 1:fitsheaderInfo.fitsheaderNum
            fits.writeKey(fptr,fitsheaderInfo.fitsheader{iHeader},fitsheaderInfo.fitsheaderVal{iHeader});
        end
    end
    
    fits.closeFile(fptr);    
       
    pause(1)
    
    [attribStatus,attribValues] = fileattrib(dmFilename);
    fileattrib(dmFilename, '+w','o a')
    
    fid = fopen(dmlog_Filename,'wt');
    fprintf(fid,[dmBasename]);
    fprintf(fid, '\n');
    fclose(fid);
    
   
end

