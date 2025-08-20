'use strict'

const { URL } = require('url')

const ADMIN_BACKEND_URL = process.env.ADMIN_BACKEND_URL || process.env.BACKEND_URL
const PHISH_BACKEND_URL = process.env.PHISH_BACKEND_URL

const ADMIN_HOST = (process.env.ADMIN_HOST || '').toLowerCase()
const PHISH_HOST = (process.env.PHISH_HOST || '').toLowerCase()

function readBody(req) {
    return new Promise((resolve, reject) => {
        const chunks = []
        req.on('data', (c) => chunks.push(c))
        req.on('end', () => resolve(Buffer.concat(chunks)))
        req.on('error', reject)
    })
}

module.exports = async (req, res) => {
    try {
        const hostHeader = String(req.headers.host || '').toLowerCase()
        const hostNoPort = hostHeader.split(':')[0]
        const isPhish = PHISH_HOST && hostNoPort === PHISH_HOST
        const base = isPhish && PHISH_BACKEND_URL ? PHISH_BACKEND_URL : ADMIN_BACKEND_URL
        if (!base) {
            res.statusCode = 500
            res.setHeader('content-type', 'application/json')
            res.end(JSON.stringify({ error: 'Missing ADMIN_BACKEND_URL or BACKEND_URL' }))
            return
        }

        const upstreamUrl = new URL(req.url.replace(/^\/api/, ''), base)

        const hopByHop = new Set([
            'connection', 'keep-alive', 'proxy-authenticate', 'proxy-authorization', 'te', 'trailers', 'transfer-encoding', 'upgrade'
        ])
        const headers = {}
        for (const [k, v] of Object.entries(req.headers)) {
            const key = String(k).toLowerCase()
            if (!hopByHop.has(key)) headers[key] = v
        }
        headers['x-forwarded-host'] = req.headers.host || ''
        headers['x-forwarded-proto'] = 'https'

        let body
        if (!['GET', 'HEAD'].includes(req.method)) {
            const buf = await readBody(req)
            if (buf.length) body = buf
        }

        const upstream = await fetch(upstreamUrl, {
            method: req.method,
            headers,
            body,
        })

        res.statusCode = upstream.status
        upstream.headers.forEach((value, key) => {
            if (!hopByHop.has(String(key).toLowerCase())) {
                res.setHeader(key, value)
            }
        })
        const buff = Buffer.from(await upstream.arrayBuffer())
        res.end(buff)
    } catch (err) {
        console.error('Proxy error:', err)
        res.statusCode = 502
        res.setHeader('content-type', 'application/json')
        res.end(JSON.stringify({ error: 'Bad Gateway', details: String(err && err.message ? err.message : err) }))
    }
}


