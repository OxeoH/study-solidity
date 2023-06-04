import { expect } from "chai";
import { ethers } from "hardhat";
import { Provider } from "@ethersproject/abstract-provider";
import { Signer } from "ethers";
import { ModStudy } from "../typechain-types";

describe("ModStudy", function () {
  let owner: Signer;
  let otherAcc: Signer;
  let modStudy: ModStudy;
  this.beforeEach(async function () {
    [owner, otherAcc] = await ethers.getSigners();
    const ModStudy = await ethers.getContractFactory("ModStudy", owner);
    modStudy = await ModStudy.deploy();
    await modStudy.deployed();
    console.log("Contract address: ", modStudy.address);
  });

  async function sendMoney(sender: Signer) {
    const amount = 1000;
    const txData = {
      to: modStudy.address,
      value: amount,
    };
    const tx = await sender.sendTransaction(txData);
    await tx.wait();
    return [tx, amount];
  }

  it("should allow to send money", async function () {
    const [tx, amount] = await sendMoney(otherAcc);
    console.log(tx);

    await expect(() => tx).to.changeEtherBalance(modStudy, amount);

    if (typeof tx !== "number") {
      await expect(tx)
        .to.emit(modStudy, "Paid")
        .withArgs(
          await otherAcc.getAddress(),
          amount,
          (
            await ethers.provider.getBlock(tx.blockNumber!)
          ).timestamp
        );
    }
  });

  it("should allow owner to withdraw funds", async function () {
    const [_, amount] = await sendMoney(otherAcc);

    const tx = await modStudy.withdraw(await owner.getAddress());

    await expect(() => tx).to.changeEtherBalances(
      [owner, modStudy.address],
      [amount, -amount]
    );
  });

  // ??????????????????????
  //   it("should not allow other account to withdraw funds", async function () {
  //     await sendMoney(otherAcc);

  //     const tx = await modStudy
  //       .connect(otherAcc)
  //       .withdraw(await otherAcc.getAddress());

  //     await expect(() => tx).to.be.revertedWith("Error: You are not an Owner!");
  //   });
});
