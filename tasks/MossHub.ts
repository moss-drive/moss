import '@nomicfoundation/hardhat-ethers'
import 'hardhat-deploy'

import { task } from 'hardhat/config'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import {
	MossHub
} from './Contracts'
import { formatEther } from 'ethers'

// task('MossHub:create')
// 	.addParam('id')
// 	.addParam('f')
// 	.addParam('fs')
// 	.addParam('step')
// 	.addParam('fsstep')
// 	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
// 		const mossHub = await MossHub(env)
// 		const ethers = env.ethers
// 		const signers = await ethers.getSigners()
// 		const f = ethers.parseEther(args.f)
// 		const jsonHead = 'data:application/json;utf8,'
// 		{
// 			const id = args.id
// 			const tx = await mossHub.connect(signers[0]).create(id, f, args.fs, args.step, args.fsstep, Math.floor(Date.now() / 1000) + 360, { value: f * 2n, gasPrice: 2e9 })
// 			console.log('tx', tx)
// 			const receipt = await tx.wait()
// 			console.log('receipt', receipt)
// 			const uri = await mossHub.uri(id)

// 			console.log('uri', uri)
// 			const token = JSON.parse(uri.substring(jsonHead.length))
// 			console.log('image', token.image_data)
// 		}
// 	})

// task('MossHub:mint')
// 	.addOptionalParam('id')
// 	.addOptionalParam('amount')
// 	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
// 		const mossHub = await MossHub(env)
// 		const ethers = env.ethers
// 		const signers = await ethers.getSigners()
// 		const jsonHead = 'data:application/json;utf8,'
// 		{
// 			const amount = args.amount ?? 1
// 			const account = await signers[0].getAddress()
// 			const id = args.id ?? 1
// 			const value0 = await mossHub['estimateMint(uint256,uint256)'](id, amount)
// 			console.log('total', formatEther(value0.total), 'value', formatEther(value0.value), 'devFee', formatEther(value0.devFee), 'creatorFee', formatEther(value0.creatorFee))
// 			const tx = await mossHub.connect(signers[0]).mint(id, account, amount, value0.total, { value: value0.total, gasPrice: 2e9 })
// 			console.log('tx', tx)
// 			const receipt = await tx.wait()
// 			console.log('receipt', receipt)
// 			const uri = await mossHub.uri(id)
// 			console.log('uri', uri)
// 			const totalSupply = await mossHub.totalSupply(id)
// 			console.log('totalSupply', totalSupply)
// 			// const token = JSON.parse(uri.substring(jsonHead.length))
// 			// console.log('image', token.image_data)
// 		}
// 	})

// task('MossHub:mint:price')
// 	.addOptionalParam('id')
// 	.addOptionalParam('amount')
// 	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
// 		const mossHub = await MossHub(env)
// 		{
// 			const amount = args.amount ?? 1
// 			const id = args.id ?? 1
// 			const value0 = await mossHub['estimateMint(uint256,uint256)'](id, amount)
// 			console.log('total', formatEther(value0.total), 'value', formatEther(value0.value), 'devFee', formatEther(value0.devFee), 'creatorFee', formatEther(value0.creatorFee))
// 		}
// 	})

// task('MossHub:burn')
// 	.addOptionalParam('id')
// 	.addOptionalParam('amount')
// 	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
// 		const mossHub = await MossHub(env)
// 		const ethers = env.ethers
// 		const signers = await ethers.getSigners()
// 		const jsonHead = 'data:application/json;utf8,'
// 		{
// 			const amount = args.amount ?? 1
// 			const account = await signers[0].getAddress()
// 			const id = args.id ?? 1
// 			const value0 = await mossHub['estimateBurn(uint256,uint256)'](id, amount)
// 			console.log('total', formatEther(value0.total), 'value', formatEther(value0.value), 'devFee', formatEther(value0.devFee), 'creatorFee', formatEther(value0.creatorFee))

// 			const tx = await mossHub.burn(id, account, amount, value0.total, { gasPrice: 2e9 })
// 			console.log('tx', tx)
// 			const receipt = await tx.wait()
// 			console.log('receipt', receipt)
// 			const uri = await mossHub.uri(id)

// 			console.log('uri', uri)
// 			const totalSupply = await mossHub.totalSupply(id)
// 			console.log('totalSupply', totalSupply)
// 			// const token = JSON.parse(uri.substring(jsonHead.length))
// 			// console.log('image', token.image_data)
// 		}
// 	})

// task('MossHub:burn:price')
// 	.addOptionalParam('id')
// 	.addOptionalParam('amount')
// 	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
// 		const mossHub = await MossHub(env)
// 		{
// 			const amount = args.amount ?? 1
// 			const id = args.id ?? 1
// 			const value0 = await mossHub['estimateBurn(uint256,uint256)'](id, amount)
// 			console.log('total', formatEther(value0.total), 'value', formatEther(value0.value), 'devFee', formatEther(value0.devFee), 'creatorFee', formatEther(value0.creatorFee))
// 		}
// 	})

// task('MossHub:updateStoneName')
// 	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
// 		const mossHub = await MossHub(env)
// 		const ethers = env.ethers
// 		const signers = await ethers.getSigners()
// 		{
// 			const id = 0
// 			const tx = await mossHub.connect(signers[0]).updateStoneName(id, 'Alexandas')
// 			const receipt = await tx.wait()
// 			console.log('receipt', receipt)
// 		}
// 	})
module.exports = {}