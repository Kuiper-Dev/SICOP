import {getConnection} from '../database/connection';

export const getContratos = async (req, res) =>{
    const pool =await getConnection();
    const result =await pool.request().query('EXEC REP_CONTRATOS');
    console.log(result);
    res.json(result.recordset);
};
export const getContratoAdicional = async (req, res) =>{
    const pool =await getConnection();
    const result =await pool.request().query('EXEC REP_ContratoAdicional');
    console.log(result);
    res.json(result.recordset);
};
export const getLineasContratos = async (req, res) =>{
    const pool =await getConnection();
    const result =await pool.request().query('EXEC REP_LineasContrato');
    console.log(result);
    res.json(result.recordset);
};
