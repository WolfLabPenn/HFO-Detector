# HFO detector
You can find details of the method for detecting high frequency oscillations (HFOs) in Mirzakhalili _et. al. IEEE NER 2023_. 
The essential codes are included in the **function** folder. 
If you want to run the benchmark scripts, then you need to download the **Data** folder. 
Please download all the scripts and folders and put them in the same directory.
## Note:
We had used an open-source library (fcwt) for continuous wavelet analysis to generate the results in the method paper. However, that library no longer works properly with MATLAB. Hence, the codes in this repository use MATLAB’s native functions for continuous wavelet analysis. 
## Benchmark_1.m
This script uses the HFO detector to find HFOs in the [Donos _et. al_ benchmark dataset] (https://doi.org/10.3389/fnins.2020.00183). The script also produces a figure, which compares our method with the results presented in [Donos _et. al Front. Neurosci._ (2020)] (https://doi.org/10.3389/fnins.2020.00183). 
## Benchmark_2.m
This script uses the HFO detector to find HFOs in the [Roehri _et. al_ benchmark dataset] (https://doi.org/10.1371/journal.pone.0174702). The script also produces a figure, which compares our method with the results presented in [Donos _et. al PloS one_.  (2017)] (https://doi.org/10.1371/journal.pone.0174702). 
