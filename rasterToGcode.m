%%  Converts raster image to gcode file.
%   Each colour of image is separeted into its own layer and plotted separately


clear all, clc
maxX = 35; %X axis limit
maxY = 35; %Y axis limit

stepsPmmX = 6.667; %step per mm for X stepper
stepsPmmY = 6.75; %step per mm for Y stepper

plotX = 35; %required image size X
plotY = 35; %required image size Y

penSize = 0.1; %thickness of used pen

imageName = '';
gCodeName = 'oblouk.gcode';

gCode = fopen(gCodeName, 'a+');

img = imread(imageName);
[imgY,imgX,h] = size(img);

if imgX > stepsPmmX * maxX || imgY > stepsPmmY * maxY
    fprintf('Image resolution too high.');
    return
end

if penSize > plotY/imgY
    fprintf('Pen thickness too large for required resolution.');
    return
end

scaleX = plotX/imgX;
scaleY = plotY/imgY;

if h > 1
    colors = zeros(1,3)+255;
    nn = 0;
    for i = 1:imgY
        for j = 1:imgX
            for k = 1:size(colors,1)
                if (img(i,j,1) == colors(k,1)) && (img(i,j,2) == colors(k,2)) && (img(i,j,3) == colors(k,3))
                    nn = 1;
                end
            end
            if nn ~= 1
                colors(end+1,1) = img(i,j,1);
                colors(end,2) = img(i,j,2);
                colors(end,3) = img(i,j,3);
            end
            nn = 0;
        end
    end
    
    layers = ones(imgY,imgX,size(colors,1));
    for i = 1:imgY
        for j = 1:imgX
            for k = 1:size(colors,1)
                if img(i,j,1) == colors(k,1) && img(i,j,2) == colors(k,2) && img(i,j,3) == colors(k,3)
                    layers(i,j,k) = 0;
                end
            end
        end
    end
    
    layers(:,:,1) = [];
    colors(1,:) = [];
else
    layers = im2bw(img);
    colors = [0 0 0];
end
nol = size(layers,3);

for k = 1 : nol;
    subplot(2,nol,k);
    imshow(layers(:,:,k));
end
subplot(2,nol,nol+1);
imshow(img);

fprintf('Colors %d %d %d\n',colors');

fprintf(gCode, 'G21\nG90\nG92 X0.00 Y0.00 Z0.00\n');
penDown = 0;

penPos = zeros(2,2);

layers = flip(layers,2);        %flip if you plotter mirrored images


lflip = 0;

for l = 1:nol                               %cycle through layers of colors
    fprintf(gCode, 'M001\n');
    fprintf(gCode, 'M300 S50\n');
    for i = 1:imgY                          %cycle through rows
        for k = 1:floor((scaleY)/penSize) %cycle through subrows
            for j = 1:imgX                      %cycle through columns
                if layers(i,j,l) == 0
                    if penDown == 0
                        penPos(1,1) = abs((imgX*lflip - (j-1))) * scaleX;
                        penPos(1,2) = ((i-1) + ((k-1)/floor((plotY/imgY)/penSize))) * scaleY;
                        fprintf(gCode, 'G01 X%.2f Y%.2f\n',penPos(1,:));
                        fprintf(gCode,'M300 S30\nG4 P150\n');
                        penDown = 1;
                    end
                    if j < imgX
                        if layers(i,j+1,l) == 1
                            penPos(2,1) = abs((imgX*lflip - j )) * scaleX;
                            penPos(2,2) = ((i-1) + ((k-1)/floor((plotY/imgY)/penSize))) * scaleY;
                            fprintf(gCode, 'G01 X%.2f Y%.2f\n',penPos(2,:));
                            fprintf(gCode,'M300 S50\nG4 P150\n');
                            penDown = 0;
                        end
                    else
                        penPos(2,1) = abs((imgX*lflip - j)) * scaleX;
                        penPos(2,2) = ((i-1) + ((k-1)/floor((plotY/imgY)/penSize))) * scaleY;
                        fprintf(gCode, 'G01 X%.2f Y%.2f\n',penPos(2,:));
                        fprintf(gCode,'M300 S50\nG4 P150\n');
                        penDown = 0;
                    end
                end
            end
            layers = flip(layers,2);
            lflip = ~lflip;
        end
    end
    fprintf(gCode,'G01 X0.00 Y0.00 Z0.00\n');
    fprintf(gCode,'M300 S30\nG4 P150\n');
end

fprintf(gCode,'G01 X0.00 Y0.00 Z0.00\n');
fprintf(gCode,'M300 S50\nG4 P150\n');

fclose(gCode);
