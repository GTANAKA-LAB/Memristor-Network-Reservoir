# ECG classification
The ECG200 dataset contains normal and abnormal ECG data. 
The datset is divided into 100 training (normal: 69, abnormal: 31) and 100 testing data (normal: 64, abnormal: 36). 
The purpose of this task is to classify the ECG signals into the two types.

  ## How to use
  ### Step.1
  Download the ECG200 dataset from ([UEA & UCR Time Series Classification Repository](https://timeseriesclassification.com/description.php?Dataset=ECG200)). 
  Put the downloaded folder ```ECG200``` in the folder  ```data```. 
  The masked ECG data are obtained by the following command:
  ```
  > main
  ```
  
  A new folder ```ECG_mask``` including 200 masked data will be created.
  
  ### Step.2
  In the folder ```reservoir_response```, an example of a response of the memristor network reservoir to an input ECG signal is produced by the following command:
  ```
  > main
  ```
  
  The output figure corresponds to Fig. 4b of the [reference paper](https://www.nature.com/articles/s41598-022-13687-z).
  
  
  ### Step.3 
  In the folder ```reservoir_computing```, the reservoir computation is performed by the following command:
  ```
  > main
  ```
  
  First, a new folder ```reservoir_states``` including edge currents on the memristor networks for all the data will be created.
  Second, using the reservoir states for the training data, the readout weight matrix is optimized.
  Third, the trained system produces a predicted class label for each of the testing data.
  The classification accuracies for the training and testing data are evaluated.
