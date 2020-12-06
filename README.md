# Docker for [cardano-cli](https://github.com/input-output-hk/cardano-node/tree/master/cardano-cli)

```console
$ docker run -d -v cardano-chaindata:/data/db -v cardano-socket:/ipc -e NETWORK=mainnet inputoutput/cardano-node
$ docker run --rm -v cardano-socket:/node-ipc islishude/cardano-cli shelley query tip --mainnet
{
    "blockNo": 5041032,
    "headerHash": "875532d8cf9dff771ce0c9b6fdbab7a826c3bbd9fd9c8ac5d3351c311ae080d6",
    "slotNo": 15658669
}
```
