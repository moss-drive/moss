import '@nomicfoundation/hardhat-chai-matchers'
import '@nomicfoundation/hardhat-ethers'
import '@nomicfoundation/hardhat-verify'
import '@typechain/hardhat'
import '@matterlabs/hardhat-zksync-solc'
import '@matterlabs/hardhat-zksync-deploy'
import 'hardhat-deploy'
import 'hardhat-gas-reporter'
import 'solidity-coverage'
import 'hardhat-storage-layout'
import 'solidity-docgen'
import { config as dotenvConfig } from 'dotenv'
import { resolve } from 'path'

if (process.env.NODE_ENV != 'build') {
	require('./tasks')
}

const dotenvConfigPath: string = process.env.DOTENV_CONFIG_PATH || './.env'
dotenvConfig({ path: resolve(__dirname, dotenvConfigPath) })

const accounts = {
	mnemonic: process.env.MNEMONIC || 'test test test test test test test test test test test test',
}

const config = {
	zksolc: {
		version: '1.4.0', // Uses latest available in https://github.com/matter-labs/zksolc-bin/
		settings: {
			libraries: {
				'contracts/libraries/NFTDescriptor.sol': {
					'NFTDescriptor': '0x0A152Ee57E655f4b863766f31a4CB4c903Be9E43'
				}
			}
		},
		missingLibrariesPath: './deployments/optimistic/NFTDescriptor.json',
		libraries: {
			'contracts/libraries/NFTDescriptor.sol': {
				NFTDescriptor: '0xF9702469Dfb84A9aC171E284F71615bd3D3f1EdC',
			},
		},
	},
	solidity: {
		overrides: {},
		compilers: [
			{
				version: '0.8.19',
				settings: {
					optimizer: {
						enabled: true,
						runs: 2000
					},
					outputSelection: {
						'*': {
							'*': ['storageLayout'],
						},
					},
				},
			}
		],
	},
	namedAccounts: {
		deployer: 0,
		simpleERC20Beneficiary: 1
	},
	networks: {
		mainnet: {
			url: 'https://mainnet.infura.io/v3/bc3b8563a584416d9240bec18f404305',
			accounts,
			gas: 'auto',
			gasPrice: 'auto',
			gasMultiplier: 1.3,
			timeout: 100000
		},
		localhost: {
			url: 'http://127.0.0.1:8545',
			accounts,
			gas: 'auto',
			gasPrice: 'auto',
			gasMultiplier: 1.3,
			timeout: 100000
		},
		zkSyncTestnet: {
			url: 'https://sepolia.era.zksync.dev', // The testnet RPC URL of zkSync Era network.
			ethNetwork: 'sepolia', // The Ethereum Web3 RPC URL, or the identifier of the network (e.g. `mainnet` or `sepolia`)
			zksync: true, // enables zksolc compiler
			accounts
		},
		zkSyncMainnet: {
			url: 'https://mainnet.era.zksync.io',
			ethNetwork: 'mainnet',
			zksync: true,
			accounts
		},
		'optimistic-sepolia': {
			url: 'https://opt-sepolia.g.alchemy.com/v2/W2Mb0zJiEVI8ziTVuoMuyAyKdlpZ0W0T',
			chainId: 11155420,
			accounts
		},
		'blast-sepolia': {
			url: 'https://sepolia.blast.io',
			accounts,
			gasPrice: 1000000000,
		},
		optimistic: {
			url: 'https://op-pokt.nodies.app',
			chainId: 10,
			accounts
		},
		blast: {
			url: 'https://rpc.blast.io',
			accounts
		},
		'taiko-hekla': {
			url: 'https://rpc.ankr.com/taiko_hekla',
			accounts
		},
		'taiko': {
			url: 'https://rpc.taiko.xyz',
			accounts
		},
		'optopia-sepolia': {
			url: 'https://rpc-testnet.optopia.ai/',
			accounts
		},
		'optopia': {
			url: 'https://rpc-mainnet-2.optopia.ai',
			accounts,
			zksync: false,
		},
	},
	etherscan: {
		apiKey: {
			'optopia-sepolia': 'YCD2MN31FUJ15DQD4ANRH5FVQV2V66VQ3K',
			'optopia': 'YCD2MN31FUJ15DQD4ANRH5FVQV2V66VQ3K'
		},
		customChains: [
			{
				network: 'optopia-sepolia',
				chainId: 62049,
				urls: {
					apiURL: 'https://scan-testnet.optopia.ai/api',
					browserURL: 'https://scan-testnet.optopia.ai/'
				}
			},
			{
				network: 'optopia',
				chainId: 62050,
				urls: {
					apiURL: 'https://scan.optopia.ai/api',
					browserURL: 'https://scan.optopia.ai/'
				}
			}
		]
	},
	paths: {
		deploy: 'deploy',
		artifacts: 'artifacts',
		cache: 'cache',
		sources: 'contracts',
		tests: 'test'
	},
	gasReporter: {
		currency: 'USD',
		gasPrice: 100,
		enabled: process.env.REPORT_GAS ? true : false,
		coinmarketcap: process.env.COINMARKETCAP_API_KEY,
		maxMethodDiff: 10,
	},
	docgen: {
		templates: './hbs',
		root: './',
		theme: 'markdown',
		sourcesDir: './contracts',
		pages: 'files',
		outputDir: './docs'
	},
	typechain: {
		outDir: 'types',
		target: 'ethers-v6',
	},
	mocha: {
		timeout: 0,
	}
}

export default config
