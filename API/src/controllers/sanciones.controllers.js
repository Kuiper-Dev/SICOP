import {getConnection} from '../database/connection';

export const getSancionesProveedores = async (req, res) =>{
    const pool =await getConnection();
    const result =await pool.request().query('EXEC REP_SancionesProveedores');
    console.log(result);
    res.json(result.recordset);
};