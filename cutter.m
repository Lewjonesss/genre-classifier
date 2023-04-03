function cut = cutter(inputdir,start,duration)

tracks = audioDatastore(inputdir, 'IncludeSubfolders',true, ...
    'LabelSource','foldernames');

numTracks = numel(tracks.Files); 
splitpath = split(inputdir, '/');
pathnofinal = string(splitpath(1));

if size(splitpath) > 2
    for i=1:size(splitpath)-1
        pathnofinal = strcat(pathnofinal, '/', string(splitpath(i)));
    end
end

if not(isfolder(strcat(pathnofinal, '/cut_songs')))
    mkdir(strcat(pathnofinal, '/cut_songs'))
end


for it=1:numTracks
    newsplit = split(tracks.Files(it), '\');
    song = split(newsplit(end),'.');
    songname = '';

    for k=1:size(song)-1
        songname = strcat(songname, string(song(k)));
    end

    outputdir = strcat(pathnofinal, '/cut_songs/', string(tracks.Labels(it)));
    
    if not(isfolder(outputdir))
        mkdir(outputdir)
    end
    filename = strcat(outputdir, '/', songname, '_cut.wav');
    
    if not(isfile(filename))
        [y,Fs] = audioread(string(tracks.Files(it)));
    
        if length(y) < duration*Fs
            error('Audio clip is too short')
        elseif length(y) > (start+duration)*Fs
            samples = [start*Fs, (start+duration)*Fs];
        else        
            samples = [1, duration*Fs];
        end

        [y1,Fs] = audioread(string(tracks.Files(it)),samples);
        audiowrite(filename,y1,Fs);
    end

end

cut=tracks;
end