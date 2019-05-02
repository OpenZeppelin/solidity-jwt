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
    }
  },
  compilers: {
    solc: {
      version: "0.5.4",
      evmVersion: "constantinople"
    }
  }
}

