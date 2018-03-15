clc
close all
clear all
addpath(genpath('altmany-export_fig-83ee7fd'))
%% Input parameters 
r        = im2double(imread('cameraman.tif'));
sigma_w  = 0.1;
A        = 'fft';
seedNum  = 1;
figure, imshow(log10(abs(r)),[]), colorbar
title('Object-Reflectance')
set(gcf, 'Position', get(0, 'Screensize'));
export_fig(['Figures\OpticalReflectance.png']);
%% Generate w,g, and y form input-parameters
[M,N]    = size(r);                                                         % Size of the input-image 
g        = (sqrt(r)/2).*randn(M,N)+1j*(sqrt(r)/2).*randn(M,N);              % g ~ CN(0,D(r))
if(strcmp(A,'fft'))
    y = fftshift(fft2(g));
end
w        = (sqrt(sigma_w)/2)*randn([M,N])+1j*(sqrt(sigma_w)/2)*randn([M,N]);% w ~ CN(0,\sigma_w^2)   
y        = y+w;                                                             % noisy-measurements 
figure, imshow(log10(abs(y)),[]), colorbar
title('Noisy-Fourier domain')
set(gcf, 'Position', get(0, 'Screensize'));
export_fig(['Figures\NoisyFourierDomain.png']);
figure, imshow(log10(abs(g)),[]), colorbar
title('Complex-optical field')
set(gcf, 'Position', get(0, 'Screensize'));
export_fig(['Figures\ComplexOpticalField.png']);
%% Compute c and mu 
c  = (1/sigma_w^2)+r(:);                                                     % diagonal-elements of cov. matrix 
inv= ifft2(y);                                                               % fourier-inverse of the observation
mu = c.*(1/sigma_w^2)*inv(:);                                                 % mean of the posterior-distribution
%% Plug and play ADMM algorithm     
maxIters = 25;
v0       = abs(ifft2(y)).^2; 
u0       = zeros(size(v));
sigmaLambda  = 0.5*sqrt(var(v0(:))); 
sigman   = 0.1; 
vPrev    = v0;
uPrev    = u0; 
rPrev    = v0-u0;

for iters = 1:maxIters
    rtildenext = vPrev-uPrev;
    rnext      = inversionOperator(rtildenext,rPrev,sigmaLamda); 
    vtildenext = rnext+uPrev;
    vNext      = denoisingOperator(vtildenext,sigman);
    unext      = uPrev+rnext-vnext;
    vPrev      = vnext;
    uPrev      = unext;
    rPrev      = rnext;
end
%%
