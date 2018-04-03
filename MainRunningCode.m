clc
close all
clear all
f = filesep;
addpath(genpath(['altmany-export_fig-83ee7fd',f]))
addpath(genpath(['denoisers',f]))
%% Input parameters 
r                = im2double(rgb2gray(imread('saturn.png')));
r                = imresize(r,[256 256]);
objectSizePixels = [256 256];
sigma_w          = 1e-3;
measurementType  = 'Linear';
forwardModelType = 'Identity';
noiseType        = 'Gaussian';
seedNum          = 100;
figure, imshow(abs(r),[]), colorbar
title('Object-Reflectance')
set(gcf, 'Position', get(0, 'Screensize'));
export_fig(['Figures',filesep,'OpticalReflectance.png']);
%% Generate w,g, and y form input-parameters
F        = ForwardModelGenerator(objectSizePixels,measurementType,forwardModelType,seedNum,noiseType,sigma_w);
res      = F*r;
y        = res(1:prod(objectSizePixels));
g        = res(prod(objectSizePixels)+1:end);
y        = reshape(y,objectSizePixels);
g        = reshape(g,objectSizePixels);
figure, imshow(abs(y),[]), colorbar
title('Noisy-Measurement |y|')
set(gcf, 'Position', get(0, 'Screensize'));
export_fig(['Figures',filesep,'NoisyMeasurementAmplitudeNoiseSigma1e',num2str(log10(sigma_w)),'.png']);
figure, imshow(angle(y),[]), colorbar
title('Noisy-Measurement $\angle(y)$')
set(gcf, 'Position', get(0, 'Screensize'));
export_fig(['Figures',filesep,'NoisyMeasurementPhaseNoiseSigma1e',num2str(log10(sigma_w)),'.png']);
figure, imshow(abs(g),[]), colorbar
title('Complex-optical field (Amplitude)')
set(gcf, 'Position', get(0, 'Screensize'));
export_fig(['Figures',filesep,'ComplexOpticalFieldAmplitude.png']);
figure, imshow(angle(g),[]), colorbar
title('Complex-optical field (Phase)')
set(gcf, 'Position', get(0, 'Screensize'));
export_fig(['Figures',filesep,'ComplexOpticalFieldPhase.png']);
%% ML-reconstruction
inversionModelType = 'ML';
maxIters     = 25;
sigmaLambda  = 0.5*sqrt(var(y(:))); 
sigman       = 0.75;
denoiserType = 'TV';
realOnly     = true;
I            = InverseModelRetriever(objectSizePixels,inversionModelType,noiseType,sigma_w,maxIters,sigmaLambda,sigman,denoiserType,r,realOnly);
rML          = I*y;
rML          = reshape(rML,objectSizePixels);
figure, imshow(rML,[]), colorbar
title('ML Reconstruction')
set(gcf, 'Position', get(0, 'Screensize'));
export_fig(['Figures',filesep,'MLReconstructionNoiseSigma1e',num2str(log10(sigma_w)),'.png']);
%% Plug and play ADMM algorithm (TV)      
inversionModelType = 'PnP';
maxIters     = 15;
sigmaLambda  = 0.01; 
sigman       = 0.02;
denoiserType = 'TV';
realOnly     = true;
I            = InverseModelRetriever(objectSizePixels,inversionModelType,noiseType,sigma_w,maxIters,sigmaLambda,sigman,denoiserType,r,realOnly);
rPnP         = I*y;
rPnP         = reshape(rPnP,objectSizePixels);
figure, imshow(rPnP,[]), colorbar
title(['EM-P&P ',denoiserType])
set(gcf, 'Position', get(0, 'Screensize'));
export_fig(['Figures',filesep,'PnPReconstructionNoiseSigma1e',num2str(log10(sigma_w)),'.png']);
%%