import {
	MossHub,
	MossSquare,
	Helpers
} from '../types'
import { Signer } from 'ethers'
import { ethers } from 'hardhat'

interface Deployment {
	signers: Signer[]
	signer: Signer
	account: string
	MossHub: MossHub
	helpers: Helpers
	MossSquare: MossSquare
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

	const MossSquareImp = await ethers.deployContract('MossSquare', signer)
	const MossSquaredata = MossSquareImp.interface.encodeFunctionData('initialize', [dev])
	const MossSquareproxy = await ethers.deployContract('TransparentUpgradeableProxy', [MossSquareImp.target, proxyAdmin.target, MossSquaredata], signer)
	const MossSquare = MossSquareImp.attach(MossSquareproxy.target) as MossSquare
	return {
		signers,
		signer,
		account,
		MossHub,
		MossSquare,
		helpers
	}
}

export {
	deploy,
	Deployment
}