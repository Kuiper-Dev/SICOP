import app from '../app/app';

app.listen(app.get('port'));

//SETTINGS

console.log('Server on port', app.get('port'));