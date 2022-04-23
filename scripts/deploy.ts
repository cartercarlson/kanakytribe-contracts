import fs from "fs";
import config from "./config";
import { network, run, ethers } from "hardhat";
import { deploy, verifyContract } from "./utils";
import { KanakyTribe } from "../artifacts/types/KanakyTribe";

async function main() {
    let [deployer] = await ethers.getSigners();

    const ANDY = "0xa18E80BC6c15Dc48C98aC166d350472CfeC72520";
    const ANDY_PCT = 200;
    const CARTER = "0x00000000005dbcB0d0513FcDa746382Fe8a53468";
    const CARTER_PCT = 500;
    const CLASSY = "0x90697c268D9619cAc787C16a35e6Ddf98f1389AE";
    const CLASSY_PCT = 500;
    const FREEFLOW = "0x5B588e36FF358D4376A76FB163fd69Da02A2A9a5";
    const FREEFLOW_PCT = 75;
    const JRC = "0x30FEC548460301c704615357219d1005217c9564";
    const JRC_PCT = 100;
    const NICK = "0"; // TODO
    const NICK_PCT = 500;
    const SKULL = "0xA18050f3688Eb81eA134B04ed822126785aC9FE2";
    const SKULL_PCT = 1000;
    const SOULESS = "0x816B45b48B6263d015eA4ac292B04942Ac6a81B8";
    const SOULESS_PCT = 1000;
    const VICKY = "0xC35262CDc121654Df27B663412468b76Fc6eF11F";
    const VICKY_PCT = 100;
    const shareholders = [
        ANDY,
        CARTER,
        CLASSY,
        FREEFLOW,
        JRC,
        NICK,
        SKULL,
        SOULESS,
        VICKY
    ];
    const shares = [
        ANDY_PCT,
        CARTER_PCT,
        CLASSY_PCT,
        FREEFLOW_PCT,
        JRC_PCT,
        NICK_PCT,
        SKULL_PCT,
        SOULESS_PCT,
        VICKY_PCT
    ];
}