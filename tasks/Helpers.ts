import '@nomicfoundation/hardhat-ethers'
import 'hardhat-deploy'

import { task } from 'hardhat/config'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import {
	Helpers
} from './Contracts'

task('Helpers:stoneOf')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const helpers = await Helpers(env)
		const stone = await helpers.stoneOf('0x21eE2DFdf794C6b650b1fDc6FD2406F2c6f3a990', 2)
		console.log('stone', stone)
	})

module.exports = {}