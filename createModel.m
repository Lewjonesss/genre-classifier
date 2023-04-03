function model = createModel(imdsTrain)

model = layerGraph;

numLabels = numel(unique(imdsTrain.Labels));

input = imageInputLayer([128 128 3], 'Name', 'spectrogram');
reshape_layer = functionLayer(@(x) reshape(x, [size(x), 1]));

model = addLayers(model, [input reshape_layer]);

for i=1:5
    num_filters = 32 * (2^i);
    conv_layer = convolution2dLayer(3, num_filters, 'Padding', 'same', 'BiasLearnRateFactor', 0);
    batch_norm_layer = batchNormalizationLayer();
    relu_layer = reluLayer();
    max_pool_layer = maxPooling2dLayer(2, 'Stride', 2);

    layers = [conv_layer batch_norm_layer relu_layer max_pool_layer];
    model = addLayers(model, layers);
end

global_pool_layer = globalAveragePooling2dLayer();
dense_layer = fullyConnectedLayer(numLabels, 'Name', 'genre');
softmax =  softmaxLayer();
classification = classificationLayer('Classes', categories(imdsTrain.Labels));

layers = [global_pool_layer dense_layer softmax classification];

model = addLayers(model, layers);

model = connectLayers(model, 'layer', 'conv');
model = connectLayers(model, 'maxpool', 'conv_1');
model = connectLayers(model, 'maxpool_1', 'conv_2');
model = connectLayers(model, 'maxpool_2', 'conv_3');
model = connectLayers(model, 'maxpool_3', 'conv_4');
model = connectLayers(model, 'maxpool_4', 'gap');

end