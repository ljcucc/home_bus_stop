const API_BASE = 'https://2384.tainan.gov.tw/NewTNBusAPI_V2'
const KEYWORD_URL = API_BASE + '/API/keyword.ashx'
const CROSSROUTES_URL = API_BASE + '/API/CrossRoutesV2.ashx'

function calcDistance(lat1, lon1, lat2, lon2) {
  const R = 6371e3
  const toRad = d => d * Math.PI / 180
  const dLat = toRad(lat2 - lat1)
  const dLon = toRad(lon2 - lon1)
  const a = Math.sin(dLat / 2) ** 2
    + Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  return R * c
}

function formatDist(meters) {
  return meters < 1000 ? Math.round(meters) + 'm' : (meters / 1000).toFixed(1) + 'km'
}

function classifyTime(timeStr) {
  const timeNum = parseInt(timeStr, 10)
  if (timeStr === '未發車' || timeStr === '已發車' || isNaN(timeNum)) {
    return { label: timeStr, cls: 'nobus', numeric: Infinity }
  }
  if (timeNum <= 1) return { label: '即將進站', cls: 'arriving', numeric: 1 }
  if (timeNum <= 3) return { label: timeNum + ' 分', cls: 'arriving', numeric: timeNum }
  if (timeNum <= 10) return { label: timeNum + ' 分', cls: 'approaching', numeric: timeNum }
  return { label: timeNum + ' 分', cls: 'coming', numeric: timeNum }
}

export async function searchStops(keyword) {
  const res = await fetch(KEYWORD_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ keyword, type: '1', Lang: 'cht', prj: 'tn' }),
  })
  return await res.json()
}

export async function fetchStopData(stopName) {
  const res = await fetch(CROSSROUTES_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ stopnamecht: stopName, Lang: 'cht', Types: '1', prj: 'tn' }),
  })
  return await res.json()
}

export function processStopData(data, myLat, myLon) {
  if (!data || data.length === 0) return []

  const hasLocation = myLat != null && myLon != null

  const sides = data.map(loc => {
    const locId = loc.LocationID

    const routes = loc.info.map(info => {
      const { label, cls, numeric } = classifyTime(info.Time)
      return {
        routeName: info.RouteName,
        dest: info.GoBack === '0' ? info.Dest : info.Dept,
        timeLabel: label,
        timeClass: cls,
        numeric,
        goback: info.GoBack,
        dir: info.GoBack === '0' ? '去程' : '返程',
      }
    })

    routes.sort((a, b) => {
      const order = { arriving: 0, approaching: 1, coming: 2, nobus: 3 }
      const ao = order[a.timeClass] ?? 99
      const bo = order[b.timeClass] ?? 99
      if (ao !== bo) return ao - bo
      if (a.numeric !== Infinity && b.numeric !== Infinity) return a.numeric - b.numeric
      return a.routeName.localeCompare(b.routeName)
    })

    const gobacks = [...new Set(routes.map(r => r.goback))]
    const dirLabel = gobacks.length === 1
      ? (gobacks[0] === '0' ? '往程' : '返程')
      : '雙向'

    let distText = ''
    if (hasLocation && loc.info[0]?.Lat && loc.info[0]?.Lon) {
      const dist = calcDistance(myLat, myLon, parseFloat(loc.info[0].Lat), parseFloat(loc.info[0].Lon))
      distText = formatDist(dist)
    }

    return { locId, dirLabel, distText, routes, gobacks }
  })

  sides.sort((a, b) => {
    if (a.gobacks.length !== b.gobacks.length) return b.gobacks.length - a.gobacks.length
    return a.locId.localeCompare(b.locId)
  })

  return sides
}

export { calcDistance, formatDist }
