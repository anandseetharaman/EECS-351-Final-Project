<h1>EECS 351 Project: Music Artist Identifier</h1>

<h2>Project Description</h2>
<p>In this project, we are attempting to classify a music artist based on their song using Digital Signal Processing(DSP) Techniques and Machine Learning. Initally, we will process our signals to remove unwanted noise and ensure that we are able to isolate the voice of the music artist from their music and then use existing machine learning models to classify those signals. Our goal is to ensure that the machine learning models are able to have an accuracy of atleast 75% after our signal processing methods are applied to the data.  <p>

<h2>DSP Tools Used</h2>
<p>For our project, we used various DSP Tools to isolate the vocals of the music artist while attenuating the instrumentals. The following is a list of some of the tools used: </p>
<ul>
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
