%Folder with all scraped songs, start time and cut length as inputs
cutter('Data/test_songs',30,30);

%Generate spectrograms
goodspec('Data/cut_songs');

%Store Images and create training-validation split
imds = imageDatastore('Data/specs', ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames'); 
[imdsTrain,imdsValidation] = splitEachLabel(imds,0.9, 'randomized');

%Augment Images
imageAugmenter = imageDataAugmenter( ...
    'RandRotation',[-20,20], ...
    'RandXTranslation',[-3 3], ...
    'RandYTranslation',[-3 3]);

augimdsTrain = augmentedImageDatastore([128 128 3] ,imdsTrain);
augimdsValidation = augmentedImageDatastore([128 128 3] ,imdsValidation);

%Create CNN
lgraph = createModel(imdsTrain);

%Options for the CNN
miniBatchSize = 32;
valFrequency = floor(numel(augimdsTrain.Files)/miniBatchSize);
options = trainingOptions('sgdm', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',30, ...
    'InitialLearnRate',3e-4, ...
    'Shuffle','every-epoch', ...
    'ValidationData',augimdsValidation, ...
    'ValidationFrequency',valFrequency, ...
    'ValidationPatience', 5, ...
    'Verbose',false, ...
    'Plots','training-progress');

%Train CNN
net = trainNetwork(augimdsTrain,lgraph,options);

%Test CNN
[YPred,probs] = classify(net,augimdsValidation);
accuracy = mean(YPred == imdsValidation.Labels)

%View Validation for CNN
idx = randperm(numel(imdsValidation.Files),9);
figure
for i = 1:9
    subplot(3,3,i)
    I = readimage(imdsValidation,idx(i));
    imshow(I)
    label = YPred(idx(i));
    title(string(label) + ", " + num2str(100*max(probs(idx(i),:)),3) + "%" + 'actual:' + string(imdsValidation.Labels(idx(i))));
end

%Generate Confusion Matrix
confusionchart(imdsValidation.Labels,YPred) 
