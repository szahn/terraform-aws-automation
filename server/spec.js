var assert = require('assert');
const getPayload = require('./getPayload');

describe('Server', function() {
    it('should return return payload', async () => {
        var payload = await getPayload(new Date('1995-12-17T03:24:00'), './payload.json');
        assert.equal('Automation for the People', payload.message);
        assert.equal(819195840000, payload.timestamp);
    });
});