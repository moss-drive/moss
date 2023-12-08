import '@nomicfoundation/hardhat-ethers'
import { deploy, Deployment } from './deploy'
import { ethers } from 'hardhat'
import { expect } from 'chai'

describe('Test MossHub', () => {

	let deployment: Deployment
	let MossHubAddr: string

	beforeEach(async () => {
		deployment = await deploy()
		MossHubAddr = await deployment.MossHub.getAddress()
	})

	it('create', async () => {
		const f = ethers.parseEther('0.005')
		{
			const id = 0
			await deployment.MossHub.connect(deployment.signers[0]).create(id, f, 50, 100, 10, Math.floor(Date.now() / 1000) + 360, { value: f * 2n })
			expect(await deployment.MossHub.exists(id), 'nonexisten token')
		}
	})

	it('mint and burn', async () => {
		const f = ethers.parseEther('0.005')
		const id = 0
		await deployment.MossHub.create(id, f, 50, 100, 10, Math.floor(Date.now() / 1000) + 360, { value: f * 2n })
		const balance = await deployment.signer.provider?.getBalance(MossHubAddr)
		console.log('initializeNewKey balance:', balance)
		const worth = await deployment.MossHub.worthOf(id)
		console.log('worth initializeNewKey', worth)
		{
			const f = await deployment.MossHub.floor(id)
			const p = await deployment.MossHub.floorSupply(id)
			const t = await deployment.MossHub.totalSupply(id)
			console.log('f', f, 'p', p, 't', t)
			const amount = p - 1n
			const value = await deployment.MossHub['estimateMint(uint256,uint256)'](id, amount)
			console.log('buy value', value.total, value.value, value.devFee, value.creatorFee)
			await deployment.MossHub.mint(id, deployment.account, amount, value.total, { value: value.total })
		}
		for (let i = 0; i < 10; i++) {
			const f = await deployment.MossHub.floor(id)
			const p = await deployment.MossHub.floorSupply(id)
			const t = await deployment.MossHub.totalSupply(id)
			console.log('f', f, 'p', p, 't', t)
			const amount0 = 99
			const value0 = await deployment.MossHub['estimateMint(uint256,uint256)'](id, amount0)
			console.log('buy value 0', value0.total, value0.value, value0.devFee, value0.creatorFee, ethers.formatEther(value0.total))
			await deployment.MossHub.mint(id, deployment.account, amount0, value0.total, { value: value0.total })
			{
				const f = await deployment.MossHub.floor(id)
				const p = await deployment.MossHub.floorSupply(id)
				const t = await deployment.MossHub.totalSupply(id)
				console.log('f', f, 'p', p, 't', t, 'parse value', ethers.formatEther(f))
				const amount1 = 1
				const value1 = await deployment.MossHub['estimateMint(uint256,uint256)'](id, amount1)
				console.log('buy value 1', value1.total, value1.value, value1.devFee, value1.creatorFee, ethers.formatEther(value1.total))
				await deployment.MossHub.mint(id, deployment.account, amount1, value1.total, { value: value1.total })
			}

			{
				const f = await deployment.MossHub.floor(id)
				const p = await deployment.MossHub.floorSupply(id)
				const t = await deployment.MossHub.totalSupply(id)
				console.log('f', f, 'p', p, 't', t, 'parse value', ethers.formatEther(f))
				const amount2 = 1
				const value2 = await deployment.MossHub['estimateMint(uint256,uint256)'](id, amount2)
				console.log('buy value 2', value2.total, value2.value, value2.devFee, value2.creatorFee, ethers.formatEther(value2.total))
			}

			{
				const balance = await deployment.signer.provider?.getBalance(MossHubAddr)
				console.log('balance', ethers.formatEther(balance!))
				const worth = await deployment.MossHub.worthOf(id)
				console.log('MossHub worth', ethers.formatEther(worth))
				const totalSupply = await deployment.MossHub.totalSupply(id)
				console.log('totalSupply', totalSupply)
			}
		}

		{
			const balance = await deployment.signer.provider?.getBalance(MossHubAddr)
			console.log('balance', ethers.formatEther(balance!))
			const worth = await deployment.MossHub.worthOf(id)
			console.log('MossHub worth', ethers.formatEther(worth))
			const t1 = await deployment.MossHub.totalSupply(id)
			console.log('t1', t1)
		}

		{
			const b = await deployment.MossHub.balanceOf(deployment.account, id)
			console.log('balance', b)
			await deployment.MossHub.burn(id, deployment.account, b, 0)
			const total = await deployment.MossHub.totalSupply(id)
			console.log('total', total)
		}
	})

})