% Yigang Peng, Arvind Ganesh, November 2009. 
% Questions? abalasu2@illinois.edu
%
% Copyright: Perception and Decision Laboratory, University of Illinois, Urbana-Champaign
%            Microsoft Research Asia, Beijing



% Un-encode an sRGB image into linear intensities.  uint8 to double.
function outputImage = gamma_decompress(inputImage, gammaType)

tempImage = double(inputImage)/255;

switch gammaType
    
    case 'srgb'

        a = .055;
        
        outputImage = (tempImage>.04045).* ((tempImage+a)./(1+a)).^2.4 + ~(tempImage>.04045) .* (tempImage./12.92);
    
    case 'ntsc'
        
        outputImage = tempImage.^2.2 ;
        
    case 'linear'
        
        outputImage = tempImage ;
        
    otherwise
        
        error('Gamma Type not recognized') ;
        
end
