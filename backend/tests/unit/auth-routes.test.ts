import { rateLimitIpKey } from '../../src/modules/auth/rate-limit-keys';

describe('rateLimitIpKey', () => {
  it('normalizes IPv6 addresses to a stable /56 subnet key', () => {
    expect(rateLimitIpKey('2001:db8:abcd:12aa:1111:2222:3333:4444')).toBe(
      '2001:db8:abcd:1200:0:0:0:0/56'
    );
    expect(rateLimitIpKey('2001:db8:abcd:12ff:ffff:ffff:ffff:ffff')).toBe(
      '2001:db8:abcd:1200:0:0:0:0/56'
    );
    expect(rateLimitIpKey('2001:db8:abcd:1300::1')).toBe(
      '2001:db8:abcd:1300:0:0:0:0/56'
    );
  });

  it('preserves IPv4 keys and handles missing IPs', () => {
    expect(rateLimitIpKey('192.0.2.10')).toBe('192.0.2.10');
    expect(rateLimitIpKey(undefined)).toBe('unknown');
  });

  it('treats IPv4-mapped IPv6 addresses as their underlying IPv4', () => {
    expect(rateLimitIpKey('::ffff:192.0.2.10')).toBe('192.0.2.10');
    expect(rateLimitIpKey('::ffff:203.0.113.5')).toBe('203.0.113.5');
    expect(rateLimitIpKey('::ffff:192.0.2.10')).not.toBe(
      rateLimitIpKey('::ffff:203.0.113.5')
    );
  });
});
