const express = require('express');
const router = express.Router();
const sql = require('mssql');

// import dbConfig
const dbConfig = require('../dbConfig');


// (POST)/user/admin/signin
// Auth log in admin with creds
router.post('/admin/signin', async (req, res) => {
    const { Email, Password } = req.body;

    if (!Email || !Password) {
        return res.status(400).json({
            message: "Missing credentials: Email and Password must be provided",
        });
    }

    try {
        const pool = await sql.connect(dbConfig);
        const request = pool.request();

        request.input('Email', sql.VARCHAR(100), Email);
        request.input('Password', sql.NVARCHAR(255), Password);

        const result = await request.execute('ValidateAdmin');

        // Return of validate request
        adminInfo = result.recordset[0];
        const validatedAdminID = adminInfo?.MaAdmin;

        // Admin ID return not null: Login success
        if (validatedAdminID) {
            return res.status(200).json({
                message: 'Admin login successful',
                adminInfo: adminInfo,
            })
        } else {
            return res.status(401).json({
                message: "Invalid admin email or password"
            });
        }


    } catch(err) {
        console.error("Lỗi khi login admin:", err.message);

        res.status(500).json({
        message: "Lỗi server khi login admin.",
        error: err.message,
        });
    }

});




// (GET)/user/users/
// Return users with paging
router.get('/users/', async (req, res) => {
    const page = parseInt(req.query.page) || 1
    const limit = parseInt(req.query.limit) || 10
    try {
        const pool = await sql.connect(dbConfig);
        const request = pool.request(); 

        request.input('page', sql.Int, page)
        request.input('limit', sql.Int, limit)

        const result = await request.execute('GetUsersPaged');

        const users = result.recordsets[0];
        const pagination = result.recordsets[1][0];

        const reponseContent = {
            users: users,
            pagination: pagination
        } 

        return res.json(reponseContent);
    }
    catch (error) {
        console.error(error);
        return res.status(500).send({ message: 'Error executing get users paged.' });
    }
});






// (GET)/user/customers/
// Return customers with paging
router.get('/customers/', async (req, res) => {
    const page = parseInt(req.query.page) || 1
    const limit = parseInt(req.query.limit) || 10
    try {
        const pool = await sql.connect(dbConfig);
        const request = pool.request(); 

        request.input('page', sql.Int, page)
        request.input('limit', sql.Int, limit)

        const result = await request.execute('GetCustomersPaged');

        const users = result.recordsets[0];
        const pagination = result.recordsets[1][0];

        const reponseContent = {
            users: users,
            pagination: pagination
        } 

        return res.json(reponseContent);
    }
    catch (error) {
        console.error(error);
        return res.status(500).send({ message: 'Error executing get users paged.' });
    }
});





// (GET)/:UserID
// Return user
router.get('/:UserID', async (req, res) => {
    const UserID = req.params.UserID;
    try {
        const pool = await sql.connect(dbConfig);
        const request = pool.request();

        request.input('UserID', sql.VarChar, UserID);
        const result = await request.query('SELECT * FROM [User] WHERE UserID = @UserID');
        
        return res.json(result.recordsets[0]);
    }
    catch (error) {
        console.log(error);
        return res.status(500).send({ message: 'Error executing get user query.' });
    }
});



// (GET)/products/topbuy
// Return top limit most bought products by UserID
router.get('/:UserID/toppurchased', async (req, res) => {
    const UserID = req.params.UserID;
    const limit = parseInt(req.query.limit);
    try {
        if (!UserID || !limit) {
            return res.status(400).send({ message: 'Missing required parameters: UserID and limit.' });
        };

        const pool = await sql.connect(dbConfig);
        const request = pool.request();
        request.input('p_UserID', sql.VarChar, UserID);
        request.input('p_Limit', sql.Int, limit);

        const result = await request.execute('GetTopPurchasedItems');
        return res.json(result.recordsets[0]);
    }
    catch (error) {
        console.log(error);
        return res.status(500).send({ message: 'Error executing stored procedure.' });
    }
});





module.exports = router;