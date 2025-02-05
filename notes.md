## Code Studied
https://github.com/aave/aave-protocol/blob/master/contracts/tokenization/AToken.sol

1. A protocol that allows users to deposit into a vault and in return , receiver rebase tokens that represent their underlying balance;
2. Rebase token -> balanceOf()  function is dynamic to show the changing balance with time. 
    - Balance increases linearly with time  [ meaning early depositor get more money ..]
    NB: the balanceOf function is a view function so we 
    - mint tokens to our users everytime they perform an action ( minting , burning , transferring or .. bridging).. so lets say if they do any action we check if the balance has increase and we mint that token increase to the user so that their actually number of tokens represent the principal + accrued interest so this is where we update the state

3. Interest Rate [ interest rewards can be as a result of staking , lending or a way to increase token adoption ]
      - Individually set an interest rate or each user based on some global interest rate of the protocol at the time the user deposits into the vault. 
      - This global interest rate can only decrease to incentivize / reward early adopters


Summary :
 -  user deposits ETH into Vault contract 
 - Vault Contract calls rebase token contract to mint rebase tokens 
 - set interest rate based on global interest rate
 -interest can be decreased automatically or manuallly by the protocol 






/////////////////////////////////////////
 Video 4 : @7:20 you cant work with deciamls in solidity so 
 - 1.1  tokens  would have to follow the 1e18 so 
( 1.1 is 11e17)  if you divide (11e17) by 10e18 you get back 1.1


so percent format lets say 50% is the same as 0.5 
then 0.5 is 5e17

so 5e10 representing a percentage would be 

0.0000005 * 100% which means 0.00005%
////////////////////////////////////////





******************************************
video 4 @14:09 : if someone has already minted before meaning they have already deposited eth into the vault 

and they come and deposit in the vault again and call mint they... we rather want the mint function to mint the token only and only after the  accrue interest 
for that user before they mint anymore tokens.. so we (mint accrued interest) so any interest based on their "actions" we mint then we mint the rebase token
******************************************









<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>
video 5 @6:58: Because in the real world thereis some kind of latency so from the 

Time you send a Txn on chain :  
It can take some a while to go through 
There you wait for finality etc 

There can be interest that can be accrued so we need to account for the left over interest that is being accrued when someone is redeeming their eth / aUSDC and burning the rebase token

so even if they think they are passing their current balance to redeem everything they arent 

so if they pass the max value of uint256 in our case to the Vault contract to redeem which would call the burn function in the rebase then we withdraw  

this is a common thing in DEFI
<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>






///////////////////////////////////////
video 6 @0:27 
We digging into the inherited ERC20 smart contract to see if we can override some functions


-    totalSupply()  : now in order to get an accurate totalSupply of our rebase token 
    which is accrued tokens we owe users + minted tokens, 

    we need to loop through every user in the protocol and calculate their balanceOf accounting the interest we owe them and update the totalSupply() with 
    super.totalSupply() however you can get some kind of DOS [denial of service] if the array of users becomes extremely long and do calculation for alot of people 

    but for now we are going to assume that we are accepting this flaw and accept that the total supply is going to be any minted tokens,  not including any interest that is owed 


-   transfer(): we need to implement / override the transfer 
  
  "Because we want to be setting/updating  the interest rate for users that are receving a transfer"

  so if Bob sends Alice the rebase token cause we dont have track of her interest on our contract if we dont override Alice cannot earn interest.

  Now we know that the interest rate also reduce with time so this means that when Bob starts with smaller deposit but early he would have a higher interest rate attached to his wallet and if the interest rate drops and he transfers the one getting it would get a lower interest rate.. cause we are setting the interest rate in our overriding logic 

  This also means that if Bob started late and sending to a wallet that started early that can cause its interest

   but our logic would not set if the receiver has an interest rate already set 

- transferFrom()  same thing as transfer





///////////////////////////////////////







