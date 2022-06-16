# Spoken digit recognition
The TI46 Word Corpus contains sound signals of spoken digits and alphabets.
Following the setting of the other studies on reservoir computing, the 500 spoken digit data (5 speakers, 10 utterances, 10 digits) 
are chosen for this classification task. 
The purpose of this task is to classify the sound signals into ten digit classes.

  ## How to use
  ### Step.1
  Download the TI-46 dataset from ([Linguistic Data Consortium](https://catalog.ldc.upenn.edu/LDC93S9)). 
  Put the downloaded and uncompressed folder ```ti46_LDC93S9``` in the folder  ```data```.
  For the preprocessing, the ]sap-voicebox](https://github.com/ImperialCollegeLondon/sap-voicebox) 
  and [AuditoryToolbox](https://engineering.purdue.edu/~malcolm/interval/1998-010/) are required. 
  The data are transformed into cochleagrams which are then masked by the following command:
  ```
  > main
  ```
  
  Two new folders ```cochleagram``` including cochleagrams and ```cochleagram_mask``` including masked cochleagrams will be created.
  
  ### Step.2
  In the folder ```reservoir_response```, an example of a response of the memristor network reservoir to an input signal is produced by the following command:
  ```
  > main
  ```
  
  The output figure corresponds to Fig. 6b of the reference paper.
  
  
  ### Step.3 
  In the folder ```reservoir_computing```, the reservoir computation is performed by the following command:
  ```
  > main
  ```
  
  First, a new folder ```reservoir_states``` including edge currents on the memristor networks for all the data will be created.
  Second, using the reservoir states for the training data, the readout weight matrix is optimized.
  Third, the trained system produces a predicted class label for each of the testing data.
  The classification accuracies for the training and testing data are evaluated.
