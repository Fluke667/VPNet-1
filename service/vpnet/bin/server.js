'use strict'
/**
 * 
 * VPNet.io Web Service
 * Virtual Private Network Essential Toolbox
 * https://github.com/acrossfw/vpnet
 * 
 */
const express             = require('express')
const httpProxyMiddleware = require('http-proxy-middleware')

const { Config, GfRelay, SetupScript, log } = require('../')

const app     = express()

const config = new Config()

const GF_RELAY_PREFIX = '/gf-relay/'
const gfRelay = new GfRelay({
  host: `${config.ip()}:${config.port()}`
  , prefix: GF_RELAY_PREFIX
})
app.use(GF_RELAY_PREFIX, gfRelay.router())

app.get('/', (req, res) => {
  res.send(`curl -sL http://${config.ip()}:${config.port()}/connect-gfwrt.sh | bash -`)
})

app.get('/setup.sh/:uuid', (req, res) => {
  
  const gfwrt = new GfWrt(req.params.uuid)
  const script = new SetupScript(gfwrt)
  
  // res.writeHead(200, { 'Content-Type': 'application/x-sh' })
  res.writeHead(200, { 'Content-Type': 'text/plain' })
  res.write(script.generate())
  res.end()
})

app.listen(config.port())

console.log(`[VPNet] Server: listening at ${config.ip()}:${config.port()}`)

console.log('ss: ' + gfRelay.url('shadowsocks'))