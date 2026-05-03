import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

const PROJECT_ID = 'edrmp-100b7'

function getServiceAccount() {
  const b64 = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_B64')!
  return JSON.parse(atob(b64))
}

async function getAccessToken(serviceAccount: Record<string, string>): Promise<string> {
  const now = Math.floor(Date.now() / 1000)
  const header = { alg: 'RS256', typ: 'JWT' }
  const payload = {
    iss: serviceAccount.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  }

  const encode = (obj: object) =>
    btoa(JSON.stringify(obj))
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=/g, '')

  const signingInput = `${encode(header)}.${encode(payload)}`

  const keyData = serviceAccount.private_key
    .replace('-----BEGIN PRIVATE KEY-----', '')
    .replace('-----END PRIVATE KEY-----', '')
    .replace(/\n/g, '')

  const binaryKey = Uint8Array.from(atob(keyData), (c) => c.charCodeAt(0))
  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    binaryKey,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign']
  )

  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    new TextEncoder().encode(signingInput)
  )

  const jwt = `${signingInput}.${btoa(
    String.fromCharCode(...new Uint8Array(signature))
  ).replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '')}`

  const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  })
  const tokenData = await tokenRes.json()
  return tokenData.access_token
}

async function sendFcmNotification(
  fcmToken: string,
  title: string,
  body: string,
  projectId: string
): Promise<void> {
  const serviceAccount = getServiceAccount()
  const accessToken = await getAccessToken(serviceAccount)

  await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: {
          token: fcmToken,
          notification: { title, body },
          data: { title, body },
        },
      }),
    }
  )
}

serve(async (req) => {
  try {
    const payload = await req.json()
    const record = payload.record

    if (record.status !== 'police_approved') {
      return new Response(JSON.stringify({ skipped: true }), { status: 200 })
    }

    const title = 'Unblock Request — Action Required'
    const body = 'Police have approved an unblock request. Your approval is needed.'

    const { data: ptaProfile } = await supabase
      .from('profiles')
      .select('id, fcm_token')
      .eq('role', 'pta')
      .limit(1)
      .single()

    if (!ptaProfile) {
      return new Response(JSON.stringify({ ok: true, note: 'no pta profile found' }), { status: 200 })
    }

    if (ptaProfile.fcm_token) {
      await sendFcmNotification(ptaProfile.fcm_token, title, body, PROJECT_ID)
    }

    await supabase.from('notifications').insert({
      recipient_id: ptaProfile.id,
      title,
      body,
      type: 'unblock_received_pta',
      entity_id: record.id,
    })

    return new Response(JSON.stringify({ ok: true }), { status: 200 })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 })
  }
})
