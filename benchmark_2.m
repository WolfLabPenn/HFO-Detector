clc;
clear;
%%
if ~exist('.\Functions','dir')
    error('Please put the script in the same directory as the Function folder')
else
    addpath('.\Functions');
end
%% You can also find the data and the dector by Roehri et al. here but it requires some processing (rearranging)
% https://figshare.com/articles/dataset/Simulation_Dataset_of_SEEG_signal_for_HFO_detector_validation/4729645
if ~exist('.\Data','dir')
    error('Please put the script in the same directory as the Data folder to run benchmark_2')
else
    load('.\Data\Roehri_signal.mat');
    gt=load('.\Data\Roehri_ground_truth.mat'); % Ground truth
    fs=2048; % Sampling frequency of benchmark data
    L=length(signal); % Length of the signal
end
%% General parameters
parameters.channels= 1:32; % Channels to loop through
parameters.fs= fs; % Sampling frequency
parameters.chunks= 6; % Breaking data into smaller chunks
parameters.verbose= true; % Display some information
%% Continuous wavelet transform (CWT) parameters
parameters.wavelet= 'morse'; % Type of wavelet
parameters.WaveletParameters= [9,120]; % Parameters of wavelet.
parameters.VoicesPerOctave= 16; % Voices per octave
parameters.FrequencyLimits= [15,1000]; % Frequncy range for CWT analysis
parameters.gpu= false; % Using gpu for CWT
%% Parameters for detecting and characterizing blobs
parameters.compare= 'magnitude'; % Use "amplidute" or "power" for comparison
parameters.center= 'mean'; % Use "mean" or "max" as the center
parameters.unimodal= true; % Making sure detected blobs are unimodal
%% Ripple detection parameters
parameters.ripple.ecdf= 0.993; % Cutoff threshold
parameters.ripple.range= [80,250]; % Frequency range to detect ripples
parameters.ripple.n_cyles= 3; % Number of cycles a ripple must have at the "center" frequency
parameters.ripple.frequency_range_th= 170*98/100; % Allowable difference between lowest and higher frequncy of a blob
parameters.ripple.mean_th= 3.5; % Threshold that a blob mean/max needs to be compared to all the data at its central frequency
parameters.ripple.ext= 500; % Upper limit allowed for comparison
parameters.ripple.save_ecdf= false;% Saving ecdf results is unnecessary and takes large space
%% Fast-ripple detection parameters
parameters.fast_ripple.ecdf=0.998; % Cutoff threshold
parameters.fast_ripple.range=[250,500]; % Frequency range to detect fast-ripples
parameters.fast_ripple.n_cyles=3; % Number of cycles a ripple must have at the "center" frequency
parameters.fast_ripple.frequency_range_th=250*98/100; % Allowable difference between lowest and higher frequncy of a blob
parameters.fast_ripple.mean_th=3.5; % Threshold that a blob mean/max needs to be compared to all the data at its central frequency
parameters.fast_ripple.ext=500; % Upper limit allowed for comparison
parameters.fast_ripple.save_ecdf= false; % Saving ecdf results is unnecessary and takes large space
%% Spike detection parameters
parameters.spike.prom=1.5; % minimum dominance of peaks
parameters.spike.range=[15,45]; % Frequency range to detect fast-ripples
parameters.spike.artifact=[990,995]; % Frequncy range for artifacts that look like spikes
%% Detecting HFOs
results= HFO_detector(signal,parameters); % Calling HFO detector function
%% Comparing the results with the published data for Roehri et al. dataset
% https://doi.org/10.1371/journal.pone.0174702
delta_t= 0.1; % The window size [s] to check for true positives (TP), false positives (FP), and false negatives (FN)
TP_HFO=zeros(8,4);FP_HFO=zeros(8,4);FN_HFO=zeros(8,4); % Initializing TP, FP, FN for HFOs
TP_spikes=zeros(8,4);FP_spikes=zeros(8,4);FN_spikes=zeros(8,4); % Initializing TP, FP, FN for spikes
N=1e6;
for channel=1:8 % Looping through the channels
    for dB=1:4 % Looping through different SNRs
        selection=dB+(channel-1)*4; % Picking up the correct channel from the dataset based on the channel and SNR
        current_R=gt.R{selection}; % Getting ripples from benchmark
        current_FR=gt.FR{selection}; % Getting fast-ripples from benchmark
        current_RFR=gt.RFR{selection}; % Getting ripple+fast-ripples from benchmark;
        current_SR=gt.SR{selection}; % Getting spikes+ripple from benchmark;
        current_SFR=gt.SFR{selection}; % Getting spikes+fast-ripples from benchmark;
        current_SRFP=gt.SRFR{selection}; % Getting spikes+ripples+fast-ripples from benchmark
        current_S=gt.S{selection}; % Getting spikes from benchmark;
        check_HFO=[current_R;current_RFR;current_SR;current_SRFP;current_FR;current_SFR]; % Putting together all the events in the ground truth that can be counted as HFOs
        test_HFO=zeros(1,N); 
        n=0;
        for j=1:parameters.chunks
            temp=[results.channel(selection,j).ripples.center,results.channel(selection,j).fast_ripples.center]; % Putting together detected ripples and fast-ripples as HFOs
            temp=[temp.time];
            test_HFO(n+1:n+length(temp))=temp;
            n=n+length(temp);
        end
        test_HFO(n+1:N)=[];
        [TP_HFO(channel,dB),FP_HFO(channel,dB),FN_HFO(channel,dB),TP_Inds]=compare_resutls(test_HFO,check_HFO,delta_t); % Comparing detected HFOs with ground truth
    end
end
F_all=zeros(4,6);
F_all(:,1)=sum(TP_HFO,1)./(sum(TP_HFO,1)+0.5*(sum(FP_HFO,1)+sum(FN_HFO,1)));
dataset={'Delphos_All','Hilbert_HFOs','STE_HFOs','SLL_HFOs','MNI_HFOs'};
for i=1:length(dataset)
    data=load(['./Data/',dataset{i},'.mat']);
    TP=data.TP_HFO;
    FP=data.FP_HFO;
    FN=data.FN_HFO;
    F_all(:,i+1)=sum(TP,1)./(sum(TP,1)+0.5*(sum(FP,1)+sum(FN,1)));
end
% Plotting the results
bar(F_all);
xticklabels({'0','5','10','15'})
xlabel('SNR')
ylabel('F-Measure')
legend('Ours','Delphos','Hilbert','STE','SLL','MNI','Location','northoutside','Orientation','horizontal','Box','off')