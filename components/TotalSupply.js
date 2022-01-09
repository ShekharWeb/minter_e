import { useEffect, useState } from 'react'
import { ethers } from 'ethers'
import { hasEthereum, requestAccount } from '../utils/ethereum'
import Minter from '../src/abi/NftJson.json'

export default function TotalSupply() {
    // UI state
    const [loading, setLoading] = useState(true)
    const [totalMinted, setTotalMinted] = useState(0)
    const [totalValue, setTotalValue] = useState(0)

    const contractAddress = "0x73F5c026a16777Ca435E79242634ac28215C91e4";


    // Constants
    const TOTAL = 10000;

    useEffect( function() {
        async function fetchTotals() {
            if(! hasEthereum()) {
                console.log('Install MetaMask')
                setLoading(false)
                return
            }
    
            await getTotalSupply()
            await getTotalValue()
        
            setLoading(false)
        }
        fetchTotals();
    });

    // Get total supply of tokens from smart contract
    async function getTotalSupply() {
        try {
          // Interact with contract
          const provider = new ethers.providers.Web3Provider(window.ethereum)
          const contract = new ethers.Contract(contractAddress, Minter.abi, provider)
          const data = await contract.totalSupply() 
      
          setTotalMinted(data.toNumber());
        } catch(error) {
            console.log(error)
        }
    }

     // Get total value collected by the smart contract
     async function getTotalValue() {
        try {
          // Interact with contract
          const provider = new ethers.providers.Web3Provider(window.ethereum)
        //   const contract = new ethers.Contract(contractAddress, Minter.abi, provider)
        //   const data = await contract.mintPrice()
            const data = await provider.getBalance(contractAddress);
          setTotalValue(ethers.utils.formatEther(data).toString());
        } catch(error) {
            console.log(error)
        }
    }

    return (
        <>
            <p>
                Tokens minted: { loading ? 'Loading...' : `${totalMinted}/${TOTAL}` }<br />
                Contract value: { loading ? 'Loading...' : `${totalValue}ETH` }
            </p>
        </>
    )
}