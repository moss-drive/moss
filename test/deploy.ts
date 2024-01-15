import {
	MossHub,
	MossBeta,
	Helpers
} from '../types'
import { Signer } from 'ethers'
import { ethers } from 'hardhat'

interface Deployment {
	signers: Signer[]
	signer: Signer
	account: string
	MossHub: MossHub
	MossBeta: MossBeta
	helpers: Helpers
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
	const helpers = await ethers.deployContract('Helpers', [MossHub.target], signer)
	const MossBetaImp = await ethers.deployContract('MossBeta', signer)
	const MossBetaData = MossBetaImp.interface.encodeFunctionData('initialize', [dev])
	const MossBetaProxy = await ethers.deployContract('TransparentUpgradeableProxy', [MossBetaImp.target, proxyAdmin.target, MossBetaData], signer)
	const MossBeta = MossBetaImp.attach(MossBetaProxy.target) as MossBeta
	return {
		signers,
		signer,
		account,
		MossHub,
		MossBeta,
		helpers
	}
}

export {
	deploy,
	Deployment
}