const DeGiro = require('..');

const degiro = DeGiro.create({
    username: 'croa98',
    password: 'Queteden123',
});

degiro.login().then(degiro.getCashFunds)
.then(console.log)
.catch(console.error);
