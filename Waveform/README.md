# Waveform classification
A set of multiple sinusoidal and triangular waveform data are generated. 
Their amplitudes are the same, but the frequencies are distributed. 
The purpose of this task is to classify the waveforms into the two types.

  ## How to use
  ### Step.1
  In the folder  ```data```, 100 sinusoidal and 100 triangular waveform data are generated with the following command:
  ```
  > main
  ```
  
  A new folder ```dataset``` including the 200 timeseries data will be created.
  
  ### Step.2
  In the folder ```reservoir_response```, an example of a response of the memristor network reservoir to input waveform data is produced with the following command:
  ```
  > main
  ```
  
  The output figure corresponds to Fig. 2 of the [reference paper](https://www.nature.com/articles/s41598-022-13687-z).
  
  
  ### Step.3 
  In the folder ```reservoir_computing```, the reservoir computation is performed with the following command:
  ```
  > main
  ```
  
  First, a new folder ```reservoir_states``` including edge currents on the memristor networks for all the data will be created.
  Second, using the reservoir states for training data, the readout weight matrix is optimized.
  Third, the trained system produces a predicted class for each testing data.
  The classification accuracies for the training and testing data are obtained.
  
