import '@nomicfoundation/hardhat-ethers'
import 'hardhat-deploy'

import { task } from 'hardhat/config'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import {
	ProxyAdmin
} from './Contracts'

task('ProxyAdmin:upgradeAndCall')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const admin = await ProxyAdmin(env)
	})


module.exports = {}