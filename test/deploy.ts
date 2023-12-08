import {
	MossHub
} from '../types'
import { Signer } from 'ethers'
import { ethers } from 'hardhat'

interface Deployment {
	signers: Signer[]
	signer: Signer
	account: string
	MossHub: MossHub
}

async function deploy(): Promise<Deployment> {
	const signers = await ethers.getSigners()
	const signer = signers[0]

	const account = await signer.getAddress()
	const dev = account
	const proxyAdmin = await ethers.deployContract('ProxyAdmin', signer)
	const NFTDescriptor = await ethers.deployContract('NFTDescriptor', signer)
	const MossHubImp = await ethers.deployContract('MossHub', { libraries: { NFTDescriptor: NFTDescriptor.target }, signer })
	const data = MossHubImp.interface.encodeFunctionData('initialize', [dev])
	const proxy = await ethers.deployContract('TransparentUpgradeableProxy', [MossHubImp.target, proxyAdmin.target, data], signer)
	const MossHub = MossHubImp.attach(proxy.target) as MossHub
	return {
		signers,
		signer,
		account,
		MossHub
	}
}

export {
	deploy,
	Deployment
}