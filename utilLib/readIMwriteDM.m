function [imOut, iter] = writeDMreadIM(dmActs, iter, labelLength, runlabel, im_wfcDir, dm_wfcDir)
    iterLabel = create_numericalLabel(iter,labelLength);
   
    % read current iteration of dm file
	iterLabel = create_numericalLabel(iter+1,labelLength);

    dmBasename = ['run' runLabel 'it' iterLabel 'dm.fits'];
    dmFilename = [dm_wfcDir dmBasename];
    
    figure(2);
    imagesc(dmActs); axis image;
     
    fptr = fits.createFile(dmFilename);
    fits.createImg(fptr,'double',[dmLen dmLen 1]);
    fits.writeImg(fptr, dmActs);
    fits.closeFile(fptr);    
    
    pause(1)
    
    fid = fopen(dmlog_Filename,'wt');
    fprintf(fid,[dmBasename]);
    fprintf(fid, '\n')
    fclose(fid);
    
    % read next image
	iter = iter + 1;

    imBasename = ['run' runLabel 'it' iterLabel '.fits'];
    imFilename = [im_wfcDir 'run' runLabel 'it' iterLabel '.fits']
    
    readLog = ''
    
    while not(strcmp(readLog,imBasename))
        pause(0.1)
        fid_im = fopen(imlog_Filename,'r');
        readLog = fscanf(fid_im, '%s')
        fclose(fid_im)
        
        if length(readLog) > 0
            if strcmp(readLog(1:8),'starting')
                readLog = readLog(9:30);
            end
        end
    end
    
    figure(1);
    imagesc(thisIm); axis image;
end

