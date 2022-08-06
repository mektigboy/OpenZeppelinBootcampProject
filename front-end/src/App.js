import "./App.css";
import contractABI from "../../back-end/deployments/rinkeby/AbitoRandomNFTGenerator.json";
import { ethers, BigNumber } from "ethers";
import { useEffect, useState } from "react";

const contractAddress = "0xc85ed190568E1542c9cb2f917bE383335716DE32"; // Address of the deployed contract.

function App() {
  const [data, setData] = useState({
    address: "",
    Balance: null,
  });

  const connectHandler = () => {
    // Metamask?
    if (window.ethereum) {
      // Fetch first address.
      window.ethereum
        .request({ method: "eth_requestAccounts" })
        .then((response) => accountChangeHandler(response[0]));
    } else {
      alert("you have to install metamask extension.");
    }
  };

  const getBalance = (address) => {
    // Request balance method.
    window.ethereum
      .request({
        method: "eth_getBalance",
        params: [address, "latest"],
      })
      .then((balance) => {
        // Set balance.
        setData({
          Balance: ethers.utils.formatEther(balance),
        });
      });
  };

  const accountChangeHandler = (account) => {
    // Set and address data.
    setData({
      address: account,
    });

    // Set a balance.
    getBalance(account);
  };

  // // Mint:

  // const [mintAmount, setMintAmount] = useState(1);

  // async function handleMint() {
  //   if (window.ethereum) {
  //     const provider = new ethers.providers.Web3Provider(window.ethereum);
  //     const signer = provider.getSigner();
  //     const contract = new ethers.Contract(
  //       contractAddress,
  //       contractABI.abi,
  //       signer
  //     );

  //     try {
  //       const response = await contract.mint(BigNumber.from(mintAmount)); // Change to name of the function.
  //       console.log("response: ", response);
  //     } catch (error) {
  //       console.log(error);
  //     }
  //   }
  // }

  return (
    <div className="App">
      <div className="box">
        <div className="top">
          openzeppelin bootcamp project
          <a onClick={connectHandler}>connect wallet</a>
        </div>
        <div className="middle">
          <div className="buttons">
            <button className="margin-right">access whitelist</button>
            <button onClick={connectHandler}>mint</button>
          </div>
        </div>
        <div className="bottom">
          <div>copyright © 2022 - team one.</div>
          <div className="links">
            <a href="" className="margin-right">
              contract address
            </a>
            <div className="margin-right">/</div>
            <a href="https://github.com/mektigboy/OpenZeppelinBootcampProject">
              github
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
