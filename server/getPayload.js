const fs = require("fs");

module.exports = function getPayload(date, filename) {

    return new Promise((res, rej) => {
        fs.readFile(filename, (err, data) => {
            if (err){
                rej(err);
                return;
            }
    
            const responseJson = Object.assign(JSON.parse(data), {
                "timestamp": date.getTime()
            });
    
            res(responseJson);
        });
    });
}
