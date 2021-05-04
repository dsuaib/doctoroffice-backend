var express = require('express');
var app = express();
const cors = require('cors')
var sql = require("mssql");
const { SlowBuffer } = require('buffer');

app.use(express.json())
app.use(cors())


app.get('/teen', function(req, res){

    var amountCharged = 50
    var config = {
        user: 'dsuaib',
        password: 'Incorrect1',
        server: 'firstaitserver.database.windows.net', 
        database: 'firstDatabase' 
    };

    sql.connect(config, function (err) {
    
        if (err) console.log(err);

        // create Request object
        var request = new sql.Request();
           
        // query to the database and get the records
        request.query(`insert into record (Date, AmountCharged, DiagnosisID, EmployeeID, PatientID) values (CONVERT(VARCHAR(10), '2021-05-02'), '${amountCharged}', '1', '6', '1')`, function (err, recordset) {
            
            if (err) console.log(err)

            // send records as a response
            res.send(recordset);
            sql.close();
        });
    });
});
app.get('/patient/:id', function(req, res){

    var id = req.params.id

    var config = {
        user: 'dsuaib',
        password: 'Incorrect1',
        server: 'firstaitserver.database.windows.net', 
        database: 'firstDatabase' 
    };

    sql.connect(config, function (err) {
    
        if (err) console.log(err);

        // create Request object
        var request = new sql.Request();
           
        // query to the database and get the records
        request.query(`select * from record where PatientID ='${id})`, function (err, recordset) {
            
            if (err) console.log(err)

            // send records as a response
            res.send(recordset);
            sql.close();
        });
    });
});
app.post('/createrecord', function(req, res){
    
    var dateInfo = req.body.dateInfo
    var diagnosisId = req.body.diagnosisId
    var employeeId = req.body.employeeId
    var patientId = req.body.patientId
    var amountCharged = req.body.amountCharged

    var config = {
        user: 'dsuaib',
        password: 'Incorrect1',
        server: 'firstaitserver.database.windows.net', 
        database: 'firstDatabase' 
    };

    sql.connect(config, err => {
    
        if (err) console.log(err);

        // create Request object
        var request = new sql.Request()

        // query to the database and get the records
        request
        .input('Date', sql.Date, dateInfo)
        .input('AmountCharged', sql.Numeric(12,2), amountCharged)
        .input('DiagnosisID', sql.Int, diagnosisId) 
        .input('PatientID', sql.Int, patientId)   
        .input('EmployeeID', sql.Int, employeeId)
        .execute('add_record_of_patient_appointment', (err, result) =>{
            res.send(result)
            sql.close();
        })        
        });
});

app.get('/', function (req, res) {


    // config for your database
    var config = {
        user: 'dsuaib',
        password: 'Incorrect1',
        server: 'firstaitserver.database.windows.net', 
        database: 'firstDatabase' 
    };

    // connect to your database
    sql.connect(config, function (err) {
    
        if (err) console.log(err);

        // create Request object
        var request = new sql.Request();
           
        // query to the database and get the records
        request.query('select * from Office', function (err, recordset) {
            
            if (err) console.log(err)

            // send records as a response
            res.send(recordset);
            sql.close();
        });
    });
});

app.post('/createpayment', function(req, res){
    
    var dateInfo = req.body.dateInfo
    var paymentTypeId = req.body.paymentTypeId
    var patientId = req.body.patientId
    var paymentAmount = req.body.paymentAmount


    var config = {
        user: 'dsuaib',
        password: 'Incorrect1',
        server: 'firstaitserver.database.windows.net', 
        database: 'firstDatabase' 
    };

    sql.connect(config, err => {
    
        if (err) console.log(err);

        // create Request object
        var request = new sql.Request()

        // query to the database and get the records
        request
        .input('Date', sql.Date, dateInfo)
        .input('PaymentAmount', sql.Numeric(12,2), paymentAmount) 
        .input('PaymentTypeID', sql.Int, paymentTypeId)
        .input('PatientID', sql.Int, patientId)   
        .execute('record_patient_payment', (err, result) =>{
            res.send(result)
            sql.close();
        })        
        });
});

app.get('/', function (req, res) {


    // config for your database
    var config = {
        user: 'dsuaib',
        password: 'Incorrect1',
        server: 'firstaitserver.database.windows.net', 
        database: 'firstDatabase' 
    };

    // connect to your database
    sql.connect(config, function (err) {
    
        if (err) console.log(err);

        // create Request object
        var request = new sql.Request();
           
        // query to the database and get the records
        request.query('select * from Office', function (err, recordset) {
            
            if (err) console.log(err)

            // send records as a response
            res.send(recordset);
            sql.close();
        });
    });
});

var server = app.listen(8080, function () {
    console.log('Server is running..');
});