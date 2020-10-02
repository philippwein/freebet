var web3 = new Web3(Web3.givenProvider);
var contractInstance;
var account;
var blocknr=0;


$(document).ready(function() {
    window.ethereum.enable().then(function(accounts){
      account=accounts[0];
      contractInstance = new web3.eth.Contract(abi,contractAddress);
      console.log(contractInstance);
      $("#place_bet_button").click(placeBet);
      $("#claim_bet_button").click(claimBet);
      $("#get_data_button").click(getData);
      $("#get_balance_data_button").click(getDataBalance);
      $("#provide_liquidity_button").click(deposit);claim_lost_in_time_button
      $("#withdraw_liquidity_button").click(withdraw);
      $("#claim_lost_in_time_button").click(claimLostInTime);
    });
});


function placeBet(){
  var amount = web3.utils.toWei(parseFloat($("#bet_amount_input").val()).toString(),"ether");
  console.log(amount);
  contractInstance.methods.placeBet().send({value:amount,from:account})
  .then(function(receipt){
    blocknr=receipt["blockNumber"];
    console.log(blocknr);
    console.log(receipt);
  });
}

function claimBet(){
  web3.eth.getBlockNumber(function(error, currentBlocknr){
    if (!error && blocknr!=0 && currentBlocknr>blocknr+1){
      console.log("stored bet blocknr:", blocknr);
      console.log("current blockNumber:", currentBlocknr);
      contractInstance.methods.claimBet().send({value:"0",from:account})
      .on("receipt", function(receipt){
        if(receipt["status"]){
          console.log("Claim successful");
          blocknr=0;
        }
      });
    }
  });
}

function withdraw(){
  var amount = web3.utils.toWei(parseFloat($("#withdraw_amount_input").val()).toString(),"ether");
  contractInstance.methods.withdraw(amount).send({value:"0",from:account})
  .on("receipt", function(receipt){
    console.log(receipt);
  });
}

function deposit(){
  var amount = web3.utils.toWei(parseFloat($("#deposit_amount_input").val()).toString(),"ether");
  console.log(amount);
  contractInstance.methods.deposit().send({value:amount,from:account})
  .on("receipt", function(receipt){
    console.log(receipt);
  });
}

function getData(){
  console.log("stored bet blocknr:", blocknr);
  web3.eth.getBlockNumber(function(error, currentBlocknr){
    if (!error){
      console.log("current blockNumber:", currentBlocknr);
      if(blocknr==0){$("#bet_status_output").text("No bet yet");return;}
      else if(currentBlocknr<=blocknr+1){$("#bet_status_output").text("No result yet");return;}
      contractInstance.methods.won().call({from:account}).then(function(won){
        console.log(won);
        if(won){$("#bet_status_output").text("You won");}
        if(!won){$("#bet_status_output").text("You lost");}
      });
    }
  });
}

function getDataBalance(){
  contractInstance.methods.getMyBalance().call({from:account}).then(function(balance){
    console.log(balance);
    $("#deposit_output").text(web3.utils.fromWei(balance));
  });
  contractInstance.methods.getMyMaxWithdrawal().call({from:account}).then(function(maxwithdraw){
    console.log(maxwithdraw);
    $("#maxwithdraw_output").text(web3.utils.fromWei(maxwithdraw));
  });
}

function claimLostInTime(){
  contractInstance.methods.claimLostInTime().send({value:"0",from:account})
    .then(function(receipt){
    if(receipt["status"]){
      console.log("Claim successful");
    }
  });
}
