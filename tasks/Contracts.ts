import '@nomicfoundation/hardhat-ethers'
import 'hardhat-deploy'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import {
	ProxyAdmin__factory,
	MossHub__factory
} from '../types'

export const ProxyAdmin = async (env: HardhatRuntimeEnvironment) => {
	const signers = await env.ethers.getSigners()
	const deployment = await env.deployments.get('ProxyAdmin_Proxy')
	return ProxyAdmin__factory.connect(deployment.address, signers[0])
}

export const MossHub = async (env: HardhatRuntimeEnvironment) => {
	const signers = await env.ethers.getSigners()
	const deployment = await env.deployments.get('MossHub_Proxy')
	return MossHub__factory.connect(deployment.address, signers[0])
}
