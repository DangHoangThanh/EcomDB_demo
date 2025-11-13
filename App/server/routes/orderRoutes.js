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
    try {
        const pool = await sql.connect(dbConfig);
        const request = pool.request(); 

        request.input('page', sql.Int, page)
        request.input('limit', sql.Int, limit)

        const result = await request.execute('GetOrdersPaged');

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






module.exports = router;