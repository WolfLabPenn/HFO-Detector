# HFO detector
You can find details of the method for detecting high frequency oscillations (HFOs) in [Mirzakhalili _et al. IEEE NER_ (2023)](https://doi.org/10.1109/NER52421.2023.10123882).

The essential codes are included in the **function** folder. 
If you want to run the benchmark scripts, you need to download the **Data** folder. 
## Note:
We had used an open-source library (fcwt) for continuous wavelet transform (cwt) analysis to generate the results in the method paper. However, that library no longer works properly with MATLAB. Hence, the codes in this repository use MATLAB’s native functions for cwt analysis. 

CWT analysis is performed on GPU for faster calculations. You can change that by setting parameters.gpu= false. If you still want to use GPU but do not have enough GPU memory, you can increase parameters.chunks. However, the chunks should be long enough for proper ECDF calculations. 
## benchmark_1.m
This script uses the HFO detector to find HFOs in the [Donos _et al. Front. Neurosci._ (2020)](https://doi.org/10.3389/fnins.2020.00183) benchmark dataset. This script also produces a figure, which compares our method with the results presented in the paper with the benchmark dataset.

![alt text](https://github.com/WolfLabPenn/HFO-Detector/blob/main/Documents/Benchmark_1.svg)
## benchmark_2.m
This script uses the HFO detector to find HFOs in the [Roehri _et al. PloS one_.  (2017)](https://doi.org/10.1371/journal.pone.0174702) benchmark dataset. This script also produces a figure, which compares our method with the results presented in the paper with the benchmark dataset.

The signal for this benchmark is too large to upload on Github. Please download the signal from [here](https://doi.org/10.6084/m9.figshare.23098526) and put it in the **Data** folder.

![alt text](https://github.com/WolfLabPenn/HFO-Detector/blob/main/Documents/Benchmark_2.svg)
