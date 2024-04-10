clear all
close all

folder_path = 'Dataset/';
image_files = dir(fullfile(folder_path, '*.png'));


for i = 1:numel(image_files)
    file_path = fullfile(folder_path, image_files(i).name);
    original_image = imread(file_path);
    all_images{1, i} = original_image;
end

augmentedImages = AugmentData(all_images, 1, 0.001 , 0, 1, 0.25);

%% 

for i = 2:4
    figure;
    imshow(augmentedImages{i, 1});
end










function aug_data = AugmentData(data, noise_cnt, noise_value , rot_cnt, scale_cnt, scale_factor)
    %angle_step_dg = 120;
    %noise_cnt = 2;
    %numTransformations = (360/angle_step_dg) - 1 + noise_cnt;
    %augmentedImages = cell(numTransformations + 1, numel(image_files));
    if(rot_cnt ~= 0)
        angle_step_dg = 360/rot_cnt;
    else
        angle_step_dg = 360;
    end
    aug_data = data;
    
    for i = 1:size(aug_data,2)
    
        noise_idx = 2;
        for noise_idx = 2:noise_cnt + 1
            noisyImage = imnoise(aug_data{1, i}, 'gaussian', 0, noise_idx*noise_value); 
            aug_data{noise_idx, i} = noisyImage;
        end
    
        angle = 0;
        next_idx = noise_idx;
        for rot_idx = noise_idx + 1 :((noise_idx + 360/angle_step_dg) - 1)
            angle = angle + angle_step_dg;
            rotatedImage = imrotate(aug_data{1, i}, angle);
            aug_data{rot_idx, i} = rotatedImage;
        end

        scale_idx = next_idx;
        for scale_idx = next_idx + 1 : (next_idx + scale_cnt)
            scaledImage = imresize(aug_data{1, i}, (1 + scale_factor*(scale_idx-next_idx)));
            aug_data{scale_idx, i} = scaledImage;
        end
    end

end