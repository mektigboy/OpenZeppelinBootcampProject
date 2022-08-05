import "./App.css";
import contractABI from "./RandomNFTGenerator.json";
import { ethers, BigNumber } from "ethers";
import { useEffect, useState } from "react";

const contractAddress = "0x74eA74c0d471ACB88e979b1c6C24B2dE9F7ac4d3"; // Address of the deployed contract.

function App() {
  // Connect:

  const [accounts, setAccounts] = useState([]);

  async function connectAccounts() {
    if (window.ethereum) {
      const accounts = await window.ethereum.request({
        method: "eth_requestAccounts",
      });
      setAccounts(accounts);
    }
  }

  useEffect(() => {
    connectAccounts();
  }, []);

  // Mint:

  const [mintAmount, setMintAmount] = useState(1);

  async function handleMint() {
    if (window.ethereum) {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(
        contractAddress,
        contractABI.abi,
        signer
      );

      try {
        const response = await contract.mint(BigNumber.from(mintAmount)); // Change to name of the function.
        console.log("response: ", response);
      } catch (error) {
        console.log(error);
      }
    }
  }

  return (
    <div className="App">
      {accounts.length && (
        <div>
          <button onClick={() => setMintAmount(mintAmount - 1)}>-</button>
          {mintAmount}
          <button onClick={() => setMintAmount(mintAmount + 1)}>+</button>
          <button onClick={handleMint}>Mint</button>
        </div>
      )}
    </div>
  );
}

export default App;
