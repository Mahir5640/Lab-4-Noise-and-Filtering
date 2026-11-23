%% Lab 4: Noise and Filtering
close all; clear; clc;

lab4Folder = fileparts(mfilename('fullpath'));
outputDir = fullfile(lab4Folder, 'screenshots');
if ~isfolder(outputDir)
    mkdir(outputDir);
end

rng(42);  % Reproduce the same noise each time
I = im2double(rgb2gray(imread('peppers.png')));

%% 1) Add Gaussian and salt-and-pepper noise
I_gauss = imnoise(I, 'gaussian', 0, 0.01);
I_sp = imnoise(I, 'salt & pepper', 0.05);

fig = figure('Position', [100 100 1200 380]);
subplot(1,3,1); imshow(I, [0 1]); title('Original');
subplot(1,3,2); imshow(I_gauss, [0 1]); title('Gaussian noise');
subplot(1,3,3); imshow(I_sp, [0 1]); title('Salt-and-pepper noise');
exportgraphics(fig, fullfile(outputDir, '01-noise.png'));

%% 2) Measure MSE and SNR before filtering
signalPower = mean(I(:).^2);

MSE_gauss = immse(I_gauss, I);
MSE_sp = immse(I_sp, I);

SNR_gauss = 10 * log10(signalPower / MSE_gauss);
SNR_sp = 10 * log10(signalPower / MSE_sp);

fprintf('\nBefore filtering\n');
fprintf('Gaussian noise        MSE = %.6f | SNR = %.2f dB\n', ...
    MSE_gauss, SNR_gauss);
fprintf('Salt-and-pepper noise MSE = %.6f | SNR = %.2f dB\n', ...
    MSE_sp, SNR_sp);

fig = figure('Position', [100 100 850 350]);
subplot(1,2,1);
bar([MSE_gauss, MSE_sp]);
xticks(1:2); xticklabels({'Gaussian', 'Salt & pepper'});
ylabel('MSE'); title('MSE before filtering'); grid on;

subplot(1,2,2);
bar([SNR_gauss, SNR_sp]);
xticks(1:2); xticklabels({'Gaussian', 'Salt & pepper'});
ylabel('SNR (dB)'); title('SNR before filtering'); grid on;
exportgraphics(fig, fullfile(outputDir, '02-noisy-metrics.png'));

%% 3) Apply linear mean and Gaussian filters
h_avg = fspecial('average', 3);
h_gauss = fspecial('gaussian', [3 3], 0.7);

I_avg_gauss = imfilter(I_gauss, h_avg, 'replicate');
I_avg_sp = imfilter(I_sp, h_avg, 'replicate');

I_gauss_gauss = imfilter(I_gauss, h_gauss, 'replicate');
I_gauss_sp = imfilter(I_sp, h_gauss, 'replicate');

fig = figure('Position', [100 100 900 680]);
subplot(2,2,1); imshow(I_avg_gauss, [0 1]); title('Gaussian noise | Mean filter');
subplot(2,2,2); imshow(I_gauss_gauss, [0 1]); title('Gaussian noise | Gaussian filter');
subplot(2,2,3); imshow(I_avg_sp, [0 1]); title('Salt & pepper | Mean filter');
subplot(2,2,4); imshow(I_gauss_sp, [0 1]); title('Salt & pepper | Gaussian filter');
exportgraphics(fig, fullfile(outputDir, '03-linear-filters.png'));

%% 4) Apply the nonlinear median filter
% Replicate padding matches the boundary handling used by the linear filters.
I_med_gauss = median3_replicate(I_gauss);
I_med_sp = median3_replicate(I_sp);

fig = figure('Position', [100 100 900 680]);
subplot(2,2,1); imshow(I_gauss, [0 1]); title('Gaussian noise | Before');
subplot(2,2,2); imshow(I_med_gauss, [0 1]); title('Gaussian noise | Median filter');
subplot(2,2,3); imshow(I_sp, [0 1]); title('Salt & pepper | Before');
subplot(2,2,4); imshow(I_med_sp, [0 1]); title('Salt & pepper | Median filter');
exportgraphics(fig, fullfile(outputDir, '04-median-filter.png'));

%% 5) Compare all methods for both noise types
methods = {'No filter'; 'Mean'; 'Gaussian'; 'Median'};

mseGaussian = [MSE_gauss;
               immse(I_avg_gauss, I);
               immse(I_gauss_gauss, I);
               immse(I_med_gauss, I)];

mseSaltPepper = [MSE_sp;
                 immse(I_avg_sp, I);
                 immse(I_gauss_sp, I);
                 immse(I_med_sp, I)];

snrGaussian = 10 * log10(signalPower ./ mseGaussian);
snrSaltPepper = 10 * log10(signalPower ./ mseSaltPepper);

results = table(methods, mseGaussian, snrGaussian, mseSaltPepper, snrSaltPepper, ...
    'VariableNames', {'Method', 'Gaussian_MSE', 'Gaussian_SNR_dB', ...
                      'SaltPepper_MSE', 'SaltPepper_SNR_dB'});

fprintf('\nComparison against the original image\n');
disp(results);

[~, bestGaussian] = min(mseGaussian(2:end));
[~, bestSaltPepper] = min(mseSaltPepper(2:end));
fprintf('Best tested filter for Gaussian noise: %s\n', methods{bestGaussian + 1});
fprintf('Best tested filter for salt-and-pepper noise: %s\n', methods{bestSaltPepper + 1});

fig = figure('Position', [100 100 1100 420]);
subplot(1,2,1);
bar([mseGaussian, mseSaltPepper]);
xticks(1:4); xticklabels(methods);
ylabel('MSE'); title('MSE comparison'); grid on;
legend('Gaussian noise', 'Salt & pepper', 'Location', 'best');

subplot(1,2,2);
bar([snrGaussian, snrSaltPepper]);
xticks(1:4); xticklabels(methods);
ylabel('SNR (dB)'); title('SNR comparison'); grid on;
legend('Gaussian noise', 'Salt & pepper', 'Location', 'best');
exportgraphics(fig, fullfile(outputDir, '05-filter-comparison.png'));

%% 6) Reflection answers are in README.md
fprintf('\nFigures saved to %s\n', outputDir);

function filtered = median3_replicate(noisyImage)
    paddedImage = padarray(noisyImage, [1 1], 'replicate');
    filteredPadded = medfilt2(paddedImage, [3 3]);
    filtered = filteredPadded(2:end-1, 2:end-1);
end