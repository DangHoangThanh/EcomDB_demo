const express = require('express');
const router = express.Router();
const sql = require('mssql');

// import dbConfig
const dbConfig = require('../dbConfig');





// (GET)/product/products/
// Return products with paging
router.get('/products/', async (req, res) => {
    const page = parseInt(req.query.page) || 1
    const limit = parseInt(req.query.limit) || 10
    try {
        const pool = await sql.connect(dbConfig);
        const request = pool.request(); 

        request.input('page', sql.Int, page)
        request.input('limit', sql.Int, limit)

        const result = await request.execute('GetProductsPaged');

        const products = result.recordsets[0];
        const pagination = result.recordsets[1][0];

        const reponseContent = {
            products: products,
            pagination: pagination
        } 

        return res.json(reponseContent);
    }
    catch (error) {
        console.error(error);
        return res.status(500).send({ message: 'Error executing get products paged.' });
    }
});




// (GET)/:MaSP
// Return single product
router.get('/:MaSP', async (req, res) => {
    const MaSP = req.params.MaSP;
    try {
        const pool = await sql.connect(dbConfig);
        const request = pool.request();

        request.input('MaSP', sql.VarChar, MaSP);
        const result = await request.query('SELECT * FROM [SanPham] WHERE MaSP = @MaSP');
        
        return res.json(result.recordsets[0]);
    }
    catch (error) {
        console.log(error);
        return res.status(500).send({ message: 'Error executing get product query.' });
    }
});







// (GET)/products/topbuy
// Return top limit most bought products by UserID
router.get('/products/toppurchased', async (req, res) => {
    const UserID = req.query.UserID;
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