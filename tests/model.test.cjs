const { test } = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const vm = require('node:vm');

// QML imports plain JavaScript; evaluate the same source without a build step.
const model = vm.createContext({});
vm.runInContext(readFileSync(`${__dirname}/../Model.js`, 'utf8'), model);
const plain = value => JSON.parse(JSON.stringify(value));
const sample = (device = 'wlan0', rx = 1000, tx = 2000, time = 10) =>
  `${JSON.stringify([{ dev: device }])}\nInter-| Receive | Transmit\n`
  + ` lo: 9000 0 0 0 0 0 0 0 9000 0 0 0 0 0 0 0\n`
  + ` wlan0: ${rx} 0 0 0 0 0 0 0 ${tx} 0 0 0 0 0 0 0\n`
  + ` tun0: 99999 0 0 0 0 0 0 0 88888 0 0 0 0 0 0 0\n${time} 25.50\n`;

test('reads only the selected route, including a VPN, without double counting', () => {
  assert.deepEqual(plain(model.parseSample(sample())), { device: 'wlan0', rx: 1000, tx: 2000, time: 10 });
  assert.equal(model.parseSample(sample('tun0')).rx, 99999);
  assert.equal(model.parseSample(sample('tun0')).tx, 88888);
});

test('offline, missing, loopback, malformed and truncated samples are safe', () => {
  for (const raw of ['', '[]\n1 2', sample('missing'), sample('lo'), 'invalid\n10 20', sample().replace('2000', 'bad'), sample().replace('10 25.50', 'oops')])
    assert.equal(model.parseSample(raw), null);
  assert.equal(model.parseSample('[{"dev":"wlan0"}]\nwlan0: 1 2\n10 20'), null);
});

test('uses elapsed monotonic time, not the nominal timer interval', () => {
  const previous = model.parseSample(sample());
  const current = model.parseSample(sample('wlan0', 4000, 8000, 11.5));
  assert.deepEqual(plain(model.rates(previous, current)), { down: 2000, up: 4000 });
});

test('rebaselines on first read, disconnect, interface change, reset, stall and suspend', () => {
  const previous = model.parseSample(sample());
  const cases = [null, { ...previous, device: 'tun0' }, { ...previous, rx: 0 },
    { ...previous, tx: 0 }, { ...previous, time: 9 }, { ...previous, time: 16 }, previous];
  assert.deepEqual(plain(model.rates(null, previous)), { down: 0, up: 0 });
  for (const current of cases)
    assert.deepEqual(plain(model.rates(previous, current)), { down: 0, up: 0 });
});

test('formats decimal bytes and bits, including unit boundaries', () => {
  for (const [bytes, unit, expected] of [
    [0, 'bytes', '0 KB/s'], [2400, 'bytes', '2.4 KB/s'], [180000, 'bytes', '180 KB/s'],
    [2400000, 'bytes', '2.4 MB/s'], [999500, 'bytes', '1.0 MB/s'],
    [1e9, 'bytes', '1.0 GB/s'], [125000, 'bits', '1.0 Mbps'], [-10, 'bytes', '0 KB/s']
  ]) assert.equal(model.formatRate(bytes, unit), expected);
});

test('threshold follows the selected view and is strictly greater than the limit', () => {
  for (const [down, up, view, expected] of [
    [11000, 0, 'both', true], [0, 11000, 'both', true], [10000, 10000, 'both', false],
    [0, 11000, 'download', false], [11000, 0, 'upload', false],
    [11000, 0, 'download', true], [0, 11000, 'upload', true]
  ]) assert.equal(model.aboveThreshold({ down, up }, view, 10), expected);
  assert.equal(model.aboveThreshold({ down: 0, up: 0 }, 'both', 0), false);
  assert.equal(model.aboveThreshold({ down: 1, up: 0 }, 'both', 0), true);
});
