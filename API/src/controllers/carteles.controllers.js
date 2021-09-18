import {getConnection} from '../database/connection';

export const getDetalleGeneral = async (req, res) =>{

    const pool =await getConnection();
    const result =await pool.request().query('EXEC REP_DetallesCartel');

    console.log(result);


    res.json(result.recordset);
};

export const getDetalleLineas = async (req, res) =>{

    const pool =await getConnection();
    const result =await pool.request().query('EXEC REP_DetallesLineas');

    console.log(result);


    res.json(result.recordset);
};