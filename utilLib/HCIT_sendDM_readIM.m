function [imOut, iter] = HCIT_sendDM_readIM(dmActs, iter, labelLength, runLabel, im_wfcDir, dm_wfcDir, fitsheaderInfo)
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
    
    figure(2);
    imagesc(abs(dmActs)); axis image;
    
    dmLen = length(dmActs);
    
    fptr = fits.createFile(dmFilename);
    fits.createImg(fptr,'double',[dmLen dmLen 1]);
    fits.writeImg(fptr, dmActs);
    
    if fitsheaderInfo.useHeader == true
        for iHeader = 1:fitsheaderInfo.fitsheaderNum
            fits.writeKey(fptr,fitsheaderInfo.fitsheader{iHeader},fitsheaderInfo.fitsheaderVals(iHeader));
        end
    end
    
    fits.closeFile(fptr);    
    
    pause(1)
    
    fid = fopen(dmlog_Filename,'wt');
    fprintf(fid,[dmBasename]);
    fprintf(fid, '\n');
    fclose(fid);
    
    imBasename = ['run' runLabel 'it' iterLabel '.fits'];
    imFilename = [im_wfcDir 'run' runLabel 'it' iterLabel '.fits']
    
    readLog = '';
    
    while not(strcmp(readLog,imBasename))
        pause(0.5)
        fid_im = fopen(imlog_Filename,'r');
        readLog = fscanf(fid_im, '%s')
        fclose(fid_im)
        
        if length(readLog) > 0
            if strcmp(readLog(1:8),'starting')
                readLog = readLog(9:30);
                
                checkThis = [];
                while not(strcmp(checkThis,'done'))
                    pause(0.1)
                    fid_im = fopen(imlog_Filename,'r');
                    checkThis = fscanf(fid_im, '%s')
                    fclose(fid_im)
                    
                    if length(checkThis) > 0
                        checkThis = checkThis(end-3:end);
                    end
                end
            end
        end
    end
    
    pause(2)
    %imOut = flipud(fitsread(imFilename));
    imOut = fitsread(imFilename);
    
    figure(1);
    imagesc(imOut); axis image;
    
    iter = iter + 1;
end

