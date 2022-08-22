const CID = require('cids')
const base32 = require('base32')

const args = process.argv.slice(2);
const cid  = args[0];

const season1_image_cid_v1 = new CID(cid).toV1().toString('base32')
console.log(season1_image_cid_v1)
console.log(new CID(season1_image_cid_v1).toString('base16').substr(9))
