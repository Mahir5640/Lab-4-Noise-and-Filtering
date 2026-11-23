# Lab 4 — Noise and Filtering

**Mahir Foysol Chowdhury**  
Mathematical Algorithms (DSP) — Image Processing Labs

## How to run

Open `lab4_noise_filtering.m` in MATLAB with Image Processing Toolbox
and click Run. The script exports five figures to `screenshots/` and
prints the measured results in the Command Window.

## 1. Noise models

I converted `peppers.png` to grayscale and added two types of noise.
The Gaussian noise has a specified mean of 0 and variance of 0.01.
It produces small intensity variations throughout the image.
Salt-and-pepper noise with a density of 0.05 replaces about 5% of the
pixels with black or white values. A fixed random seed makes the
experiment reproducible.

![Original image and two noisy images](screenshots/01-noise.png)

## 2. Image quality before filtering

I used the original grayscale image as the reference. Mean-square
error (MSE) is the average of the squared pixel differences. I computed
signal-to-noise ratio as `10 * log10(signalPower / MSE)`, using the
mean squared intensity of the original image as the signal power.
Lower MSE and higher SNR indicate a closer match to the reference.

![MSE and SNR for both noisy images](screenshots/02-noisy-metrics.png)

## 3. Linear filtering

I applied a 3×3 mean filter and a 3×3 Gaussian filter to both noisy
images. The mean filter gives equal weight to all nine pixels.
The Gaussian filter, with a standard deviation of 0.7 pixels, gives
more weight to pixels near the center. Averaging reduces random
intensity variations, but it can also soften edges and spread the
effect of an isolated black or white pixel to its neighbors.

![Mean and Gaussian filtering results](screenshots/03-linear-filters.png)

## 4. Median filtering

The 3×3 median filter sorts the values in each neighborhood and uses
the middle value. An isolated black or white pixel usually falls near
one end of that sorted list, so it has little effect on the output.
I used replicated boundaries for all three filters so they treat the
image borders consistently.

![Both noise types before and after median filtering](screenshots/04-median-filter.png)

## 5. Comparison after filtering

I compared the original noisy inputs and all three filter outputs
against the clean reference. For each noise type, the shortest MSE
bar and tallest SNR bar identify the closest result by these metrics.
Both rankings agree here because the reference signal power stays
the same. The Command Window also identifies the best tested filter
for each noise type.

![MSE and SNR comparison for both noise types](screenshots/05-filter-comparison.png)

## 6. Reflections

1. **Which noise is best removed by a median filter? Why?**  
   Salt-and-pepper noise is especially suited to median filtering
   because its black and white impulses are extreme values. If most
   pixels in a neighborhood are clean, the median usually selects a
   value representative of those clean pixels.

2. **Why does linear filtering blur edges?**  
   A mean or Gaussian filter averages pixels on both sides of an
   edge. This produces intermediate values and turns a sharp jump
   in intensity into a gradual transition.

3. **How could an adaptive filter preserve more detail?**  
   An adaptive filter could smooth more strongly in flat regions
   and less strongly near edges. For impulse noise, it could first
   compare each pixel with its local median and replace only pixels
   that differ substantially from their neighbors. This would leave
   more clean pixels and fine details intact.
