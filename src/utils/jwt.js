export function splitToken(token) {
  return token.split('.');
}

export function parseToken(token) {
  const [header, payload, signature] = splitToken(token);
  return {
    header: JSON.parse(atob(header)),
    payload: JSON.parse(atob(payload)),
    signature: '0x' + Buffer.from(signature, 'base64').toString('hex')
  }
}