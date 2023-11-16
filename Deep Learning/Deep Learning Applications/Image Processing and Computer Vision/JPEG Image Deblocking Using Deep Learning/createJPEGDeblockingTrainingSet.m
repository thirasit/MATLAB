function [compressedDirName,residualDirName] = createJPEGDeblockingTrainingSet(imds,qualityFactors)

[~,info] = read(imds);
filePath = fileparts(info.Filename);
reset(imds);
    
if ~isfolder([filePath filesep 'compressedImages'])
    mkdir([filePath filesep 'compressedImages']);
end
  
if ~isfolder([filePath filesep 'residualImages'])
    mkdir([filePath filesep 'residualImages']);
end
extn = '.mat'; 

compressedDirName = [filePath filesep 'compressedImages'];
residualDirName = [filePath filesep 'residualImages'];

while hasdata(imds)

    [Ipristine,info] = read(imds);
    [~,fileName,~] = fileparts(info.Filename);

    residualFilePrefix = [residualDirName filesep fileName 'q'];
    compressedFilePrefix = [compressedDirName filesep fileName 'q'];
    
    imwrite(Ipristine,[compressedFilePrefix '100.jpg'],'JPEG','Quality',100);
    Iq100 = imread([compressedFilePrefix '100.jpg']);
    
    % Use only the luminance component for training
    YCbCr = rgb2ycbcr(Iq100);
    Y = YCbCr(:,:,1);
    
    %Iq100 is the pristine reference image
    Iq100 = im2double(Y);
    
    for q = qualityFactors
        imwrite(Ipristine,[compressedFilePrefix num2str(q) '.jpg'],'JPEG','Quality',q)
        Iq = imread([compressedFilePrefix num2str(q) '.jpg']);
        
        %Iq is the compressed image and the network input
        YCbCr = rgb2ycbcr(Iq);
        Y = YCbCr(:,:,1);
        Iq = im2double(Y);
        
        %Iresidual is the desired network response
        Iresidual = Iq - Iq100;
        
        save([compressedFilePrefix num2str(q) extn],'Iq');
        save([residualFilePrefix num2str(q) extn],'Iresidual');

    end
        
end

end