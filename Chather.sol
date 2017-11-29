pragma solidity ^0.4.11;

contract Chather {

	event MessageSent(address from, address to, uint64 messageId);
	event Withdrawn(address from, address to, uint wai);

   //in Wei
	uint80 public fee;

	address public owner = msg.sender;
	uint public creationTime = now;

	struct Message {
		address from;
		address to;
		uint blockNumber;
		bytes32 messageHash;
	}

	mapping (uint64 => Message) Messages;

	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}

	function Chather(uint80 initFee) {
		fee = initFee;
	}

	function getMessageById(uint64 id) public constant returns(uint, address, address,bytes32 ) {

		Message memory message = Messages[id];
		return (message.blockNumber, message.from, message.to, message.messageHash);
	}

	function checkMessage(uint64 id, address from, address to) returns (bool result) {
		if(Messages[id].blockNumber == 0)
			return false;
		
		return Messages[id].from == from && Messages[id].to == to;
	}
	
	function changeFee(uint80 newFee) onlyOwner {
		fee = newFee;
	}


	function withdraw(address reciver, uint96 wai) onlyOwner {
		reciver.transfer(wai);
		Withdrawn(msg.sender, reciver, wai);
	}
	

	function sendMessage(address receiver,bytes32 messageHash, uint64 id) payable returns (bool result) {
		
		require( msg.value >= fee && Messages[id].blockNumber == 0);
		
		Messages[id] = Message({
			messageHash: messageHash,
			from: msg.sender,
			to:receiver,
			blockNumber:block.number	
		});	

		MessageSent(msg.sender, receiver,id);
		return true;	
	   
	}
}