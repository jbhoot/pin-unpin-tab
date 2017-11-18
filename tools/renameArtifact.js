const path = require('path');
const {renameSync} = require('fs');
const manifest = require('../src/manifest.json');

const name = manifest.name.toLowerCase()
    .replace(/ /g, '_');

const oldName = `${name}-${manifest.version}.zip`;
const newName = `${name}-${manifest.version}-unsigned.xpi`;
renameSync(
    path.resolve('releases', oldName),
    path.resolve('releases', newName)
)
console.log(`Renamed ${oldName} to ${newName}`)
