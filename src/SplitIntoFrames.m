videoName = 'NSExpansion';
vidFolder = './Neurogenesis';

%Filepath of video
videoFullFile = fullfile(vidFolder,strcat(videoName,'.mpg'));
videoObject = VideoReader(videoFullFile);

numberOfFrames = videoObject.NumberOfFrames;

%Go through each frame and write it to directory
for frame = 1:numberOfFrames
    thisFrame = read(videoObject,frame);
    
    %Naming of Frame
    folder = fullfile(vidFolder,videoName);
    outputBaseFileName = sprintf('Frame_%4.4d.png', frame);
	outputFullFileName = fullfile(folder, outputBaseFileName);
  
    %Write frame
    imwrite(thisFrame, outputFullFileName, 'png');
    
    finishedMessage = sprintf('Finished Frame_%4.4d',frame);
    disp(finishedMessage)
    
    
end