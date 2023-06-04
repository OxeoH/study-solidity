// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MerkleTree{
    bytes32[] public hashes;
    string[4] public transactions = [
        "TX1: 1 -> 2",
        "TX2: 1 -> 3",
        "TX3: 1 -> 4",
        "TX4: 1 -> 5"
    ];
    
    constructor(){
        for(uint i = 0; i < transactions.length; i++){
            hashes.push(makeTxHash(transactions[i]));
        }

        uint offset = 0;
        uint count = transactions.length;

        while(count > 0){
            for(uint i = 0; i < count - 1; i += 2){
                hashes.push(
                    keccak256(abi.encodePacked(hashes[offset + i], hashes[offset + i + 1]))
                );
            }
            offset += count;
            count /= 2;
        }
    }

    function makeTxHash(string memory txInput) public pure returns(bytes32){
        return keccak256(abi.encodePacked(txInput));
    }
    //"TX3: 1 -> 4" 
    // 2
    //root : 0x3b692b9b6387aec24235451c1f4a6e60a3607dbfd8b99c165f2c012bb35c404e
    // [0x77673385e55a47116109530db90c019bcce6ab54de78a64d5a80367f52310f21, 0x76ae9b6ee8d6182bf99e18b10b765d211479df4cf25e1340440593db46904896]

    function verify(string memory transaction, uint txIndex, bytes32 rootHash, bytes32[] memory proofHashes) public pure returns(bool){
        bytes32 txHash = makeTxHash(transaction);

        for (uint i = 0; i < proofHashes.length; i++) 
        {
            bytes32 element = proofHashes[i];
            if(txIndex % 2 == 0){
                txHash = keccak256(abi.encodePacked(txHash, element));
            }else{
                txHash = keccak256(abi.encodePacked(element, txHash));
            }

            txIndex /= 2;
        }

        return rootHash == txHash;
    }
}