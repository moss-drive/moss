import '@nomicfoundation/hardhat-ethers'
import 'hardhat-deploy'

import { task } from 'hardhat/config'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import {
	ProxyAdmin
} from './Contracts'

task('ProxyAdmin:upgrade:MossHub')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const admin = await ProxyAdmin(env)
		const proxy = '0x8a6569e85c97a1Bbe2d4Ea539a0C9C873c5f55FE'
		const imp = '0xe9940ACe86b1B857D3a59Ab0C9b09039ba0ad9fa'
		const tx = await admin.upgrade(proxy, imp)
		console.log('tx', tx)
		const receipt = await tx.wait()
		console.log('receipt', receipt)
	})

module.exports = {}