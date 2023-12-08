import '@nomicfoundation/hardhat-ethers'
import 'hardhat-deploy'

import { task } from 'hardhat/config'
import { HardhatRuntimeEnvironment } from 'hardhat/types'

task('StorageLayout')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		await env.storageLayout.export()
	})