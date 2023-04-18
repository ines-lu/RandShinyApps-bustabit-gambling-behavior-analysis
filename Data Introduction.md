
### Bustabit dataset
The dataset I am working with includes a total of 50000 rows (one game played by one player), with over 40000 games of Bustabit by a bit over 4000 different players. The source of the data is: [https://www.kaggle.com/datasets/lifebetting/bustabit](https://www.kaggle.com/datasets/lifebetting/bustabit)


#### The modified variables in the dataset are:

I modified the existing data in order to have a complete understanding of player behavior. Originally, the Profit column only reflects the amount won in each game, but it didn't show the amount lost if the player lost or an indicator for whether the game was a win or a loss overall. To address this, I create and modify some variables.
<ol>

<li> <strong>Id:</strong> A unique identifier for a specific row (representing a player's game outcome)</li>
<li> <strong>GameID:</strong> A unique identifier for a specific game</li>
<li> <strong>Username:</strong> A unique identifier for a player</li>
<li> <strong>Bet:</strong> The amount of Bits (equivalent to 1/1,000,000 of a Bitcoin) placed by the player in the game</li>
<li> <strong>CashedOut:</strong> The multiplier at which the player cashed out in this game. If the value of CashedOut is NA, it will be set to 0.01 more than the BustedAt value to represent the player failed to cash out before losing</li>
<li> <strong>Bonus:</strong> The bonus (expressed as a percentage) awarded to the player for this game</li>
<li> <strong>Profit:</strong> The amount the player won in the game, calculated as (Bet * CashedOut) + (Bet * Bonus) - Bet. If the value of Profit is NA, it will be set to zero to indicate that the player didn't make a profit in that game</li>
<li> <strong>BustedAt:</strong> The multiplier at which this game ended</li>
<li> <strong>Losses:</strong> If the new value of Profit is zero, Losses will be set to the amount the player lost in that game, otherwise, it will be set to zero. This value will always be either zero or negative</li>
<li> <strong>GameWon:</strong> If the player made a profit in the game, this value will be 1, and 0 otherwise</li>
<li> <strong>GameLost:</strong> If the player made a profit in the game, this value will be 1, and 0 otherwise</li>
<li> <strong>PlayDate:</strong> The date and time the game took place</li>



</ol>

