
function aug_data = AugmentData(data, noise_cnt, noise_value , rot_cnt, scale_cnt, scale_factor)
    %angle_step_dg = 120;
    %noise_cnt = 2;
    %numTransformations = (360/angle_step_dg) - 1 + noise_cnt;
    %augmentedImages = cell(numTransformations + 1, numel(image_files));
    if(rot_cnt ~= 0)
        angle_step_dg = 360/(rot_cnt+1);
    else
        angle_step_dg = 360;
    end
    aug_data = data;
    
    for i = 1:size(aug_data,2)
    
        scale_idx = 2;
        noise_idx = 2;
        for noise_idx = 2:noise_cnt + 1
            noisyImage = imnoise(aug_data{1, i}, 'gaussian', 0, (noise_idx-1)*noise_value); 
            aug_data{noise_idx, i} = noisyImage;
        end
    
        angle = 0;

        next_idx = noise_idx;
        if(isempty(noise_idx ))
            next_idx = 2;
            noise_idx = 2;
        end
        for rot_idx = noise_idx + 1 :((noise_idx + 360/angle_step_dg))
            angle = angle + angle_step_dg;
            rotatedImage = imrotate(aug_data{1, i}, angle,'bilinear','crop' );
            aug_data{rot_idx-1, i} = rotatedImage;
        end

        scale_idx = next_idx;
        if(isempty(scale_idx ))
            scale_idx = 2;
        end
        for scale_idx = next_idx + 1 : (next_idx + scale_cnt)
            scaledImage = imresize(aug_data{1, i}, (1 + scale_factor*(scale_idx-next_idx)));
            aug_data{scale_idx-1, i} = scaledImage;
        end
    end

end