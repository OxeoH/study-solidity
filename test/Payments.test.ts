import { expect } from "chai";
import { ethers } from "hardhat";
import { Payments } from "../typechain-types";
import { Provider } from "@ethersproject/abstract-provider";
import { Signer } from "ethers";

describe("Payments", function () {
  let acc1: Signer;
  let acc2: Signer;
  let payments: Payments;
  this.beforeEach(async function () {
    [acc1, acc2] = await ethers.getSigners();
    const Payments = await ethers.getContractFactory("Payments", acc1);
    payments = await Payments.deploy();
    await payments.deployed();
    console.log("Contract address: ", payments.address);
  });

  it("should be deployed", async function () {
    expect(payments.address).to.be.properAddress;
  });

  it("should have 0 on balance by default", async function () {
    const balance = await payments.getCurrentBalance();
    expect(balance).equals(0);
  });

  it("it should be possible to send funds", async function () {
    const tx = await payments
      .connect(acc2)
      .pay("Hello hardhat!", { value: 1000 });

    await expect(() => tx).to.changeEtherBalances(
      [acc2, payments],
      [-1000, 1000]
    );

    await tx.wait();

    const senderAddress = await acc2.getAddress();

    const newPayment = await payments.getPayment(senderAddress, 0);
    expect(newPayment.amount).to.eq(1000);
    expect(newPayment.message).to.eq("Hello hardhat!");
    expect(newPayment.from).to.eq(senderAddress);
  });
});
