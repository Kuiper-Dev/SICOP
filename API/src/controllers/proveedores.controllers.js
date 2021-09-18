import {getConnection} from '../database/connection';

export const getProveedores = async (req, res) =>{
    const pool =await getConnection();
    const result =await pool.request().query('EXEC REP_Proveedores');
    console.log(result);
    res.json(result.recordset);
};

export const getProveedoresAdjudicados = async (req, res) =>{
    const pool =await getConnection();
    const result =await pool.request().query('EXEC REP_ProveedoresAdjudicados');
    console.log(result);
    res.json(result.recordset);
};

export const getProveedoresSancionados = async (req, res) =>{
    const pool =await getConnection();
    const result =await pool.request().query('EXEC REP_ProveedoresSancionados');
    console.log(result);
    res.json(result.recordset);
};