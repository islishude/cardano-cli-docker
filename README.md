# Docker for [cardano-cli](https://github.com/input-output-hk/cardano-node/tree/master/cardano-cli)

```console
$ docker run -d -v cardano-chaindata:/data/db -v cardano-socket:/ipc -e NETWORK=mainnet_candidate_4 islishude/cardano-node:1.18.0
$ docker run --rm -v cardano-socket:/node-ipc islishude/cardano-cli shelley query tip --testnet-magic 42
{
    "blockNo": 14693,
    "headerHash": "365058d01c8a453fac03d315f73244bff4e7d861b47cb2e088a1433ec90e01d1",
    "slotNo": 299440
}
```
