var express = require('express');
var app = express();
const cors = require('cors')
var sql = require("mssql");
const { SlowBuffer } = require('buffer');
const dotenv = require('dotenv')
dotenv.config()


app.use(express.json())
app.use(cors())


//Endpoint to retreive patient's appointment record 
app.post('/patient', function(req, res){

    //Retrieve value the user entered
    var id = req.body.recordId

    //Connect to database with authorization
    var config = {
        user: process.env.USER,
        password: process.env.PASSWORD,
        server: process.env.SERVER, 
        database: process.env.DATABASE 
    };
    sql.connect(config, function (err) {  
        if (err) console.log(err);
        var request = new sql.Request();

        // Query database to retrieving record with matching RecordID
        request.query(`select * from Record where RecordID ='${id}'`, function (err, rows) {
            if (err) {
                res.json({message: 'RecordID does not exists'})
                console.log(err)
            } 

            // returns the record of the patient's appointment as JSON object
            res.status(200).json(rows.recordset[0])
            sql.close();
        });
    });
});

//Endpoint to create patient appointment record
app.post('/createrecord', function(req, res){
    
     //Retrieve value the user entered
    var dateInfo = req.body.dateInfo
    var diagnosisId = req.body.diagnosisId
    var employeeId = req.body.employeeId
    var patientId = req.body.patientId
    var amountCharged = req.body.amountCharged

    //Connect to database with authorization
    var config = {
        user: process.env.USER,
        password: process.env.PASSWORD,
        server: process.env.SERVER, 
        database: process.env.DATABASE 
    };

    sql.connect(config, err => {
    
        if (err) console.log(err);
        var request = new sql.Request()

//Pass in values with proper data types and execute add_record_of_patient_appointment procedure
        request
        .input('Date', sql.Date, dateInfo)
        .input('AmountCharged', sql.Numeric(12,2), amountCharged)
        .input('DiagnosisID', sql.Int, diagnosisId) 
        .input('PatientID', sql.Int, patientId)   
        .input('EmployeeID', sql.Int, employeeId)
        .execute('add_record_of_patient_appointment', (err, result) =>{
            res.json({message: 'Appointment Record Added!'})
            sql.close();
        })        
        });
});

//Endpoint to submit a payment
app.post('/createpayment', function(req, res){
    
    //Retrieve value the user entered
    var dateInfo = req.body.dateInfo
    var paymentTypeId = req.body.paymentTypeId
    var patientId = req.body.patientId
    var paymentAmount = req.body.paymentAmount

    //Connect to database with authorization
    var config = {
        user: process.env.USER,
        password: process.env.PASSWORD,
        server: process.env.SERVER, 
        database: process.env.DATABASE 
    };

    sql.connect(config, err => {
    
        if (err) console.log(err);
        var request = new sql.Request()

//Pass in values with proper data types and execute record_patient_payment procedure
        request
        .input('Date', sql.Date, dateInfo)
        .input('PaymentAmount', sql.Numeric(12,2), paymentAmount) 
        .input('PaymentTypeID', sql.Int, paymentTypeId)
        .input('PatientID', sql.Int, patientId)   
        .execute('record_patient_payment', (err, result) =>{
            res.json({message: 'Payment Successful!'})
            sql.close();
        })        
        });
});


var server = app.listen(8080, function () {
    console.log('Server is up and running!');
});