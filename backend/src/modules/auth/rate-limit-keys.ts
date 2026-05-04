import { isIP } from 'node:net';

const ipv6RateLimitSubnetBits = 56;

function expandIpv6(ip: string): number[] | null {
  const [headPart, tailPart = ''] = ip.toLowerCase().split('::');
  const head = headPart ? headPart.split(':') : [];
  const tail = tailPart ? tailPart.split(':') : [];

  const ipv4Tail = tail.at(-1)?.includes('.') ? tail.pop() : undefined;
  if (ipv4Tail) {
    const octets = ipv4Tail.split('.').map((part) => Number(part));
    if (
      octets.length !== 4 ||
      octets.some((octet) => !Number.isInteger(octet) || octet < 0 || octet > 255)
    ) {
      return null;
    }
    tail.push(
      ((octets[0] << 8) | octets[1]).toString(16),
      ((octets[2] << 8) | octets[3]).toString(16)
    );
  }

  const missing = 8 - head.length - tail.length;
  if (missing < 0 || (!ip.includes('::') && missing !== 0)) return null;

  const hextets = [...head, ...Array(missing).fill('0'), ...tail].map((part) => {
    const value = Number.parseInt(part || '0', 16);
    return Number.isInteger(value) && value >= 0 && value <= 0xffff ? value : NaN;
  });

  return hextets.length === 8 && hextets.every((value) => !Number.isNaN(value))
    ? hextets
    : null;
}

export function rateLimitIpKey(ip: string | undefined): string {
  if (!ip) return 'unknown';
  if (isIP(ip) !== 6) return ip;

  const hextets = expandIpv6(ip);
  if (!hextets) return ip;

  // IPv4-mapped IPv6 (::ffff:a.b.c.d): treat as the underlying IPv4 so dual-stack
  // clients don't all collapse into the same /56 bucket.
  if (
    hextets[0] === 0 &&
    hextets[1] === 0 &&
    hextets[2] === 0 &&
    hextets[3] === 0 &&
    hextets[4] === 0 &&
    hextets[5] === 0xffff
  ) {
    return [
      (hextets[6] >> 8) & 0xff,
      hextets[6] & 0xff,
      (hextets[7] >> 8) & 0xff,
      hextets[7] & 0xff,
    ].join('.');
  }

  const fullHextets = Math.floor(ipv6RateLimitSubnetBits / 16);
  const remainingBits = ipv6RateLimitSubnetBits % 16;
  const normalized = [...hextets];

  if (remainingBits > 0) {
    const mask = (0xffff << (16 - remainingBits)) & 0xffff;
    normalized[fullHextets] &= mask;
  }

  for (let index = fullHextets + (remainingBits > 0 ? 1 : 0); index < 8; index += 1) {
    normalized[index] = 0;
  }

  return `${normalized.map((part) => part.toString(16)).join(':')}/${ipv6RateLimitSubnetBits}`;
}
