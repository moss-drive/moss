import '@nomicfoundation/hardhat-ethers'
import { deploy, Deployment } from './deploy'
import { ethers } from 'hardhat'
import { expect } from 'chai'
import { formatEther } from 'ethers'

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
			// uint256 _f, uint256 _fs, uint256 _s, uint256 _fsStep, uint256 timeoutAt
			await deployment.MossHub.connect(deployment.signers[0]).create(f, 50, 100, 10, Math.floor(Date.now() / 1000) + 360, { value: f * 2n })
			expect(await deployment.MossHub.exists(id), 'nonexisten token')
		}
	})

	it('mint and burn', async () => {
		const f = ethers.parseEther('0.005')
		const id = 0
		// _ f floor price
		// _fs floor supply
		// _s supply to adjust price
		// _fsStep floor supply adjustment when price adjusted
		await deployment.MossHub.create(f, 50, 100, 10, Math.floor(Date.now() / 1000) + 360, { value: f * 2n })
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
			await deployment.MossHub.mint(id, deployment.account, amount, { value: value.total })
			const nf = await deployment.MossHub.nextFloor(id)
			console.log('nf', formatEther(nf))
		}
		for (let i = 0; i < 10; i++) {
			{
				const floor = await deployment.MossHub.floor(id)
				const floorSupply = await deployment.MossHub.floorSupply(id)
				const totalSupply = await deployment.MossHub.totalSupply(id)
				console.log('floor', ethers.formatEther(floor), 'floorSupply', floorSupply, 'totalSupply', totalSupply)
				// mint amount
				const amount1 = 1
				const value1 = await deployment.MossHub['estimateMint(uint256,uint256)'](id, amount1)
				console.log(
					'buy value',
					ethers.formatEther(value1.total),
					ethers.formatEther(value1.value),
					ethers.formatEther(value1.devFee),
					ethers.formatEther(value1.creatorFee),
					ethers.formatEther(value1.total)
				)
				await deployment.MossHub.mint(id, deployment.account, amount1, { value: value1.total })
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