let bitcoinjs = require('bitcoinjs-lib');
let bitgoUtxoLib = require('bitgo-utxo-lib');
let ecPair1 = bitgoUtxoLib.ECPair.makeRandom({ network: bitgoUtxoLib.networks.zcash });
let ecPair2 = bitgoUtxoLib.ECPair.makeRandom({ network: bitgoUtxoLib.networks.zcash });
let ecPair3 = bitgoUtxoLib.ECPair.makeRandom({ network: bitgoUtxoLib.networks.zcash });

const keyPairs = [ecPair1.getPublicKeyBuffer(), ecPair2.getPublicKeyBuffer(), ecPair3.getPublicKeyBuffer()];
const p2ms = bitcoinjs.payments.p2ms({ m: 2, pubkeys: keyPairs, network: bitgoUtxoLib.networks.zcash });
const p2sh = bitcoinjs.payments.p2sh({ redeem: p2ms, network: bitgoUtxoLib.networks.zcash });

const publicAddress = bitgoUtxoLib.address.fromOutputScript(p2sh.output, bitgoUtxoLib.networks.zcash);
const redeemScript = p2sh.redeem.output.toString('hex');

console.log('Multisig Address : ', publicAddress);
console.log('Redeem Script : ', redeemScript);

console.log('** Wallet 1 details : ', {
    publicKey: ecPair1.getPublicKeyBuffer().toString('hex'),
    privateKey: ecPair1.toWIF(),
    publicAddress: ecPair1.getAddress()
});
console.log('** Wallet 2 details : ', {
    publicKey: ecPair2.getPublicKeyBuffer().toString('hex'),
    privateKey: ecPair2.toWIF(),
    publicAddress: ecPair2.getAddress()
});
console.log('** Wallet 3 details : ', {
    publicKey: ecPair3.getPublicKeyBuffer().toString('hex'),
    privateKey: ecPair3.toWIF(),
    publicAddress: ecPair3.getAddress()
});

