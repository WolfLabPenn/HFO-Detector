clc;
clear;
%%
% You can also find the data and the dector by Donos et al. here:
% https://bitbucket.org/cristidonos/hfodetector/src/master/
load('Data\Donos_signal_2.mat');
load('Data\Donos_ground_truth_2.mat');
gt(:,4)= 0.5:1:300;
fs= 2000;
%% General parameters
parameters.channels= 1:6; % Channels to loop through
parameters.fs= fs; % Sampling frequency
parameters.add_time= 0; % Add time to an event that is detected. Helpful when a long recording is broken into shorter recordings.
%% Continuous wavelet transform (CWT) parameters
parameters.wavelet= 'morse'; % Type of wavelet
parameters.WaveletParameters= [9,120]; % Parameters of wavelet.
parameters.VoicesPerOctave= 16; % Voices per octave
parameters.FrequencyLimits= [15,1000]; % Frequncy range for CWT analysis
parameters.gpu= false; % Using gpu for CWT
parameters.unimodal= false;% Making sure blobs are unimodal
%% Parameters for detecting and characterizing blobs
parameters.compare= 'magnitude'; % Use "amplidute" or "power" for comparison
parameters.center= 'mean'; % Use "mean" or "max" as the center 
%% Ripple detection parameters
parameters.ripple.ecdf= 0.993; % Cutoff threshold
parameters.ripple.range= [80,250];% Frequency range to detect ripples
parameters.ripple.n_cyles= 3; % Number of cycles a ripple must have at the "center" frequency
parameters.ripple.frequency_range_th= 160; % Allowable difference between lowest and higher frequncy of a blob
parameters.ripple.mean_th= 3.5; % Threshold that a blob mean/max needs to be compared to all the data at its central frequency 
parameters.ripple.ext= 500;% Upper limit allowed for comparison
%% Fast-ripple detection parameters
parameters.fast_ripple= []; % Not interested in detecting fast ripples in this dataset.
%% Spike detection parameters
parameters.spike= []; % Not interested in detecting fast ripples in this dataset.
%% Detecting HFOs
if parameters.unimodal
    results= HFO_detector_unimodal(signal,parameters); % Calling HFO detector function. 
else
    results= HFO_detector(signal,parameters); % Calling HFO detector function
end
%% Comparing the results with the published data for Donos et al. dataset
% https://doi.org/10.3389/fnins.2020.00183
load('Donos_paper_F1Score');
delta_t= 0.1; % The window size [s] to check for true positives (TP), false positives (FP), and false negatives (FN)
F_all= zeros(4,6);
for i= 1:4
    temp= [results.channel(i).ripples.center];
    test= [temp.time];
    [TP,FP,FN,~]= compare_resutls(test,gt(:,4),delta_t); % Comparing the results against the benchmark
    F= sum(TP,1)./(sum(TP,1)+0.5*(sum(FP,1)+sum(FN,1)));
    F_all(i,:)= [F,F1Score(i,:)];
end
bar(F_all);
xticklabels({'-9dB','-6dB','-3dB','0dB'})
xlabel('SNR')
ylabel('F-Measure')
legend('Ours','Donos','Hilbert','STE','SLL','MNI','Location','northoutside','Orientation','horizontal','Box','off')