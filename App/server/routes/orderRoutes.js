const express = require('express');
const router = express.Router();
const sql = require('mssql');

// import dbConfig
const dbConfig = require('../dbConfig');






// (GET)/order/orders/
// Return orders with paging
router.get('/orders/', async (req, res) => {
    const page = parseInt(req.query.page) || 1
    const limit = parseInt(req.query.limit) || 10
    
    // Ensure the connection pool and request object are declared outside the try block 
    // or handle the connection management appropriately.
    let pool; 
    try {
        pool = await sql.connect(dbConfig);
        let request = pool.request(); 

        request.input('page', sql.Int, page)
        request.input('limit', sql.Int, limit)

        const result = await request.execute('GetOrdersPaged');

        // Raw orders
        const orders = result.recordsets[0];
        const pagination = result.recordsets[1][0];

        // Orders with product list
        const ordersWithContent = await Promise.all(orders.map(async (order) => {
            const contentRequest = pool.request(); 
            
            contentRequest.input('input_MaDon', sql.VarChar, order.MaDon);
            const contentResult = await contentRequest.execute('GetOrderContentByMaDon');
            const productList = contentResult.recordsets[0];

            const userRequest = pool.request();

            userRequest.input('UserID', sql.VarChar, order.UserID);
            const userResult = await userRequest.query('SELECT * FROM [User] WHERE UserID = @UserID');
            const userInfo = userResult.recordsets[0][0];


            return {
                ...order,
                userInfo: userInfo,
                productList: productList
            };
        }));


        const reponseContent = {
            orders: ordersWithContent,
            pagination: pagination
        } 

        return res.json(reponseContent);
    }
    catch (error) {
        console.error(error);
        return res.status(500).send({ message: 'Error executing get orders paged.' });
    }
});





// (GET)/order/orders/:UserID
// Return orders with paging
router.get('/orders/:UserID', async (req, res) => {
    const UserID = req.params.UserID
    const page = parseInt(req.query.page) || 1
    const limit = parseInt(req.query.limit) || 10
    try {
        const pool = await sql.connect(dbConfig);
        const request = pool.request(); 

        request.input('input_UserID', sql.VarChar, UserID)
        request.input('page', sql.Int, page)
        request.input('limit', sql.Int, limit)

        const result = await request.execute('GetOrderListByUserIDPaged');

        const orders = result.recordsets[0];
        const pagination = result.recordsets[1][0];

        const reponseContent = {
            orders: orders,
            pagination: pagination
        } 

        return res.json(reponseContent);
    }
    catch (error) {
        console.error(error);
        return res.status(500).send({ message: 'Error executing get order list by UserID paged.' });
    }
});






// (GET)/order/orders/:UserID
// Get order list by user ID
router.get('/orders/:UserID', async (req, res) => {
    const UserID = req.params.UserID;
    try {
        const pool = await sql.connect(dbConfig);
        const request = pool.request(); 

        request.input('input_UserID', sql.VarChar, UserID); 
        const result = await request.execute('GetOrderListByUserID');

        return res.json(result.recordsets[0]); 
    } catch (error) {
        console.error(error);
        return res.status(500).send({ message: 'Error executing get orderlist by UserID.' });
    }
});




// (GET)/order/:MaDon
// Get order content by MaDon
router.get('/:MaDon', async (req, res) => {
    const MaDon = req.params.MaDon;
    try {
        const pool = await sql.connect(dbConfig);
        const request = pool.request(); 

        request.input('input_MaDon', sql.VarChar, MaDon); 
        const result = await request.execute('GetOrderContentByMaDon');

        return res.json(result.recordsets[0]); 
    } catch (error) {
        console.error(error);
        return res.status(500).send({ message: 'Error executing get order content by MaDon.' });
    }
});










// (PUT) /order/:MaDon/status
// Updates status of an order 
router.put('/:MaDon/status', async (req, res) => {
    const { MaDon } = req.params;
    const { newStatus } = req.body;

    if (!newStatus) {
        return res.status(400).json({ error: 'Missing required field: newStatus in request body.' });
    }


    try {
        const pool = await sql.connect(dbConfig);
        const request = pool.request();

        // Prepare input n run
        request.input('MaDon', sql.VarChar, MaDon);
        request.input('NewTrangThai', sql.NVarChar(20), newStatus);

        const result = await request.execute('UpdateOrderStatus');

        // Good exec
        const updateResult = result.recordset[0];

        res.status(200).json({
            status: 'success',
            message: updateResult.Message || 'Order status updated.',
            data: {
                MaDon: updateResult.MaDon,
                NewTrangThai: updateResult.NewTrangThai
            }
        });

    } catch (err) {
        // Bad exec
        console.error(`Error processing order ${MaDon} update to ${newStatus}:`, err.message);

        // Send a meaningful response back to the client
        const errorMessage = err.message || 'An unknown error occurred during the update.';
        
        if (err.number === 50001) {
            // Invalid transition error from trigger
            return res.status(400).json({ 
                status: 'failure',
                code: 'INVALID_TRANSITION',
                message: errorMessage
            });
        }
        
        if (err.number === 50002) {
            // Order not found error from procedure
            return res.status(404).json({ 
                status: 'failure',
                code: 'ORDER_NOT_FOUND',
                message: errorMessage
            });
        }
        
        // Generic fallback error
        res.status(500).json({ 
            status: 'error',
            message: 'Internal server error: Could not complete the database operation.' 
        });
    }
});





module.exports = router;