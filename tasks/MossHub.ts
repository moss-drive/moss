import '@nomicfoundation/hardhat-ethers'
import 'hardhat-deploy'

import { task } from 'hardhat/config'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import {
	MossHub
} from './Contracts'
import { formatEther, parseEther } from 'ethers'

task('MossHub:create')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const mossHub = await MossHub(env)
		const ethers = env.ethers
		const signers = await ethers.getSigners()
		const jsonHead = 'data:application/json;utf8,'
		{
			const id = args.id
			const tx = await mossHub.connect(signers[0]).create(Math.floor(Date.now() / 1000) + 360, { value: parseEther('0.0001') * 2n, gasPrice: 1e9 })
			console.log('tx', tx)
			const receipt = await tx.wait()
			console.log('receipt', receipt)
			const uri = await mossHub.uri(id)

			console.log('uri', uri)
			const token = JSON.parse(uri.substring(jsonHead.length))
			console.log('image', token.image_data)
		}
	})

task('MossHub:floor')
	.addOptionalParam('id')
	.addOptionalParam('amount')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const mossHub = await MossHub(env)
		const floor = await mossHub.floor(23)
		const floorSupply = await mossHub.floorSupply(23)
		const totalSupply = await mossHub.totalSupply(23)

		console.log('floor', formatEther(floor))
		console.log('floorSupply', floorSupply)
	})

task('MossHub:transferDev')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const mossHub = await MossHub(env)
		const newDev = ''
		const tx = await mossHub.transferDev(newDev)
		console.log('tx', tx)
		const receipt = await tx.wait()
		console.log('receitp', receipt)
	})

task('MossHub:dev')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const mossHub = await MossHub(env)
		const ethers = env.ethers
		const signers = await ethers.getSigners()
		{
			const id = 0
			const dev = await mossHub.dev()
			console.log('dev', dev)
		}
	})
module.exports = {}