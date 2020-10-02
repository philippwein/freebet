const FREE_BET = artifacts.require("FREE_BET");
const truffleAssert = require("truffle-assertions");

contract("FREE_BET", async function(){
  it("should handle simple deposits correctly",async function(){
    let balance;
    let instance = await FREE_BET.deployed();
    await instance.deposit({value: web3.utils.toWei("1", "ether" )});
    balance = parseFloat(await instance.getMyBalance());
    assert(balance==web3.utils.toWei("1", "ether" ));
    await instance.deposit({value: web3.utils.toWei("2", "ether" )});
    balance = parseFloat(await instance.getMyBalance());
    assert(balance==web3.utils.toWei("3", "ether" ));
  });
  it("should handle simple withdrawals correctly",async function(){
    let balance;
    let instance = await FREE_BET.deployed();
    await instance.withdraw(web3.utils.toWei("3", "ether" ));
    balance = parseFloat(await instance.getMyBalance());
    assert(balance==0);
  });
});
