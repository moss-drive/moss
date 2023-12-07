import '@nomicfoundation/hardhat-ethers'
import { HDNodeWallet, Wallet } from 'ethers'
import 'hardhat-deploy'

import { task } from 'hardhat/config'
import { HardhatRuntimeEnvironment } from 'hardhat/types'

task('deploy:contract')
	.addParam('n')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const name = args.n
		const { deployments, getNamedAccounts } = env
		const { deploy } = deployments
		console.log('start deploy:', name)
		const { deployer } = await getNamedAccounts()
		const res = await deploy(name, {
			from: deployer,
			log: true,
		})
		console.log('deploy completed:', res.receipt)
	})

module.exports = {}