pragma solidity ^0.7.0;
//SPDX-License-Identifier: UNLICENSED

contract FREE_BET {

  struct bet_struct{
    uint amount;
    uint blocknr;
  }

  uint public balance;
  uint private n256=10; // Set to 10 only for testing purposes!
  //This should be set to the maximum possible amount (256)
  //After this number of blocks bets are automatically lost if they have not been claimed
  uint private bet_balance;
  uint private total_shares;
  mapping(address=>uint) private client_shares;

  mapping(address=>bet_struct) private bet;
  address[] public unclaimed_bets;

  //provide liquidity
  function deposit() public payable { // needs to be public due to call from receive fallback function
    if (balance==0 || total_shares==0) {
      balance+=msg.value;
      client_shares[msg.sender]+=msg.value;
      total_shares+=msg.value;
    }
    else {
      client_shares[msg.sender]+=total_shares*msg.value/balance;
      total_shares+=total_shares*msg.value/balance;
      balance+=msg.value;
    }
  }

  function getMyBalance() public view returns(uint) {
    return(balanceOf(msg.sender));
  }

  function getMyMaxWithdrawal() public view returns(uint) {
    return(maxWithdrawalOf(msg.sender));
  }

  function balanceOf(address _addr) public view returns(uint){
    if (total_shares==0) {return 0;}
    return(uint(client_shares[_addr]*balance/total_shares));
  }

  function updateContractBalance() public { // could become handy if the contract receives some forced payments (e.g., through selfdestruct)
    balance = address(this).balance;
  }

  function maxWithdrawalOf(address _addr) public view returns(uint){
    if (total_shares==0) {return 0;}
    return(uint(client_shares[_addr]*(balance-bet_balance)/total_shares));
  }

  //remove liquidity
  function withdraw(uint amount) external {
    uint sender_balance=balanceOf(msg.sender);
    require(sender_balance>0,"Balance zero");
    uint maxWithdrawal=maxWithdrawalOf(msg.sender);
    if (amount>maxWithdrawal) {amount=maxWithdrawal;}
    uint num_shares=total_shares*amount/balance;
    //state changes
    client_shares[msg.sender]-=num_shares;
    total_shares-=num_shares;
    balance-=amount;
    //transfer
    msg.sender.transfer(amount);
  }

  function placeBet() external payable {
    require(msg.value>1000,"minimal bet: 1000 wei");
    require(unclaimed_bets.length<100,"maximum number of active bets reached");
    require(bet[msg.sender].blocknr+1<block.number,"one bet at a time");
    require(bet_balance+msg.value<balance*20/100,"betting pool too large");
    require(msg.value<balance*2/100,"bet too large for current liquidity");
    if(bet[msg.sender].amount>0){claimBet();}
    bet[msg.sender].amount=msg.value;
    bet[msg.sender].blocknr=block.number;
    bet_balance+=msg.value;
    unclaimed_bets.push(msg.sender);
  }

  function claimBet() public { //needs to be public due to call from placeBet
    require(bet[msg.sender].amount>0,"nothing to claim");
    require(bet[msg.sender].blocknr+1<block.number,"dices have not fallen yet");
    if (won()) {
      uint amount = bet[msg.sender].amount;
      //state changes
      bet[msg.sender].amount=0;
      bet_balance-=amount;
      balance-=amount*94/100;
      remove(msg.sender);
      //transfer
      msg.sender.transfer(amount*194/100);
    }
    else {
      uint amount = bet[msg.sender].amount;
      //state changes
      bet[msg.sender].amount=0;
      bet_balance-=amount;
      balance+=amount;
      //2% reward for claiming lost bet
      uint reward=amount*2/100;
      client_shares[msg.sender]+=total_shares*reward/balance;
      total_shares+=total_shares*reward/balance;
      remove(msg.sender);
    }
  }

  function lostInTime() public view returns(uint,uint){
    uint amount;
    uint count;
    for(uint k=0;k<unclaimed_bets.length;k++){
      if(block.number>bet[unclaimed_bets[k]].blocknr+n256){
        amount+=bet[unclaimed_bets[k]].amount;
        count++;
      }
    }
    return(amount,count);
  }

  function claimLostInTime() external {
    uint amount=0;
    for(uint k=0;k<unclaimed_bets.length;k++){
      if(block.number>bet[unclaimed_bets[k]].blocknr+n256){
        amount+=bet[unclaimed_bets[k]].amount;
        removeByIndex(k);//is unclaimed_bets.length automatically updated????
        k--;
      }
    }
    if (amount>0) {
      bet_balance-=amount;
      balance+=amount;
      //2% reward for claiming the bets lost in time
      uint reward=amount*2/100;
      client_shares[msg.sender]+=total_shares*reward/balance;
      total_shares+=total_shares*reward/balance;
    }
  }

  function won() public view returns(bool){
    require(bet[msg.sender].amount>0,"nothing to evaluate");
    require(bet[msg.sender].blocknr+1<block.number,"too early to evaluate");
    if (block.number>bet[msg.sender].blocknr+n256) {return(false);}
    if (uint(keccak256(abi.encodePacked(blockhash(bet[msg.sender].blocknr+1), msg.sender)))%2==1){return(true);}
    else {return(false);}
  }

  function remove(address _addr) internal {
    for(uint k=0;k<unclaimed_bets.length;k++){
      if(unclaimed_bets[k]==_addr){
        if(!(k==unclaimed_bets.length-1)){unclaimed_bets[k]=unclaimed_bets[unclaimed_bets.length-1];}
        unclaimed_bets.pop();//is unclaimed_bets.length automatically updated????
        return;
      }
    }
    delete bet[_addr];
  }

  function removeByIndex(uint k) internal {
    address _addr=unclaimed_bets[k];
    if(!(k==unclaimed_bets.length-1)){unclaimed_bets[k]=unclaimed_bets[unclaimed_bets.length-1];}
    unclaimed_bets.pop();
    delete bet[_addr];
  }

  receive() external payable {
    deposit();//does this work? is msg.sender in the internal deposit call really the msg.sender or will the contract itself get the balance?
  }
}
