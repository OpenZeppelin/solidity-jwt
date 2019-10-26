module.exports = {
  networks: {
    local: {
      host: 'localhost',
      port: 8545,
      network_id: '*',
      gas: 5000000
    },
    testing: {
      host: 'localhost',
      port: 9555,
      network_id: '4447',
      gas: 6000000
    },
    "rinkeby-infura": {
      provider: () => new (require("truffle-hdwallet-provider"))(process.env.MNEMONIC, "https://rinkeby.infura.io/v3/" + process.env.INFURA_ID),
      network_id: 4,
      gas: 5000000,
      gasPrice: 10e9
    },

  },
  compilers: {
    solc: {
      version: "0.5.4",
      evmVersion: "constantinople"
    }
  }
}

