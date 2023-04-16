### Normalization of the derived features
<p>As can be seen, <code>AverageBet</code> is in bits (1/1000000 of a Bitcoin), <code>AverageCashedOut</code> is a multiplier, and <code>GamesLost</code> and <code>GamesWon</code> are counts. Therefore, I use <strong>mean-sd</strong> standardization(<strong>Z-score</strong>) to scale the data, so that the variables will have approximately equal weighting. 
</p>


![Standardization Tutorial](https://ibb.co/jrYz2Xn)

