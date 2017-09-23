#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`

SOURCEDIR=`grep ^SOURCEDIR= settings.txt | sed "s/^.*=//"`

TOKENSOL=`grep ^TOKENSOL= settings.txt | sed "s/^.*=//"`
CROWDSALESOL=`grep ^CROWDSALESOL= settings.txt | sed "s/^.*=//"`
CROWDSALEJS=`grep ^CROWDSALEJS= settings.txt | sed "s/^.*=//"`

DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST2OUTPUT=`grep ^TEST2OUTPUT= settings.txt | sed "s/^.*=//"`
TEST2RESULTS=`grep ^TEST2RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

BLOCKSINDAY=10

if [ "$MODE" == "dev" ]; then
  # Start time now
  STARTTIME=`echo "$CURRENTTIME" | bc`
else
  # Start time 1m 10s in the future
  STARTTIME=`echo "$CURRENTTIME+90" | bc`
fi
STARTTIME_S=`date -r $STARTTIME -u`
ENDTIME=`echo "$CURRENTTIME+60*3" | bc`
ENDTIME_S=`date -r $ENDTIME -u`
VESTING1TIME=`echo "$CURRENTTIME+60*4" | bc`
VESTING1TIME_S=`date -r $VESTING1TIME -u`
VESTING2TIME=`echo "$CURRENTTIME+60*5" | bc`
VESTING2TIME_S=`date -r $VESTING2TIME -u`

printf "MODE            = '$MODE'\n" | tee $TEST2OUTPUT
printf "GETHATTACHPOINT = '$GETHATTACHPOINT'\n" | tee -a $TEST2OUTPUT
printf "PASSWORD        = '$PASSWORD'\n" | tee -a $TEST2OUTPUT
printf "SOURCEDIR       = '$SOURCEDIR'\n" | tee -a $TEST2OUTPUT
printf "TOKENSOL        = '$TOKENSOL'\n" | tee -a $TEST2OUTPUT
printf "CROWDSALESOL    = '$CROWDSALESOL'\n" | tee -a $TEST2OUTPUT
printf "CROWDSALEJS     = '$CROWDSALEJS'\n" | tee -a $TEST2OUTPUT
printf "DEPLOYMENTDATA  = '$DEPLOYMENTDATA'\n" | tee -a $TEST2OUTPUT
printf "INCLUDEJS       = '$INCLUDEJS'\n" | tee -a $TEST2OUTPUT
printf "TEST2OUTPUT     = '$TEST2OUTPUT'\n" | tee -a $TEST2OUTPUT
printf "TEST2RESULTS    = '$TEST2RESULTS'\n" | tee -a $TEST2OUTPUT
printf "CURRENTTIME     = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST2OUTPUT
printf "STARTTIME       = '$STARTTIME' '$STARTTIME_S'\n" | tee -a $TEST2OUTPUT
printf "ENDTIME         = '$ENDTIME' '$ENDTIME_S'\n" | tee -a $TEST2OUTPUT
printf "VESTING1TIME    = '$VESTING1TIME' '$VESTING1TIME_S'\n" | tee -a $TEST2OUTPUT
printf "VESTING2TIME    = '$VESTING2TIME' '$VESTING2TIME_S'\n" | tee -a $TEST2OUTPUT

# Make copy of SOL file and modify start and end times ---
`cp $SOURCEDIR/*.sol .`

# --- Modify parameters ---
`perl -pi -e "s/bool transferable/bool public transferable/" $TOKENSOL`
`perl -pi -e "s/MULTISIG_WALLET_ADDRESS \= 0xc79ab28c5c03f1e7fbef056167364e6782f9ff4f;/MULTISIG_WALLET_ADDRESS \= 0xa22AB8A9D641CE77e06D98b7D7065d324D3d6976;/" GimliCrowdsale.sol`
`perl -pi -e "s/START_DATE = 1505736000;.*$/START_DATE \= $STARTTIME; \/\/ $STARTTIME_S/" GimliCrowdsale.sol`
`perl -pi -e "s/END_DATE = 1508500800;.*$/END_DATE \= $ENDTIME; \/\/ $ENDTIME_S/" GimliCrowdsale.sol`
`perl -pi -e "s/VESTING_1_DATE = 1537272000;.*$/VESTING_1_DATE \= $VESTING1TIME; \/\/ $VESTING1TIME_S/" GimliCrowdsale.sol`
`perl -pi -e "s/VESTING_2_DATE = 1568808000;.*$/VESTING_2_DATE \= $VESTING2TIME; \/\/ $VESTING2TIME_S/" GimliCrowdsale.sol`

DIFFS1=`diff $SOURCEDIR/$TOKENSOL $TOKENSOL`
echo "--- Differences $SOURCEDIR/$TOKENSOL $TOKENSOL ---" | tee -a $TEST2OUTPUT
echo "$DIFFS1" | tee -a $TEST2OUTPUT

DIFFS1=`diff $SOURCEDIR/GimliCrowdsale.sol GimliCrowdsale.sol`
echo "--- Differences $SOURCEDIR/GimliCrowdsale.sol GimliCrowdsale.sol ---" | tee -a $TEST2OUTPUT
echo "$DIFFS1" | tee -a $TEST2OUTPUT

DIFFS1=`diff $SOURCEDIR/$CROWDSALESOL $CROWDSALESOL`
echo "--- Differences $SOURCEDIR/$CROWDSALESOL $CROWDSALESOL ---" | tee -a $TEST2OUTPUT
echo "$DIFFS1" | tee -a $TEST2OUTPUT

echo "var tokenOutput=`solc --optimize --combined-json abi,bin,interface $CROWDSALESOL`;" > $CROWDSALEJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST2OUTPUT
loadScript("$CROWDSALEJS");
loadScript("functions.js");

var tokenAbi = JSON.parse(tokenOutput.contracts["$CROWDSALESOL:Gimli"].abi);
var tokenBin = "0x" + tokenOutput.contracts["$CROWDSALESOL:Gimli"].bin;

// console.log("DATA: tokenAbi=" + JSON.stringify(tokenAbi));
// console.log("DATA: tokenBin=" + JSON.stringify(tokenBin));

unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var tokenMessage = "Deploy Crowdsale/Token Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: " + tokenMessage);
var tokenContract = web3.eth.contract(tokenAbi);
// console.log(JSON.stringify(tokenContract));
var tokenTx = null;
var tokenAddress = null;

var token = tokenContract.new({from: contractOwnerAccount, data: tokenBin, gas: 6000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenTx = contract.transactionHash;
      } else {
        tokenAddress = contract.address;
        addAccount(tokenAddress, "Token '" + token.symbol() + "' '" + token.name() + "'");
        addTokenContractAddressAndAbi(tokenAddress, tokenAbi);
        console.log("DATA: tokenAddress=" + tokenAddress);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

printTxData("tokenAddress=" + tokenAddress, tokenTx);
printBalances();
failIfGasEqualsGasUsed(tokenTx, tokenMessage);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var preAllocMessage = "Add Preallocations";
// -----------------------------------------------------------------------------
console.log("RESULT: " + preAllocMessage);
var preAlloc1Tx = token.preAllocate(account3, "100000000000", web3.toWei("10", "ether"), {from: contractOwnerAccount, gas: 400000});
var preAlloc2Tx = token.preAllocate(account4, "1000000000000", web3.toWei("100", "ether"), {from: contractOwnerAccount, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("preAlloc1Tx", preAlloc1Tx);
printTxData("preAlloc2Tx", preAlloc2Tx);
printBalances();
failIfGasEqualsGasUsed(preAlloc1Tx, preAllocMessage + " - ac3 1,000 GIM");
failIfGasEqualsGasUsed(preAlloc2Tx, preAllocMessage + " - ac4 10,000 GIM");
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait for crowdsale start
// -----------------------------------------------------------------------------
var startTime = parseInt(token.START_DATE()) + 1;
var startTimeDate = new Date(startTime * 1000);
console.log("RESULT: Waiting until start date at " + startTime + " " + startTimeDate + " currentDate=" + new Date());
while ((new Date()).getTime() <= startTimeDate.getTime()) {
}
console.log("RESULT: Waited until start date at " + startTime + " " + startTimeDate + " currentDate=" + new Date());


// -----------------------------------------------------------------------------
var sendContribution1Message = "Send Contribution";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution1Message);
var sendContribution1Tx = eth.sendTransaction({from: account5, to: tokenAddress, gas: 400000, value: web3.toWei("114270", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("sendContribution1Tx", sendContribution1Tx);
printBalances();
failIfGasEqualsGasUsed(sendContribution1Tx, sendContribution1Message + " - ac5 114,270 ETH = 80,000,000 GIM");
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait for crowdsale end
// -----------------------------------------------------------------------------
// var endTime = parseInt(token.END_DATE()) + 1;
// var endTimeDate = new Date(endTime * 1000);
// console.log("RESULT: Waiting until end date at " + endTime + " " + endTimeDate + " currentDate=" + new Date());
// while ((new Date()).getTime() <= endTimeDate.getTime()) {
// }
// console.log("RESULT: Waited until end date at " + endTime + " " + endTimeDate + " currentDate=" + new Date());


// -----------------------------------------------------------------------------
var closeCrowdsaleMessage = "Close Crowdsale Early";
// -----------------------------------------------------------------------------
console.log("RESULT: " + closeCrowdsaleMessage);
var closeCrowdsaleTx = token.closeCrowdsale({from: contractOwnerAccount, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("closeCrowdsaleTx", closeCrowdsaleTx);
printBalances();
failIfGasEqualsGasUsed(closeCrowdsaleTx, closeCrowdsaleMessage);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var moveTokenMessage = "Move Tokens After Crowdsale Finalised";
// -----------------------------------------------------------------------------
console.log("RESULT: " + moveTokenMessage);
var moveToken1Tx = token.transfer(account6, "100000000", {from: account4, gas: 100000});
var moveToken2Tx = token.approve(account7,  "300000000", {from: account5, gas: 100000});
while (txpool.status.pending > 0) {
}
var moveToken3Tx = token.transferFrom(account5, account8, "300000000", {from: account7, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("moveToken1Tx", moveToken1Tx);
printTxData("moveToken2Tx", moveToken2Tx);
printTxData("moveToken3Tx", moveToken3Tx);
printBalances();
failIfGasEqualsGasUsed(moveToken1Tx, moveTokenMessage + " - transfer 1 GIM ac4 -> ac6. CHECK for movement");
failIfGasEqualsGasUsed(moveToken2Tx, moveTokenMessage + " - approve 3 GIM ac5 -> ac7");
failIfGasEqualsGasUsed(moveToken3Tx, moveTokenMessage + " - transferFrom 3 GIM ac5 -> ac8 by ac7. CHECK for movement");
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait for vesting period 1 end
// -----------------------------------------------------------------------------
var vesting1EndTime = parseInt(token.VESTING_1_DATE()) + 1;
var vesting1EndTimeDate = new Date(vesting1EndTime * 1000);
console.log("RESULT: Waiting until vesting period 1 end date at " + vesting1EndTime + " " + vesting1EndTimeDate + " currentDate=" + new Date());
while ((new Date()).getTime() <= vesting1EndTimeDate.getTime()) {
}
console.log("RESULT: Waited until vesting period 1 end date at " + vesting1EndTime + " " + vesting1EndTimeDate + " currentDate=" + new Date());


// -----------------------------------------------------------------------------
var releaseVesting1Message = "Release Vesting 1 Tokens To Account 9";
// -----------------------------------------------------------------------------
console.log("RESULT: " + releaseVesting1Message);
var releaseVesting1Tx = token.releaseVesting(account9, {from: contractOwnerAccount, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("releaseVesting1Tx", releaseVesting1Tx);
printBalances();
failIfGasEqualsGasUsed(releaseVesting1Tx, releaseVesting1Message);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait for vesting period 2 end
// -----------------------------------------------------------------------------
var vesting2EndTime = parseInt(token.VESTING_2_DATE()) + 1;
var vesting2EndTimeDate = new Date(vesting2EndTime * 1000);
console.log("RESULT: Waiting until vesting period 2 end date at " + vesting2EndTime + " " + vesting2EndTimeDate + " currentDate=" + new Date());
while ((new Date()).getTime() <= vesting2EndTimeDate.getTime()) {
}
console.log("RESULT: Waited until vesting period 2 end date at " + vesting2EndTime + " " + vesting2EndTimeDate + " currentDate=" + new Date());


// -----------------------------------------------------------------------------
var releaseVesting2Message = "Release Vesting 2 Tokens To Account 10";
// -----------------------------------------------------------------------------
console.log("RESULT: " + releaseVesting2Message);
var releaseVesting2Tx = token.releaseVesting(account10, {from: contractOwnerAccount, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("releaseVesting2Tx", releaseVesting2Tx);
printBalances();
failIfGasEqualsGasUsed(releaseVesting2Tx, releaseVesting2Message);
printTokenContractDetails();
console.log("RESULT: ");


EOF
grep "DATA: " $TEST2OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST2OUTPUT | sed "s/RESULT: //" > $TEST2RESULTS
cat $TEST2RESULTS
