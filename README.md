<h1>EECS 351 Project: Music Artist Identifier</h1>

<h2>Project Description</h2>
<p>In this project, we are attempting to classify a music artist based on their song using Digital Signal Processing(DSP) Techniques and Machine Learning. Initally, we will process our signals to remove unwanted noise and ensure that we are able to isolate the voice of the music artist from their music and then use existing machine learning models to classify those signals. Our goal is to ensure that the machine learning models are able to have an accuracy of atleast 75% after our signal processing methods are applied to the data.<p>

<h2>Dataset Collected</h2>
<p>For our data, we decided to have 8 music artists, 4 male and 4 female, and for each music artist we found 10 songs and extracted a 10 second clip from each song. The music artists we selected were Drake, Pitbull, Taylor Swift, Katy Perry, Beyonce, The Weeknd, Travis Scott, and Lana Del Ray. Later on, we also added 10 more clips(making a total of 20) each for four of the music artists, Drake, Lana Del Ray, Taylor Swift, and Pitbull, to see if additional amount of data for a smaller number of music artists would improve our classification model. </p>

<h2>DSP Tools Used</h2>
<p>For our project, we used various DSP Tools to isolate the vocals of the music artist while attenuating the instrumentals. The following is a list of some of the tools used: </p>
<ul>
  <li>demo.m: Uses a trained KNN classifier to determine artists from unseen audio clips</li>
  
  <li>Frequency Domain Analysis: Transform our audio signals into frequency domain and analyze from there</li>
  
  <li>Filters: Attenuate all the noise with frequencies outside of the desired frequency range, which would be human vocals frequncy range for out project</li>

  <li>Spectrogram: Visual representation of frequencies as they vary with time</li>

  <li>Fingerprinting: Identifying songs based on a unique fingerprint created for each song following the process used by researchers from the University of Rochester</li>
</ul>

<h2>Machine Learning Models Used</h2>
<p>We used the following pre-existing machine learning classifier models to train our processed audio clips and classify them </p>
<ul>
  <li>K-Nearest Neighbor: Classify data by looking at it's nearest 'k' neighbors(where k represents an integer) based on euclidean distance</li>
  
  <li>Decision Tree: Splits and segments the data based on its most signinficant features</li>

  <li>SVM: Finds the optimal hyperplanes in order to separate the data to create different classes </li>

</ul>

<h2>MATLAB Files</h2>
<ul>
  <li>demo.m: Uses a trained KNN classifier to determine artists from unseen audio clips</li>
  <li>Fingerprinting.m: Generates fingerprints for each song and trains a decision tree using the fingerprints</li>

  <li>decision_tree_v2_test.m: Calculates the maximum magnitude value across time frames for each frequency to generate a feature matrix for each song for the decision tree and calls decision decision_tree_v2_magnitude.m to run the decision tree classifier</li>

  <li>decision_tree_v2_magnitude.m: Runs the decision tree classifier for decision_tree_v2_test.m </li>

  <li>decision_tree_v3_MFCC_test.m: Extracts 13 MFCCs from each song and calculate the mean of each of the coefficients for each of the songs and store them in a feature vector</li>

  <li>decision_tree_v3_MFCC.m: Runs the decision tree classifier for decision_tree_v3_MFCC_test.m</li>

  <li>classificationTest.m: Trains a set of data, on a range of audio features, in either KNN, naive bayes, or discriminant analysis. Cross evaluates the classifier and tests it on unused data to determine effectiveness</li>

  <li>testNotch.m: Notch filter used to remove unwanted noise in audio clips</li>

  <li>filterSong.m: Uses testNotch.m to take in a wav file and filter it and outputs the filtered file with the prefix “filter_”</li>
</ul>
