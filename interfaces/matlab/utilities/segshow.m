function segshow(inDir, outDir)
%SEGSHOW(inDir, outDir) Preview best segmentation augmented on the
%   corresponding frames.
%   Use arrows to navigate and enter, escape or space to exit.
%   If output directory is provided than use 's' key to save.
%
%   Input:
%       inDir - motionseg output directory with verbose >= 1
%       outDir - Optional output directory for saving segmentations

%% Read summary
summaryPath = fullfile(inDir, 'summary.csv');
if(~exist(summaryPath, 'file'))
    error('Could not find summary file!')
end
S = csvread(summaryPath, 1, 0);
ids = S(:,1);
scores = S(:,2);

%% Find best segmentations
[scores seg_ids] = findpeaks(scores,ids,'MinPeakDistance',10,...
    'MinPeakHeight',0.85,'SortStr','descend');

%% Initialize preview
h_fig = figure;
set(h_fig,'KeyPressFcn',@key_pressed_fcn);
i = 1;
running = true;

%% Preview loop
while(running)
    seg_id = seg_ids(i);
    score = scores(i);
    segDebugFileName = fullfile(inDir,...
        ['seg_debug_' num2str(seg_id, '%04d') '.jpg']);
    I = imread(segDebugFileName);
    imshow(I);
    title(['ID = ' num2str(seg_id) '  Score = ' num2str(score)...
        '   [' num2str(i) ' / ' num2str(length(seg_ids)) ']']);
    waitforbuttonpress
end
close(h_fig);

    %% Process key presses
    function key_pressed_fcn(fig_obj,evt)
        %disp(evt.Key)
        switch evt.Key
            case 'leftarrow'
                i = max(1, i-1);
            case 'rightarrow'
                i = min(i+1, length(seg_ids));
            case 'escape'
                running = false;
            case 'return'
                running = false;
            case 'space'
                running = false;
            case 's'
                if(exist('outDir', 'var'))
                    [inDirPath inDirName] = fileparts(inDir);
                    fileName = fullfile(outDir,...
                        [inDirName '_seg_debug_' num2str(seg_id, '%04d') '.jpg']);
                    disp(['Writing ' fileName]);
                    imwrite(I, fileName);
                end
                    
        end
    end
end

