$ npm install -g @project-serum/anchor-cli
$ anchor init skydive_coin
$ cd skydive_coin
[package]
name = "skydive_coin"
version = "0.1.0"
edition = "2018"

[dependencies]
anchor-lang = "0.10.0"
use anchor_lang::prelude::*;

declare_id!("Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkgAAoh8XxKkY");

#[program]
mod skydive_coin {
    use super::*;
    pub fn initialize(ctx: Context<Initialize>, initial_supply: u64) -> ProgramResult {
        let skydive_coin = &mut ctx.accounts.skydive_coin;
        skydive_coin.total_supply = initial_supply;
        skydive_coin.balance = initial_supply;
        Ok(())
    }
    
    pub fn mint(ctx: Context<Mint>, amount: u64) -> ProgramResult {
        let skydive_coin = &mut ctx.accounts.skydive_coin;
        skydive_coin.balance += amount;
        Ok(())
    }
}

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(init, payer = user, space = 8 + 8)]
    pub skydive_coin: Account<'info, SkydiveCoin>,
    #[account(mut)]
    pub user: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct Mint<'info> {
    #[account(mut)]
    pub skydive_coin: Account<'info, SkydiveCoin>,
    #[account(mut)]
    pub user: Signer<'info>,
}

#[account]
pub struct SkydiveCoin {
    pub total_supply: u64,
    pub balance: u64,
}
$ anchor build
$ anchor deploy --provider.cluster devnet
import { create } from 'ipfs-http-client';

const ipfs = create({ host: 'ipfs.infura.io', port: 5001, protocol: 'https' });

export async function uploadToIPFS(file) {
    const result = await ipfs.add(file);
    return `https://ipfs.infura.io/ipfs/${result.path}`;
}

export async function createNFTMetadata(name, description, imageFile) {
    const imageUrl = await uploadToIPFS(imageFile);
    const metadata = { name, description, image: imageUrl };
    const metadataHash = await ipfs.add(JSON.stringify(metadata));
    return `https://ipfs.infura.io/ipfs/${metadataHash.path}`;
}
$ npx create-react-app skydive-casino
$ cd skydive-casino
$ npm install @solana/web3.js @solana/wallet-adapter-react @solana/wallet-adapter-react-ui ipfs-http-client
import React, { useState, useEffect } from 'react';
import { Connection, PublicKey, clusterApiUrl, LAMPORTS_PER_SOL } from '@solana/web3.js';
import { useWallet, WalletProvider, ConnectionProvider } from '@solana/wallet-adapter-react';
import { WalletModalProvider, WalletDisconnectButton, WalletMultiButton } from '@solana/wallet-adapter-react-ui';
import { createNFTMetadata } from './ipfs';

const connection = new Connection(clusterApiUrl('devnet'), 'confirmed');
const programID = new PublicKey('YourProgramID');

function App() {
    const { publicKey, sendTransaction } = useWallet();
    const [balance, setBalance] = useState(0);
    const [nftImages, setNftImages] = useState([]);
    const [name, setName] = useState('');
    const [description, setDescription] = useState('');
    const [file, setFile] = useState(null);

    useEffect(() => {
        const fetchBalance = async () => {
            if (publicKey) {
                const balance = await connection.getBalance(publicKey);
                setBalance(balance / LAMPORTS_PER_SOL);
            }
        };
        fetchBalance();
    }, [publicKey]);

    const playSlot = async () => {
        // Implement playSlot logic using Solana transactions
    };

    const handleUpload = async () => {
        if (name && description && file) {
            const metadataURL = await createNFTMetadata(name, description, file);
            console.log('Metadata URL:', metadataURL);
        }
    };

    return (
        <div className="App">
            <h1>Welcome to Skydive NFT Casino</h1>
            <WalletMultiButton />
            <WalletDisconnectButton />
            {publicKey && <p>Balance: {balance} SOL</p>}
            <button onClick={playSlot}>Play Slot</button>
            <div>
                <h2>Your NFTs</h2>
                <div className="nft-gallery">
                    {nftImages.map((image, index) => (
                        <img key={index} src={image} alt={`NFT ${index + 1}`} />
                    ))}
                </div>
            </div>
            <div>
                <h2>Upload NFT</h2>
                <input type="text" placeholder="Name" value={name} onChange={(e) => setName(e.target.value)} />
                <input type="text" placeholder="Description" value={description} onChange={(e) => setDescription(e.target.value)} />
                <input type="file" onChange={(e) => setFile(e.target.files[0])} />
                <button onClick={handleUpload}>Upload</button>
            </div>
        </div>
    );
}

export default function AppWithProviders() {
    return (
        <ConnectionProvider endpoint={clusterApiUrl('devnet')}>
            <WalletProvider wallets={[]} autoConnect>
                <WalletModalProvider>
                    <App />
                </WalletModalProvider>
            </WalletProvider>
        </ConnectionProvider>
    );
}
/* Add this to App.css or a new CSS file */
.nft-gallery img {
    width: 100px;
    height: 100px;
    margin: 10px;
}
const express = require('express');
const IPFS = require('ipfs-http-client');
const app = express();

const ipfs = IPFS.create({ host: 'ipfs.infura.io', port: 5001, protocol: 'https' });

app.use(express.json());

app.post('/uploadNFT', async (req, res) => {
    try {
        const { name, description, imageFile } = req.body;
        const imageUrl = await uploadToIPFS(imageFile);
        const metadata = { name, description, image: imageUrl };
        const metadataHash = await ipfs.add(JSON.stringify(metadata));
        res.json({ url: `https://ipfs.infura.io/ipfs/${metadataHash.path}` });
    } catch (error) {
        res.status(500).send(error.toString());
    }
});

async function uploadToIPFS(data) {
    const transaction = await ipfs.add(data);
    return `https://ipfs.infura.io/ipfs/${transaction.path}`;
}

app.listen(3000, () => {
    console.log('Server running on port 3000');
});
$ git add .
$ git commit -m "Initial commit"
$ git push origin main