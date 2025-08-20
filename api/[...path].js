'use strict'

const { createProxyMiddleware } = require('http-proxy-middleware')

const ADMIN_BACKEND_URL = process.env.ADMIN_BACKEND_URL || process.env.BACKEND_URL
const PHISH_BACKEND_URL = process.env.PHISH_BACKEND_URL

const ADMIN_HOST = (process.env.ADMIN_HOST || '').toLowerCase()
const PHISH_HOST = (process.env.PHISH_HOST || '').toLowerCase()

if (!ADMIN_BACKEND_URL) {
    console.error('ADMIN_BACKEND_URL (or BACKEND_URL) env var not set')
}

module.exports = (req, res) => {
    const hostHeader = String(req.headers.host || '').toLowerCase()
    const isPhish = PHISH_HOST && hostHeader === PHISH_HOST
    const target = isPhish && PHISH_BACKEND_URL ? PHISH_BACKEND_URL : ADMIN_BACKEND_URL

    const proxy = createProxyMiddleware({
        target,
        changeOrigin: true,
        xfwd: true,
        ws: false,
        secure: false,
        pathRewrite: {
            '^/api': '',
        },
        onProxyReq: (proxyReq) => {
            proxyReq.setHeader('x-forwarded-host', req.headers.host || '')
        },
    })
    return proxy(req, res)
}


