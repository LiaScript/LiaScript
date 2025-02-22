// scripts/inject-sw.js
const fs = require('fs')
const path = require('path')
const { exec } = require('child_process')

// Path to the dist folder
const distDir = path.join(__dirname, '../dist')
// Path for the temporary Workbox config file
const tempConfigPath = path.join(__dirname, 'workbox-config.js')

try {
  // Find the hashed service worker file (e.g., sw.128372.js)
  const swFiles = fs
    .readdirSync(distDir)
    .filter((file) => /^sw\..+\.js$/.test(file))
  if (swFiles.length === 0) {
    console.error('No service worker file found in dist/')
    process.exit(1)
  }
  // Use the first matching file (adjust logic if needed)
  const swFile = swFiles[0]

  // Create the temporary Workbox config content
  const configContent = `
module.exports = {
  globDirectory: './dist',
  globPatterns: ['**/*.{ico,jpg,png,html,js,svg,webmanifest,css,woff2,woff,eot,ttf}'],
  swSrc: './dist/${swFile}',
  swDest: './dist/${swFile}',
  maximumFileSizeToCacheInBytes: 5000000,
};
`
  // Write the temporary config file
  fs.writeFileSync(tempConfigPath, configContent, 'utf8')
  console.log(`Temporary Workbox config generated at ${tempConfigPath}`)

  // Execute the Workbox CLI command with the temporary config file
  const cmd = `npx workbox injectManifest --config ${tempConfigPath}`
  console.log(`Executing: ${cmd}`)
  exec(cmd, (err, stdout, stderr) => {
    // Delete the temporary config file after command execution
    fs.unlinkSync(tempConfigPath)

    if (err) {
      console.error('Error executing Workbox CLI:', err)
      process.exit(1)
    }
    console.log(stdout)
    if (stderr) {
      console.error(stderr)
    }
    console.log('Temporary Workbox config deleted.')
  })
} catch (error) {
  console.error('Error in inject-sw script:', error)
  process.exit(1)
}
