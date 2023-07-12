clear
close all
clc

%% Image selection

% the name and the path of the file are stored
[name,path] = uigetfile('*.png;*.jpg', 'Select an image');
if isequal(name,0) || isequal(path,0)
    disp('User pressed cancel')
else
    % the original image is read
    I = imread([path name]);
    [pathstr, name_s, ext]=fileparts(fullfile(path, name));
    disp(['Input file : ', fullfile(path, name)])
    
    %% ROI selection
    
    % the ROI is selected and the cropped image along with the ROI are
    % stored
    [~, ~, img, rect] = imcrop(I);
    
    % the ROI is saved in the same directory of the original file
    nameRoi=[name_s '_roi.png'];
    imwrite(img,[path nameRoi]);
    
    %% Speckle removal
    
    % input parameters for speckle removal
    M = input("Select search area size (2*M + 1)^2 (default 7): ");
    if isempty(M)
        M = 7;
    end
    alpha = input("Select patch size (2*alpha + 1)^2 (default 3): ");
    if isempty(alpha)
        alpha = 3;
    end
    h = input("Select smoothing parameter [0-infinite] (default 0.7): ");
    if isempty(h)
        h = 0.7;
    end
    
    % the denoised image and the normalized image are stored
    [imgf, img] = speckleRemoval(img, M, alpha, h);
    
    % the denoised image is saved in the same directory of the original file
    nameout=[name_s '_norm_denoised.png'];
    imwrite(imgf,[path nameout]);
    
    % the normalized image is saved in the same directory of the original file
    nameinnorm=[name_s '_norm.png'];
    imwrite(img,[path nameinnorm]);
    
    % the residual image is saved in the same directory of the original file
    %namespeckle=[nout_s '_speckle.png'];
    %imwrite(speckle,[path namespeckle]);
    
    %% Contrast stretching
    
    % the parameters used for the contrast enhancement are computed
    [r1, s1, r2, s2] = computePoints(imgf);
    
    % the enhanced image, the V level and the contrast plot and stored and
    % saved
    [imgc, V_tot, contrastPlot] = contrastStretching(imgf, r1, s1, r2, s2);
    
    nameout=[name_s '_contrast_enhancement.png'];
    nameVlevel=[name_s '_V_level.png'];
    namePlot = [name_s '_contrast_plot.png'];
    
    imwrite(imgc,[path nameout]);
    imwrite(V_tot,[path nameVlevel]);
    saveas(contrastPlot, [path namePlot]);
    
    %% Segmentation algorithm selection
    
    disp("1. Region Growing")
    disp("2. K-means")
    disp("3. Mean Shift")
    disp("4. Watershed")
    n = input('Select segmentation algorithm: ');
    
    switch n
        case 1
            % threshold of the region growing algorithm
            thresVal = input("Select threshold value (default 5%): ");
            if isempty(thresVal)
                thresVal = 0.05;
            end
            thresVal = thresVal / 100;
            thresVal = double((max(imgc(:)) - min(imgc(:)))) * thresVal;
            
            figure
            himage = imshow(imgc, []);
            title("Select seed");
            
            % graphical user input for the initial position
            p = ginput(1);
            
            % get the pixel position concerning to the current axes coordinates
            initPos(1) = round(axes2pix(size(imgc, 2), get(himage, 'XData'), p(2)));
            initPos(2) = round(axes2pix(size(imgc, 1), get(himage, 'YData'), p(1)));
            
            [P, J] = regionGrowing(imgc, initPos, thresVal, Inf, false, true, true);
        case 2
            % clusters for the k-means algorithm
            K = input("Select the number of clusters (default 8): ");
            if isempty(K)
                K = 8;
            end
            
            % k-means using only color or color and spatial features
            Ikm = Km(imgc,K); % Kmeans (color)
            figure
            imshow(Ikm);  title(['Kmeans',' : ',num2str(K)]);
            
            nameIkm = [name_s '_kmeans.png'];
            imwrite(Ikm,[path nameIkm]);
            
            %Ikm2 = Km2(imgc,K); % Kmeans (color + spatial)
            %figure
            %imshow(Ikm2); title(['Kmeans+Spatial',' : ',num2str(K)]);
            
            %nameIkm2 = [name_s '_kmeansspatial.png'];
            %imwrite(Ikm2,[path nameIkm]);
            
            figure
            himage = imshow(Ikm, []);
            title("Select region to get the mask");
            
            % the region growing is only used to select the mask
            p = ginput(1);
            initPos(1) = round(axes2pix(size(Ikm, 2), get(himage, 'XData'), p(2)));
            initPos(2) = round(axes2pix(size(Ikm, 1), get(himage, 'YData'), p(1)));
            
            [P, J] = regionGrowing(Ikm, initPos, 0.05, Inf, false, true, true);
            %[P2, J2] = regionGrowing(Ikm2, initPos, 0.05, Inf, false, true, true);
        case 3
            % bandwidth selection
            bw = input("Mean Shift bandwidth (default 0.2): ");
            if isempty(bw)
                bw = 0.2;
            end
            [Ims, Nms] = Ms(imgc,bw); % Mean Shift (color)
            figure
            imshow(Ims);  title(['MeanShift',' : ',num2str(Nms)]);
            
            nameIms = [name_s '_meanshift.png'];
            imwrite(Ims,[path nameIms]);
            
            %[Ims2, Nms2] = Ms2(imgc,bw); % Mean Shift (color + spatial)
            %figure
            %imshow(Ims2); title(['MeanShift+Spatial',' : ',num2str(Nms2)]);
            
            %nameIms2 = [name_s '_meanshiftspatial.png'];
            %imwrite(Ims2,[path nameIms2]);
            
            figure
            himage = imshow(Ims, []);
            title("Select region to get the mask");

            p = ginput(1);
            initPos(1) = round(axes2pix(size(Ims, 2), get(himage, 'XData'), p(2)));
            initPos(2) = round(axes2pix(size(Ims, 1), get(himage, 'YData'), p(1)));
            
            [P, J] = regionGrowing(Ims, initPos, 0.05, Inf, false, true, true);
            %[P2, J2] = regionGrowing(Ims2, initPos, 0.05, Inf, false, true, true);
        case 4
            % disk dimension for the opening-closing by reconstruction
            disk = input("Select disk dimension (default 5): ");
            if isempty(disk)
                disk = 8;
            end
            imgc = V_tot;
            
            % the label matrix, the result of opening-closing by
            % reconstruction and the image containing the markers and the
            % ridge lines are stored and saved
            [Iw, Ocr, Mar] = markerControlledWatershed(imgc, disk);
            
            nameIw = [name_s '_labelmatrix.png'];
            nameOcr = [name_s '_opening_closing_rec.png'];
            nameMar = [name_s '_markers.png'];
            imwrite(Iw,[path nameIw]);
            imwrite(Ocr,[path nameOcr]);
            imwrite(Mar,[path nameMar]);
            
            figure
            himage = imshow(Iw, []);
            title("Select region to get the mask");
            
            p = ginput(1);
            initPos(1) = round(axes2pix(size(Iw, 2), get(himage, 'XData'), p(2)));
            initPos(2) = round(axes2pix(size(Iw, 1), get(himage, 'YData'), p(1)));
            
            [P, J] = regionGrowing(Iw, initPos, 0.05, Inf, false, true, true);
        otherwise
            disp('Wrong value')
    end
    
    % the mask obtained is stored
    figure
    imshow(J);
    title("Mask");
    nameMask = [name_s '_mask.png'];
    imwrite(J,[path nameMask]);
    
    %% Segmentation metrics
    
    [name,pathGt] = uigetfile('*.png;*.jpg', 'Select ground truth mask');
    if isequal(name,0) || isequal(path,0)
        disp('User pressed cancel')
    else
        % the ground truth mask is selected and cropped using the
        % previously stored ROI
        gt = imread([pathGt name]);
        [pathstr, name_s, ext]=fileparts(fullfile(pathGt, name));
        disp(['Input file : ', fullfile(pathGt, name)])
        
        gtRoi = imcrop(gt, rect);
        figure
        imshow(gtRoi);
        title("Ground truth");
        
        nameGtRoi = [name_s '_gtroi.png'];
        imwrite(gtRoi,[path nameGtRoi]);
        
        % intersection-over-union value
        iou = (intersectionOverUnion(J, gtRoi))*100;
        disp("Intersection-over-union value: " + iou + "%");
        
        % dice value
        diceVal = (dice(J, gtRoi))*100;
        disp("Dice value: " + diceVal + "%");
    end
    
end