# HFO detector
You can find details of the method for detecting high frequency oscillations (HFOs) in Mirzakhalili _et. al. IEEE NER_ (2023).

The essential codes are included in the **function** folder. 
If you want to run the benchmark scripts, you need to download the **Data** folder. 
## Note:
We had used an open-source library (fcwt) for continuous wavelet transform (cwt) analysis to generate the results in the method paper. However, that library no longer works properly with MATLAB. Hence, the codes in this repository use MATLAB’s native functions for cwt analysis. 
## benchmark_1.m
This script uses the HFO detector to find HFOs in the [Donos _et. al Front. Neurosci._ (2020)](https://doi.org/10.3389/fnins.2020.00183) benchmark dataset. This script also produces a figure, which compares our method with the results presented in the paper with the benchmark dataset.

![alt text](https://github.com/WolfLabPenn/HFO-Detector/blob/main/Documents/Benchmark_1.svg)
## benchmark_2.m
This script uses the HFO detector to find HFOs in the [Roehri _et. al PloS one_.  (2017)](https://doi.org/10.1371/journal.pone.0174702) benchmark dataset. This script also produces a figure, which compares our method with the results presented in the paper with the benchmark dataset.

![alt text](https://github.com/WolfLabPenn/HFO-Detector/blob/main/Documents/Benchmark_2.svg)
