export class PageViewCounter {
  constructor(state, env) {
    this.state = state
    this.data = { pageViews: {}, total: 0 }
    this.storagePromise = this.state.storage.get('data').then(d => {
      if (d) this.data = d
    })
  }

  async fetch(request) {
    await this.storagePromise
    const url = new URL(request.url)
    const page = url.searchParams.get('page') || '/'

    if (request.method === 'POST') {
      if (!this.data.pageViews[page]) {
        this.data.pageViews[page] = 0
      }
      this.data.pageViews[page] += 1
      this.data.total += 1
      this.state.storage.put('data', this.data)
    }

    return new Response(JSON.stringify({
      page,
      count: this.data.pageViews[page] || 0,
      total: this.data.total
    }), {
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      }
    })
  }
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url)

    if (url.pathname !== '/track') {
      return new Response('Not Found', { status: 404 })
    }

    const origin = request.headers.get('Origin') || ''
    const referer = request.headers.get('Referer') || ''
    const allowedHosts = ['andyvictory.dpdns.org']
    const isAllowed = allowedHosts.some(h => origin.includes(h) || referer.includes(h))
    if (!isAllowed) {
      return new Response('Forbidden', { status: 403 })
    }

    const page = url.searchParams.get('page') || '/'
    const id = env.PV_COUNTER.idFromName(page)
    const stub = env.PV_COUNTER.get(id)
    return stub.fetch(request)
  }
}
