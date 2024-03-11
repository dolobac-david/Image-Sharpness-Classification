clear all
close all

folderPath = 'Dataset/';
imageFiles = dir(fullfile(folderPath, '*.png')); % Modify the file extension if your images have a different format


for i = 1:numel(imageFiles)
    filePath = fullfile(folderPath, imageFiles(i).name);
    originalImage = imread(filePath);
    allImages{1, i} = originalImage;
end

augmentedImages = AugmentData(allImages, 5, 0);

%% 

for i = 2:4
    figure;
    imshow(augmentedImages{i, 1});
end










function aug_data = AugmentData(data, noise_cnt, rot_cnt)
    %angle_step_dg = 120;
    %noise_cnt = 2;
    %numTransformations = (360/angle_step_dg) - 1 + noise_cnt;
    %augmentedImages = cell(numTransformations + 1, numel(imageFiles));
    if(rot_cnt ~= 0)
        angle_step_dg = 360/rot_cnt;
    else
        angle_step_dg = 360;
    end
    aug_data = data;
    
    for i = 1:size(aug_data,2)
    
        for noise_idx = 2:noise_cnt + 1
            noisyImage = imnoise(aug_data{1, i}, 'gaussian', 0, noise_idx*0.001); 
            aug_data{noise_idx, i} = noisyImage;
        end
    
        angle = 0;
        for rot_idx = noise_idx + 1 :((noise_idx + 360/angle_step_dg) - 1)
            angle = angle + angle_step_dg;
            rotatedImage = imrotate(aug_data{1, i}, angle);
            aug_data{rot_idx, i} = rotatedImage;
        end
    end

end