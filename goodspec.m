function image = goodspec(dir)

tracks = audioDatastore(dir, 'IncludeSubfolders',true, 'LabelSource', 'foldernames');

numTracks = numel(tracks.Files);

splitpath = split(dir, '/');
pathnofinal = string(splitpath(1));

if size(splitpath) > 2
    for i=1:size(splitpath)-1
        pathnofinal = strcat(pathnofinal, '/', string(splitpath(i)));
    end
end

if not(isfolder(strcat(pathnofinal, '/specs')))
    mkdir(strcat(pathnofinal, '/specs'))
end

for i=1:numTracks
    newsplit = split(tracks.Files(i), '\');
    song = split(newsplit(end),'.');
    songname = '';

    for k=1:size(song)-1
        songname = strcat(songname, string(song(k)));
    end
    
    [audio_signal,sampling_frequency] = audioread(string(tracks.Files(i)));
    audio_signal = mean(audio_signal,2);

    % Set the parameters for the Fourier analysis
    window_length = 2^nextpow2(0.04*sampling_frequency);
    window_function = hamming(window_length, 'periodic');
    step_length = window_length/2;

    % Compute the mel filterbank
    number_mels =128;
    mel_filterbank = zaf.melfilterbank(sampling_frequency,window_length,number_mels);

    % Compute the mel spectrogram using the filterbank
    mel_spectrogram = zaf.melspectrogram(audio_signal.^2,window_function,step_length,mel_filterbank);

    % Display the mel spectrogram in in dB, seconds, and Hz
    number_samples = length(audio_signal);
    xtick_step = 1;
    figure
    zaf.melspecshow(mel_spectrogram, number_samples, sampling_frequency, window_length, xtick_step)
    set(gca,'XTick',[], 'YTick', [])

    outputdir = strcat(pathnofinal, '/specs/', string(tracks.Labels(i)));
    
    if not(isfolder(outputdir))
        mkdir(outputdir)
    end
    
    filename = strcat(outputdir, '/', songname, '_spec.png');
    saveas(gcf, filename);
    close
end

image = outputdir;
end